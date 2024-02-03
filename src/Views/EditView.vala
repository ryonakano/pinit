/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class EditView : Adw.NavigationPage {
    public signal void file_updated ();

    /*
     * When at least one input widget in this view is changed,
     * we consider the currently open desktop file as unsaved.
     */
    public bool is_unsaved {
        get {
            return (
                name_entry.text.length > 0 || exec_entry.text.length > 0 ||
                icon_entry.text.length > 0 || comment_entry.text.length > 0 || categories_row.selected.length > 0 ||
                startup_wm_class_entry.text.length > 0 || terminal_row.active
            );
        }
    }

    public MainWindow window { private get; construct; }

    private unowned DesktopFile desktop_file;

    private Gtk.Button save_button;
    private Adw.HeaderBar headerbar;

    private Gtk.Image icon_image;
    private Gtk.Label name_label;

    private Adw.EntryRow name_entry;
    private Adw.EntryRow exec_entry;
    private Adw.EntryRow icon_entry;
    private Adw.EntryRow comment_entry;
    private CategoryChooser categories_row;
    private Adw.EntryRow startup_wm_class_entry;
    private Adw.SwitchRow terminal_row;

    private Gtk.ScrolledWindow edit_page;
    private Adw.StatusPage blank_page;
    private Gtk.Stack stack;

    public EditView (MainWindow window) {
        Object (window: window);
    }

    construct {
        /*
         * Headerbar part
         */
        save_button = new Gtk.Button.with_label (_("Save"));
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
         * Content part - Required Entries
         */
        var required_group = new Adw.PreferencesGroup () {
            title = _("Required Entries"),
            description = _("The following entries need to be filled to save.")
        };

        name_entry = new Adw.EntryRow () {
            title = _("App Name")
        };
        required_group.add (name_entry);

        exec_entry = new Adw.EntryRow () {
            title = _("Exec File")
        };
        var exec_chooser_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select an executable file"),
            valign = Gtk.Align.CENTER
        };
        exec_chooser_button.add_css_class ("flat");
        exec_entry.add_suffix (exec_chooser_button);
        required_group.add (exec_entry);

        /*
         * Content part - Optional Entries
         */
        var optional_group = new Adw.PreferencesGroup () {
            title = _("Optional Entries"),
            description = _("Filling these entries improves discoverability in the app launcher.")
        };

        icon_entry = new Adw.EntryRow () {
            title = _("Icon File")
        };
        var icon_chooser_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select an icon file"),
            valign = Gtk.Align.CENTER
        };
        icon_chooser_button.add_css_class ("flat");
        icon_entry.add_suffix (icon_chooser_button);
        optional_group.add (icon_entry);

        comment_entry = new Adw.EntryRow () {
            title = _("Comment")
        };
        optional_group.add (comment_entry);

        categories_row = new CategoryChooser ();
        optional_group.add (categories_row);

        /*
         * Content part - Advanced Entries
         */
        var advanced_group = new Adw.PreferencesGroup () {
            title = _("Advanced Configurations"),
            description = _("You can create most app entries just by filling in the sections above. However, some apps may require the advanced configuration options below.")
        };

        startup_wm_class_entry = new Adw.EntryRow () {
            title = _("Startup WM Class")
        };
        advanced_group.add (startup_wm_class_entry);

        terminal_row = new Adw.SwitchRow () {
            title = _("Run in Terminal"),
            subtitle = _("Turn on if you want to register a CUI app.")
        };
        advanced_group.add (terminal_row);

        var open_text_editor_button = new Gtk.Button.with_label (_("Open")) {
            valign = Gtk.Align.CENTER
        };
        var open_in_row = new Adw.ActionRow () {
            title = _("Open in Text Editor"),
            subtitle = _("You can also edit more options by opening in a text editor."),
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
            if (name_entry.text == "") {
                name_label.label = _("Untitled App");
            } else {
                name_label.label = name_entry.text;
            }

            desktop_file.set_string (KeyFileDesktop.KEY_NAME, name_entry.text);
            set_save_button_sensitivity ();
        });

        exec_entry.notify["text"].connect (() => {
            desktop_file.set_string (KeyFileDesktop.KEY_EXEC, name_entry.text);
            set_save_button_sensitivity ();
        });

        exec_chooser_button.clicked.connect (() => {
            var filechooser = new Gtk.FileDialog () {
                title = _("Select an executable file"),
                accept_label = _("Select"),
                modal = true
            };
            filechooser.open.begin (window, null, (obj, res) => {
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
                    desktop_file.set_string (KeyFileDesktop.KEY_EXEC, path);
                    set_save_button_sensitivity ();
                } catch (Error e) {
                    warning ("Failed to select executable file: %s", e.message);
                }
            });
        });

        icon_entry.notify["text"].connect (() => {
            try {
                icon_image.gicon = Icon.new_for_string (icon_entry.text);
            } catch (Error e) {
                warning ("Failed to update icon_image: %s", e.message);
            }

            desktop_file.set_string (KeyFileDesktop.KEY_ICON, icon_entry.text, false);
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
                title = _("Select an icon file"),
                accept_label = _("Select"),
                modal = true,
                default_filter = filefilter
            };
            filechooser.open.begin (window, null, (obj, res) => {
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
                    desktop_file.set_string (KeyFileDesktop.KEY_ICON, path, false);
                } catch (Error e) {
                    warning ("Failed to select icon file: %s", e.message);
                }
            });
        });

        comment_entry.notify["text"].connect (() => {
            desktop_file.set_string (KeyFileDesktop.KEY_COMMENT, comment_entry.text, false);
        });

        categories_row.toggled.connect (() => {
            desktop_file.set_string_list (KeyFileDesktop.KEY_CATEGORIES, categories_row.selected, false);
        });

        startup_wm_class_entry.notify["text"].connect (() => {
            desktop_file.set_string (KeyFileDesktop.KEY_STARTUP_WM_CLASS, startup_wm_class_entry.text, false);
        });

        terminal_row.notify["active"].connect (() => {
            desktop_file.set_boolean (KeyFileDesktop.KEY_TERMINAL, terminal_row.active, false);
        });

        open_text_editor_button.clicked.connect (() => {
            try {
                desktop_file.open_external ();
            } catch (Error e) {
                var error_dialog = new Adw.MessageDialog (
                    window,
                    _("Could not open with external app"),
                    e.message
                );
                error_dialog.add_response (DialogResponse.CLOSE, _("Close"));
                error_dialog.default_response = DialogResponse.CLOSE;
                error_dialog.close_response = DialogResponse.CLOSE;
                error_dialog.response.connect ((response_id) => {
                    if (response_id == DialogResponse.CLOSE) {
                        error_dialog.destroy ();
                    }
                });
                error_dialog.present ();
            }
        });
    }

    /**
     * Load and fill in the all input widgets in the EditView from the desktp file.
     *
     * @param file The desktop file to load.
     */
    public void load_file () {
        desktop_file = DesktopFileOperator.get_default ().desktop_file;

        try {
            desktop_file.load_file (KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (FileError e) {
            warning (e.message);
            return;
        } catch (KeyFileError e) {
            warning (e.message);
            return;
        }

        string icon = desktop_file.get_string (KeyFileDesktop.KEY_ICON, false);

        try {
            icon_image.gicon = Icon.new_for_string (icon);
        } catch (Error e) {
            warning ("Failed to update icon_image: %s", e.message);
        }

        string locale = desktop_file.get_locale_for_key (KeyFileDesktop.KEY_NAME, DesktopFileOperator.get_default ().preferred_language);
        string app_name = desktop_file.get_locale_string (KeyFileDesktop.KEY_NAME, locale);
        if (app_name == "") {
            name_label.label = _("Untitled App");
        } else {
            name_label.label = app_name;
        }

        name_entry.text = app_name;
        exec_entry.text = desktop_file.get_string (KeyFileDesktop.KEY_EXEC);
        icon_entry.text = icon;

        locale = desktop_file.get_locale_for_key (KeyFileDesktop.KEY_COMMENT, DesktopFileOperator.get_default ().preferred_language);
        comment_entry.text = desktop_file.get_locale_string (KeyFileDesktop.KEY_COMMENT, locale, false);

        categories_row.selected = desktop_file.get_string_list (KeyFileDesktop.KEY_CATEGORIES, false);
        startup_wm_class_entry.text = desktop_file.get_string (KeyFileDesktop.KEY_STARTUP_WM_CLASS, false);
        terminal_row.active = desktop_file.get_boolean (KeyFileDesktop.KEY_TERMINAL, false);

        // Show the page that filled in just now.
        stack.visible_child = edit_page;

        // Set title label of the header depending on the status of the opened desktop file.
        if (app_name == "") {
            title = _("Edit Entry");
        } else {
            title = _("Edit “%s”").printf (app_name);
        }

        headerbar.show_title = true;
        save_button.visible = true;
        set_save_button_sensitivity ();
    }

    /**
     * Get values from the input widgets in the view and save them to a desktop file.
     */
    public void save_file () {
        try {
            desktop_file.save_file ();
            DesktopFileOperator.get_default ().add_exec_permission (
                desktop_file.get_string (KeyFileDesktop.KEY_EXEC)
            );
            file_updated ();
        } catch (Error e) {
            string locale = desktop_file.get_locale_for_key (KeyFileDesktop.KEY_NAME, DesktopFileOperator.get_default ().preferred_language);
            string app_name = desktop_file.get_locale_string (KeyFileDesktop.KEY_NAME, locale);

            string dialog_title = _("Could not save entry");
            if (app_name != "") {
                dialog_title = _("Could not save entry of “%s”").printf (app_name);
            }

            var error_dialog = new Adw.MessageDialog (
                window,
                dialog_title,
                e.message
            );
            error_dialog.add_response (DialogResponse.CLOSE, _("Close"));
            error_dialog.default_response = DialogResponse.CLOSE;
            error_dialog.close_response = DialogResponse.CLOSE;
            error_dialog.response.connect ((response_id) => {
                if (response_id == DialogResponse.CLOSE) {
                    error_dialog.destroy ();
                }
            });
            error_dialog.present ();
        }
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
}
