/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class EditView : Adw.NavigationPage {
    public MainWindow window { private get; construct; }

    private Gtk.Button save_button;
    private Adw.HeaderBar headerbar;

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
        var icon_image = new Gtk.Image.from_icon_name ("application-x-executable") {
            use_fallback = false,
            pixel_size = 128
        };
        var name_label = new Gtk.Label (null);
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

        var file_name_entry = new RegexEntry (/^[^.0-9]{1}([A-Za-z0-9]*\.)+[A-Za-z0-9]*[^.]$/, false) { //vala-lint=space-before-paren
            title = _("File Name")
        };
        file_name_entry.add_suffix (create_hint_button ());
        required_group.add (file_name_entry);

        var name_entry = new Adw.EntryRow () {
            title = _("App Name")
        };
        required_group.add (name_entry);

        var exec_entry = new Adw.EntryRow () {
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

        var icon_entry = new Adw.EntryRow () {
            title = _("Icon File")
        };
        var icon_chooser_button = new Gtk.Button.from_icon_name ("document-open-symbolic") {
            tooltip_text = _("Select an icon file"),
            valign = Gtk.Align.CENTER
        };
        icon_chooser_button.add_css_class ("flat");
        icon_entry.add_suffix (icon_chooser_button);
        optional_group.add (icon_entry);

        var comment_entry = new Adw.EntryRow () {
            title = _("Comment")
        };
        optional_group.add (comment_entry);

        var categories_row = new Adw.ComboRow () {
            title = _("Categories"),
            subtitle = _("Categories applicable to the app. (You can select more than one.)")
        };
        optional_group.add (categories_row);

        /*
         * Content part - Advanced Entries
         */
        var advanced_group = new Adw.PreferencesGroup () {
            title = _("Advanced Configurations"),
            description = _("You can create most app entries just by filling in the sections above. However, some apps may require the advanced configuration options below.")
        };

        var startup_wm_class_entry = new Adw.EntryRow () {
            title = _("Startup WM Class")
        };
        advanced_group.add (startup_wm_class_entry);

        var terminal_row = new Adw.SwitchRow () {
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
        var edit_page = new Gtk.ScrolledWindow () {
            child = clamp,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            hexpand = true
        };

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.set_content (edit_page);

        child = toolbar_view;
        // TODO Change title for new file and use file name
        title = _("Edit Entry");

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

                    exec_entry.text = file.get_path ();
                } catch (Error e) {
                    warning ("Failed to select executable file: %s", e.message);
                }
            });
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

                    icon_entry.text = file.get_path ();
                } catch (Error e) {
                    warning ("Failed to select icon file: %s", e.message);
                }
            });
        });

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
}
