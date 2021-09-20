/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class MainWindow : Gtk.ApplicationWindow {

    public MainWindow () {
        Object (
            title: "Pin It!",
            resizable: false,
            default_width: 400
        );
    }

    construct {
        var id_label = new Granite.HeaderLabel (_("File Name"));
        var id_desc_label = new DimLabel (_("File name of the desktop file."));
        var id_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var id_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        id_grid.attach (id_label, 0, 0, 1, 1);
        id_grid.attach (id_desc_label, 0, 1, 1, 1);
        id_grid.attach (id_entry, 0, 2, 1, 1);

        var name_label = new Granite.HeaderLabel (_("App Name"));
        var name_desc_label = new DimLabel (_("This name is shown in Applications Menu or Dock."));
        var name_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var name_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        name_grid.attach (name_label, 0, 0, 1, 1);
        name_grid.attach (name_desc_label, 0, 1, 1, 1);
        name_grid.attach (name_entry, 0, 2, 1, 1);

        var comment_label = new Granite.HeaderLabel (_("Comment"));
        var comment_desc_label = new DimLabel (_("A tooltip text to describe what the app helps you to do."));
        var comment_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var comment_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        comment_grid.attach (comment_label, 0, 0, 1, 1);
        comment_grid.attach (comment_desc_label, 0, 1, 1, 1);
        comment_grid.attach (comment_entry, 0, 2, 1, 1);

        var exec_label = new Granite.HeaderLabel (_("Exec File"));
        var exec_desc_label = new DimLabel (_("Location of the app itself."));
        var exec_chooser = new Gtk.FileChooserButton (
            _("Choose an exec file"),
            Gtk.FileChooserAction.OPEN
        ) {
            halign = Gtk.Align.START
        };
        var exec_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        exec_grid.attach (exec_label, 0, 0, 1, 1);
        exec_grid.attach (exec_desc_label, 0, 1, 1, 1);
        exec_grid.attach (exec_chooser, 0, 2, 1, 1);

        var icon_label = new Granite.HeaderLabel (_("Icon File"));
        var icon_desc_label = new DimLabel (_("Location of an icon for the app."));
        var icon_chooser = new Gtk.FileChooserButton (
            _("Choose an icon file"),
            Gtk.FileChooserAction.OPEN
        ) {
            halign = Gtk.Align.START
        };
        var icon_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        icon_grid.attach (icon_label, 0, 0, 1, 1);
        icon_grid.attach (icon_desc_label, 0, 1, 1, 1);
        icon_grid.attach (icon_chooser, 0, 2, 1, 1);

        var categories_label = new Granite.HeaderLabel (_("App Categories"));
        var categories_desc_label = new DimLabel (_("Type of the app."));
        var categories_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var categories_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        categories_grid.attach (categories_label, 0, 0, 1, 1);
        categories_grid.attach (categories_desc_label, 0, 1, 1, 1);
        categories_grid.attach (categories_entry, 0, 2, 1, 1);

        var no_display_checkbox = new Gtk.CheckButton.with_label (_("No Display")) {
            margin_bottom = 6
        };
        var no_display_desc_label = new DimLabel (_("Whether to show the app entry in Application Menu.")) {
            margin_bottom = 12
        };

        var terminal_checkbox = new Gtk.CheckButton.with_label (_("Run in Terminal")) {
            margin_bottom = 6
        };
        var terminal_desc_label = new DimLabel (_("Check this in if you want to registar a CUI app."));

        var action_button = new Gtk.Button.with_label ("Pin It!") {
            margin_top = 24,
            sensitive = (id_entry.is_valid && name_entry.is_valid && comment_entry.is_valid && categories_entry.is_valid)
        };
        action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var main_grid = new Gtk.Grid () {
            margin = 24,
            margin_top = 12
        };
        main_grid.attach (id_grid, 0, 0, 1, 3);
        main_grid.attach (name_grid, 0, 3, 1, 3);
        main_grid.attach (comment_grid, 0, 6, 1, 3);
        main_grid.attach (exec_grid, 0, 9, 1, 3);
        main_grid.attach (icon_grid, 0, 12, 1, 3);
        main_grid.attach (categories_grid, 0, 15, 1, 3);
        main_grid.attach (no_display_checkbox, 0, 18, 1, 1);
        main_grid.attach (no_display_desc_label, 0, 19, 1, 1);
        main_grid.attach (terminal_checkbox, 0, 20, 1, 1);
        main_grid.attach (terminal_desc_label, 0, 21, 1, 1);
        main_grid.attach (action_button, 0, 22, 1, 1);

        add (main_grid);

        var open_image = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_image, null);
        open_button.tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Open an existing desktop file"));
        open_button.clicked.connect (() => {
            // Open existing .desktop file
        });

        var header_bar = new Gtk.HeaderBar () {
            title = "Pin It!",
            show_close_button = true,
            has_subtitle = false,
        };
        header_bar.pack_start (open_button);

        unowned var header_bar_style = header_bar.get_style_context ();
        header_bar_style.add_class (Gtk.STYLE_CLASS_FLAT);
        header_bar_style.add_class ("default-decoration");

        set_titlebar (header_bar);
        show_all ();

        action_button.clicked.connect (() => {
            var desktop_file = new DesktopFile (
                id_entry.text,
                name_entry.text,
                comment_entry.text,
                exec_chooser.get_filename (),
                icon_chooser.get_filename (),
                categories_entry.text,
                no_display_checkbox.active,
                terminal_checkbox.active
            );
            DesktopFileOperator.get_default ().write_to_file (desktop_file);
        });

        key_release_event.connect (() => {
            action_button.sensitive = (id_entry.is_valid && name_entry.is_valid && comment_entry.is_valid && categories_entry.is_valid);
            return false;
        });

        key_press_event.connect ((key) => {
            if (Gdk.ModifierType.CONTROL_MASK in key.state && key.keyval == Gdk.Key.q) {
                destroy ();
            }

            return false;
        });

        // Follow elementary OS-wide dark preference
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });
    }
}
