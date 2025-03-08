/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class View.EditView : Adw.NavigationPage {
    public signal void saved ();

    private bool is_loading = false;
    private unowned Model.DesktopFile desktop_file;

    private Gtk.Button save_button;
    private Adw.HeaderBar headerbar;

    private Gtk.Image icon_image;
    private Gtk.Label name_label;

    private Adw.EntryRow name_entry;
    private Adw.EntryRow exec_entry;
    private Adw.EntryRow icon_entry;
    private Adw.EntryRow generic_name_entry;
    private Adw.EntryRow comment_entry;
    private Widget.CategoriesRow categories_row;
    private Widget.KeywordsRow keywords_row;
    private Adw.EntryRow startup_wm_class_entry;
    private Adw.SwitchRow terminal_row;
    private Adw.SwitchRow nodisplay_row;

    private Gtk.ScrolledWindow edit_page;
    private Adw.StatusPage blank_page;
    private Gtk.Stack stack;

    public EditView () {
    }

    construct {
        /*
         * Headerbar part
         */
        save_button = new Gtk.Button.with_mnemonic (_("_Save"));
        save_button.add_css_class ("suggested-action");

        headerbar = new Adw.HeaderBar ();
        headerbar.pack_end (save_button);

        /*
         * Content part - header
         */
        icon_image = new Gtk.Image.from_gicon (new ThemedIcon ("application-x-executable")) {
            pixel_size = 128
        };
        name_label = new Gtk.Label (null) {
            lines = 1,
            ellipsize = Pango.EllipsizeMode.END
        };
        name_label.add_css_class ("title-1");

        var header_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 24) {
            halign = Gtk.Align.CENTER,
            margin_bottom = 32
        };
        header_box.append (icon_image);
        header_box.append (name_label);

        /*
         * Content part - Required Fields
         */
        var required_group = new Adw.PreferencesGroup () {
            title = _("Required Fields"),
            description = _("The following fields need to be filled to save.")
        };

        name_entry = new Adw.EntryRow () {
            title = _("App Name"),
            tooltip_text = _("Shown in the launcher or dock.")
        };
        required_group.add (name_entry);

        exec_entry = new Adw.EntryRow () {
            title = _("Exec File"),
            tooltip_text = _("The command/app launched when you click the app entry in the launcher. Specify in an absolute path or an app's alias name.")
        };
        var exec_chooser_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select an executable file…"),
            valign = Gtk.Align.CENTER
        };
        exec_chooser_button.add_css_class ("flat");
        exec_entry.add_suffix (exec_chooser_button);
        required_group.add (exec_entry);

        /*
         * Content part - Optional Fields
         */
        var optional_group = new Adw.PreferencesGroup () {
            title = _("Optional Fields"),
            description = _("Filling these fields improves discoverability in the app launcher.")
        };

        icon_entry = new Adw.EntryRow () {
            title = _("Icon File"),
            tooltip_text = _("The icon branding the app. Specify in an absolute path or an icon's alias name.")
        };
        var icon_chooser_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select an icon file…"),
            valign = Gtk.Align.CENTER
        };
        icon_chooser_button.add_css_class ("flat");
        icon_entry.add_suffix (icon_chooser_button);
        optional_group.add (icon_entry);

        generic_name_entry = new Adw.EntryRow () {
            title = _("Generic Name"),
            tooltip_text = _("Generic name of the app, for example \"Web Browser\" or \"Mail Client\".")
        };
        optional_group.add (generic_name_entry);

        comment_entry = new Adw.EntryRow () {
            title = _("Comment"),
            tooltip_text = _("Descibes the app. May appear as a tooltip when you hover over the app entry in the launcher/dock.")
        };
        optional_group.add (comment_entry);

        categories_row = new Widget.CategoriesRow ();
        optional_group.add (categories_row);

        keywords_row = new Widget.KeywordsRow ();
        optional_group.add (keywords_row);

        /*
         * Content part - Advanced Configurations
         */
        var advanced_group = new Adw.PreferencesGroup () {
            title = _("Advanced Configurations"),
            description = _("You can create most app entries just by filling in the sections above. However, some apps may require the advanced configuration options below.")
        };

        startup_wm_class_entry = new Adw.EntryRow () {
            title = _("Startup WM Class"),
            tooltip_text = _("Associate the app with a window that has this ID. Use this if a different or duplicated icon appears in the dock when the app launches.")
        };
        advanced_group.add (startup_wm_class_entry);

        terminal_row = new Adw.SwitchRow () {
            title = _("Run in Terminal"),
            subtitle = _("Turn on if you want to register a CUI app.")
        };
        advanced_group.add (terminal_row);

        nodisplay_row = new Adw.SwitchRow () {
            title = _("Hide in Applications Menu"),
            subtitle = _("Useful when you won't launch the app by itself, but want to associate it with filetypes to open files with the app from file managers.")
        };
        advanced_group.add (nodisplay_row);

        var open_text_editor_button = new Gtk.Button.with_mnemonic (_("_Open")) {
            valign = Gtk.Align.CENTER
        };
        var open_in_row = new Adw.ActionRow () {
            title = _("Open with Text Editor"),
            subtitle = _("You can also edit more options by opening with a text editor."),
            activatable_widget = open_text_editor_button
        };
        open_in_row.add_suffix (open_text_editor_button);
        advanced_group.add (open_in_row);

        var content = new Gtk.Box (Gtk.Orientation.VERTICAL, 24);
        content.append (header_box);
        content.append (required_group);
        content.append (optional_group);
        content.append (advanced_group);

        var clamp = new Adw.Clamp () {
            child = content,
            maximum_size = 500,
            tightening_threshold = 400,
            unit = Adw.LengthUnit.SP,
            margin_top = 32,
            margin_bottom = 32,
            margin_start = 16,
            margin_end = 16
        };

        // Pack into a scrolled window for small height display
        edit_page = new Gtk.ScrolledWindow () {
            child = clamp,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            hexpand = true
        };

        // The blank page shown when no desktop file open.
        blank_page = new Adw.StatusPage () {
            vexpand = true,
            hexpand = true
        };

        stack = new Gtk.Stack ();
        stack.add_child (edit_page);
        stack.add_child (blank_page);

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.set_content (stack);

        title = _("New Entry");
        child = toolbar_view;

        // No desktop file open when the app launches, so hide all widgets in the view.
        hide_all ();

        save_button.clicked.connect (() => {
            save_file ();
        });

        name_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            if (name_entry.text == "") {
                name_label.label = _("Untitled App");
            } else {
                name_label.label = name_entry.text;
            }

            desktop_file.value_name = name_entry.text;
            set_save_button_sensitivity ();
        });

        exec_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_exec = exec_entry.text;
            set_save_button_sensitivity ();
        });

        exec_chooser_button.clicked.connect (() => {
            var filechooser = new Gtk.FileDialog () {
                title = _("Select Executable File"),
                accept_label = _("_Select"),
                modal = true
            };
            filechooser.open.begin ((Gtk.Window) get_root (), null, (obj, res) => {
                try {
                    var file = filechooser.open.end (res);
                    if (file == null) {
                        return;
                    }

                    string? path = file.get_path ();
                    if (path == null) {
                        warning ("Invalid executable path");
                        return;
                    }

                    exec_entry.text = path;
                    desktop_file.value_exec = path;
                    set_save_button_sensitivity ();
                } catch (Error err) {
                    warning ("Failed to select executable file: %s", err.message);
                }
            });
        });

        icon_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            try {
                icon_image.gicon = Icon.new_for_string (icon_entry.text);
            } catch (Error err) {
                warning ("Failed to update icon_image: %s", err.message);
            }

            desktop_file.value_icon = icon_entry.text;
        });

        icon_chooser_button.clicked.connect (() => {
            /*
             * Acceptable file formats in this FileChooser are: PNG, XPM, SVG, and plus ICO.
             * The first three formats are defined as supported in the fd.o specification,
             * see https://specifications.freedesktop.org/icon-theme-spec/latest/ar01s02.html.
             *
             * ICO, the last one, is not in the supported formats list above, but it should work as expected
             * in the modern desktop environment.
             */
            var filefilter = new Gtk.FileFilter ();
            filefilter.add_mime_type ("image/png");
            filefilter.add_mime_type ("image/svg+xml");
            filefilter.add_mime_type ("image/x-xpixmap");
            filefilter.add_mime_type ("image/vnd.microsoft.icon");
            filefilter.set_filter_name (_("ICO, PNG, SVG, or XMP files"));

            var filechooser = new Gtk.FileDialog () {
                title = _("Select Icon File"),
                accept_label = _("_Select"),
                modal = true,
                default_filter = filefilter
            };
            filechooser.open.begin ((Gtk.Window) get_root (), null, (obj, res) => {
                try {
                    var file = filechooser.open.end (res);
                    if (file == null) {
                        return;
                    }

                    string? path = file.get_path ();
                    if (path == null) {
                        warning ("Invalid icon path");
                        return;
                    }

                    icon_entry.text = path;
                    desktop_file.value_icon = path;
                } catch (Error err) {
                    warning ("Failed to select icon file: %s", err.message);
                }
            });
        });

        generic_name_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_generic_name = generic_name_entry.text;
        });

        comment_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_comment = comment_entry.text;
        });

        categories_row.categories_changed.connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_categories = categories_row.to_strv ();
        });

        keywords_row.keywords_changed.connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_keywords = keywords_row.to_strv ();
        });

        startup_wm_class_entry.notify["text"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_startup_wm_class = startup_wm_class_entry.text;
        });

        terminal_row.notify["active"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_terminal = terminal_row.active;
        });

        nodisplay_row.notify["active"].connect (() => {
            if (is_loading) {
                return;
            }

            desktop_file.value_nodisplay = nodisplay_row.active;
        });

        open_text_editor_button.clicked.connect (() => {
            open_external.begin (desktop_file.path, (obj, res) => {
                bool ret;

                try {
                    ret = open_external.end (res);
                } catch (Error err) {
                    // The calling method is responsible for showing the error log.

                    // Do not treat as an error if the operation is just dismissed by the user.
                    if (err.matches (Gtk.DialogError.quark (), Gtk.DialogError.DISMISSED)) {
                        ret = true;
                    }
                }

                if (!ret) {
                    var error_dialog = new Adw.AlertDialog (
                        _("Failed to Open with External App"),
                        _("There was an error while opening the file with an external app.")
                    );
                    error_dialog.add_response (Define.DialogResponse.CLOSE, _("_Close"));
                    error_dialog.default_response = Define.DialogResponse.CLOSE;
                    error_dialog.close_response = Define.DialogResponse.CLOSE;
                    error_dialog.present ((Adw.ApplicationWindow) get_root ());
                }
            });
        });
    }

    /**
     * Load and fill in the all input widgets in the EditView from the desktp file.
     *
     * @param file The desktop file to load.
     */
    public void load_file (Model.DesktopFile file) {
        // Prevent desktop_file from being updated by signal handlers, which causes the app segfault.
        is_loading = true;
        desktop_file = file;

        string icon = desktop_file.value_icon;

        try {
            icon_image.gicon = Icon.new_for_string (icon);
        } catch (Error err) {
            warning ("Failed to update icon_image: %s", err.message);
        }

        string app_name = desktop_file.value_name;
        if (app_name == "") {
            name_label.label = _("Untitled App");
        } else {
            name_label.label = app_name;
        }

        name_entry.text = app_name;
        exec_entry.text = desktop_file.value_exec;
        icon_entry.text = icon;

        generic_name_entry.text = desktop_file.value_generic_name;

        comment_entry.text = desktop_file.value_comment;

        categories_row.from_strv (desktop_file.value_categories);
        keywords_row.from_strv (desktop_file.value_keywords);
        startup_wm_class_entry.text = desktop_file.value_startup_wm_class;
        terminal_row.active = desktop_file.value_terminal;
        nodisplay_row.active = desktop_file.value_nodisplay;

        // Show the page that filled in just now.
        stack.visible_child = edit_page;

        // Set title label of the header depending on the status of the opened desktop file.
        if (app_name == "") {
            title = _("Edit Entry");
        } else {
            title = _("Edit “%s”").printf (app_name);
        }

        is_loading = false;

        headerbar.show_title = true;
        save_button.visible = true;
        set_save_button_sensitivity ();
    }

    /**
     * Get values from the input widgets in the view and save them to a desktop file.
     */
    public void save_file () {
        bool ret = desktop_file.save_file ();
        if (!ret) {
            string dialog_title = _("Failed to Save Entry");
            string app_name = desktop_file.value_name;
            if (app_name != "") {
                dialog_title = _("Failed to Save Entry of “%s”").printf (app_name);
            }

            var error_dialog = new Adw.AlertDialog (
                dialog_title,
                _("There was an error while saving the app entry.")
            );
            error_dialog.add_response (Define.DialogResponse.CLOSE, _("_Close"));
            error_dialog.default_response = Define.DialogResponse.CLOSE;
            error_dialog.close_response = Define.DialogResponse.CLOSE;
            error_dialog.present ((Adw.ApplicationWindow) get_root ());
            return;
        }

        Util.DesktopFileUtil.add_exec_permission (desktop_file.value_exec);
        saved ();
    }

    /**
     * Hide all widgets in this.
     */
    public void hide_all () {
        stack.visible_child = blank_page;

        headerbar.show_title = false;
        save_button.visible = false;
    }

    /**
     * Allow clicking the save button only when the required entries has (valid) values.
     */
    private void set_save_button_sensitivity () {
        save_button.sensitive = (name_entry.text.length > 0 && exec_entry.text.length > 0);
    }

    private async bool open_external (string path) throws Error {
        var file = File.new_for_path (path);

        var file_launcher = new Gtk.FileLauncher (file) {
            always_ask = true
        };

        bool ret = false;
        try {
            ret = yield file_launcher.launch ((Gtk.Window) get_root (), null);
        } catch (Error err) {
            warning ("Failed to open file externally. path=%s: %s", path, err.message);
            throw err;
        }

        return ret;
    }
}
