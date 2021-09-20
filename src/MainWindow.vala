/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class MainWindow : Gtk.ApplicationWindow {

    public MainWindow () {
        Object (
            resizable: false,
            default_width: 400
        );
    }

    construct {
        var main_grid = new MainGrid (this);
        add (main_grid);

        var open_image = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_image, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Open an existing desktop file"))
        };

        var header_bar = new Gtk.HeaderBar () {
            title = _("Untitled desktop file"),
            show_close_button = true,
            has_subtitle = false,
        };
        header_bar.pack_start (open_button);

        unowned var header_bar_style = header_bar.get_style_context ();
        header_bar_style.add_class (Gtk.STYLE_CLASS_FLAT);
        header_bar_style.add_class ("default-decoration");

        set_titlebar (header_bar);
        show_all ();

        open_button.clicked.connect (() => {
            var filefilter = new Gtk.FileFilter ();
            filefilter.add_mime_type ("application/x-desktop");

            var filechooser = new Gtk.FileChooserNative (_("Open a desktop file"), this, Gtk.FileChooserAction.OPEN, _("Open"), _("Cancel")) {
                local_only = true,
                filter = filefilter
            };
            filechooser.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    var desktop_file = DesktopFileOperator.get_default ().load_from_file (filechooser.get_filename ());
                    main_grid.set_desktop_file (desktop_file);
                }
            });
            filechooser.show ();
        });

        DesktopFileOperator.get_default ().notify["last-edited"].connect (() => {
            if (DesktopFileOperator.get_default ().last_edited != null) {
                header_bar.title = _("Edit “%s”").printf (DesktopFileOperator.get_default ().last_edited.app_name);
            }
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
