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
                file_name_entry.text.length > 0 || name_entry.text.length > 0 || exec_entry.text.length > 0 ||
                icon_entry.text.length > 0 || comment_entry.text.length > 0 || categories_row.selected != "" ||
                startup_wm_class_entry.text.length > 0 || terminal_row.active
            );
        }
    }

    public MainWindow window { private get; construct; }

    // TODO Use this if the specified icon is invalid.
    private Icon fallback_icon = new ThemedIcon ("application-x-executable");

    private Gtk.Button save_button;
    private Adw.HeaderBar headerbar;

    private Gtk.Image icon_image;
    private Gtk.Label name_label;

    private RegexEntry file_name_entry;
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
        icon_image = new Gtk.Image.from_gicon (fallback_icon) {
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

        file_name_entry = new RegexEntry (/^[^.0-9]{1}([A-Za-z0-9]*\.)+[A-Za-z0-9]*[^.]$/, false) { //vala-lint=space-before-paren
            title = _("File Name")
        };
        file_name_entry.add_suffix (create_hint_button ());
        required_group.add (file_name_entry);

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
                } catch (Error e) {
                    warning ("Failed to select icon file: %s", e.message);
                }
            });
        });

        open_text_editor_button.clicked.connect (() => {
            try {
                DesktopFileOperator.get_default ().open_external (file_name_entry.text);
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

        /*
         * When there are some changes in the input widgets (entries, buttons, category chooser, etc.),
         * update the sensitivity of the save button.
         */
        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_released.connect ((keyval, keycode, state) => {
            set_save_button_sensitivity ();
        });
        add_controller (event_controller);

        categories_row.toggled.connect (() => {
            set_save_button_sensitivity ();
        });
    }

    /**
     * Fill in the all input widgets in the EditView from the loaded desktp file.
     *
     * @param desktop_file      The desktop file to reflect its content to the widgets.
     */
    public void set_desktop_file (DesktopFile desktop_file) {
        try {
            icon_image.gicon = Icon.new_for_string (desktop_file.icon_file);
        } catch (Error e) {
            warning ("Failed to update icon_image: %s", e.message);
        }

        if (name_entry.text == "") {
            name_label.label = _("Untitled App");
        } else {
            name_label.label = name_entry.text;
        }

        file_name_entry.text = desktop_file.file_name;
        name_entry.text = desktop_file.app_name;
        exec_entry.text = desktop_file.exec_file;
        icon_entry.text = desktop_file.icon_file;
        comment_entry.text = desktop_file.comment;
        categories_row.selected = desktop_file.categories;
        startup_wm_class_entry.text = desktop_file.startup_wm_class;
        terminal_row.active = desktop_file.is_cli;

        // Show the page that filled in just now.
        stack.visible_child = edit_page;

        // Set title label of the header depending on the status of the opened desktop file.
        if (desktop_file.file_name == "") {
            // No file name means a new file.
            title = _("New Entry");
        } else if (desktop_file.app_name == "") {
            // Editing an existing desktop file with no app name
            title = _("Edit Entry");
        } else {
            // Editing an existing desktop file with app name.
            title = _("Edit “%s”").printf (desktop_file.app_name);
        }

        headerbar.show_title = true;
        save_button.visible = true;
        set_save_button_sensitivity ();
    }

    /**
     * Get values from the input widgets in the view and save them to a desktop file.
     */
    public void save_file (bool is_backup = false) {
        var desktop_file = new DesktopFile (
            file_name_entry.text,
            name_entry.text,
            comment_entry.text,
            exec_entry.text,
            icon_entry.text,
            categories_row.selected,
            startup_wm_class_entry.text,
            terminal_row.active,
            is_backup
        );

        try {
            DesktopFileOperator.get_default ().write_to_file (desktop_file);
            DesktopFileOperator.get_default ().add_exec_permission (desktop_file.exec_file);
            file_updated ();
        } catch (Error e) {
            var error_dialog = new Adw.MessageDialog (
                window,
                _("Could not write to file “%s”").printf (desktop_file.app_name),
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

    private Gtk.MenuButton create_hint_button () {
        var summary_label = new Gtk.Label (_("Name of the .desktop file, where this app's info will be saved.")) {
            halign = Gtk.Align.START,
            margin_bottom = 12
        };

        var desc_label = new Gtk.Label (
            _("It is recommended to use only alphanumeric characters and underscores. Don't begin with a number.") + "\n" +
            _("Include at least two elements (sections of the string seperated by a period). Most apps use three elements.")
        ) {
            halign = Gtk.Align.START
        };
        desc_label.add_css_class ("body");

        var example_label = new Gtk.Label (
            ///TRANSLATORS: "%s" will be replaced by the string "org.supertuxproject.SuperTux" which is
            ///the desktop file name of SuperTux.
            _("For example, you should use \"%s\" for the 2D game, SuperTux.").printf ("<b>org.supertuxproject.SuperTux</b>")
        ) {
            use_markup = true,
            halign = Gtk.Align.START
        };
        example_label.add_css_class ("body");

        var detailed_label = new Gtk.Label (
            ///TRANSLATORS: "%s" will be replaced by the translated string of the text "the file naming specification by freedesktop.org".
            _("For more info, see %s.").printf (
            "<a href=\"https://dbus.freedesktop.org/doc/dbus-specification.html#message-protocol-names-bus\">%s</a>").printf (
            _("the file naming specification by freedesktop.org")
        )) {
            use_markup = true,
            halign = Gtk.Align.START,
            margin_top = 12
        };
        detailed_label.add_css_class ("body");

        var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        box.append (summary_label);
        box.append (desc_label);
        box.append (example_label);
        box.append (detailed_label);

        var popover = new Gtk.Popover () {
            child = box
        };

        var menu_button = new Gtk.MenuButton () {
            icon_name = "help-contents-symbolic",
            margin_start = 6,
            popover = popover,
            valign = Gtk.Align.CENTER
        };
        menu_button.add_css_class ("flat");

        menu_button.activate.connect (() => {
            popover.popup ();
        });

        return menu_button;
    }

    /**
     * Allow clicking the save button only when the required entries has (valid) values.
     */
    private void set_save_button_sensitivity () {
        save_button.sensitive = (file_name_entry.is_valid && name_entry.text.length > 0 && exec_entry.text.length > 0);
    }
}
