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
        var name_label = new Granite.HeaderLabel (_("App Name"));
        var name_desc_label = new DimLabel (_("This name is shown in Applications Menu or Dock."));
        var name_entry = new Entry ();

        var comment_label = new Granite.HeaderLabel (_("Comment"));
        var comment_desc_label = new DimLabel (_("A tooltip text to describe what the app helps you to do."));
        var comment_entry = new Entry ();

        var exec_label = new Granite.HeaderLabel (_("Exec File"));
        var exec_desc_label = new DimLabel (_("Location of the app itself."));
        var exec_chooser = new Gtk.FileChooserButton (
            _("Choose an exec file"),
            Gtk.FileChooserAction.SELECT_FOLDER
        ) {
            halign = Gtk.Align.START
        };

        var icon_label = new Granite.HeaderLabel (_("Icon File"));
        var icon_desc_label = new DimLabel (_("Location of an icon for the app."));
        var icon_chooser = new Gtk.FileChooserButton (
            _("Choose an icon file"),
            Gtk.FileChooserAction.SELECT_FOLDER
        ) {
            halign = Gtk.Align.START
        };

        var categories_label = new Granite.HeaderLabel (_("App Category"));
        var categories_desc_label = new DimLabel (_("Type of the app."));
        var categories_entry = new Entry ();

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
            margin_top = 24
        };
        action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var main_grid = new Gtk.Grid () {
            margin = 24,
            margin_top = 12
        };
        main_grid.attach (name_label, 0, 0, 1, 1);
        main_grid.attach (name_desc_label, 0, 1, 1, 1);
        main_grid.attach (name_entry, 0, 2, 1, 1);
        main_grid.attach (comment_label, 0, 3, 1, 1);
        main_grid.attach (comment_desc_label, 0, 4, 1, 1);
        main_grid.attach (comment_entry, 0, 5, 1, 1);
        main_grid.attach (exec_label, 0, 6, 1, 1);
        main_grid.attach (exec_desc_label, 0, 7, 1, 1);
        main_grid.attach (exec_chooser, 0, 8, 1, 1);
        main_grid.attach (icon_label, 0, 9, 1, 1);
        main_grid.attach (icon_desc_label, 0, 10, 1, 1);
        main_grid.attach (icon_chooser, 0, 11, 1, 1);
        main_grid.attach (categories_label, 0, 12, 1, 1);
        main_grid.attach (categories_desc_label, 0, 13, 1, 1);
        main_grid.attach (categories_entry, 0, 14, 1, 1);
        main_grid.attach (no_display_checkbox, 0, 15, 1, 1);
        main_grid.attach (no_display_desc_label, 0, 16, 1, 1);
        main_grid.attach (terminal_checkbox, 0, 17, 1, 1);
        main_grid.attach (terminal_desc_label, 0, 18, 1, 1);
        main_grid.attach (action_button, 0, 19, 1, 1);

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
