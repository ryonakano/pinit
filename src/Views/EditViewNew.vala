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

        var file_name_entry = new Adw.EntryRow () {
            title = _("File Name")
        };
        required_group.add (file_name_entry);

        var name_entry = new Adw.EntryRow () {
            title = _("App Name")
        };
        required_group.add (name_entry);

        var exec_entry = new Adw.EntryRow () {
            title = _("Exec File")
        };
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
    }

}
