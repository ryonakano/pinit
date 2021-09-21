/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class MainWindow : Gtk.ApplicationWindow {
    private EditView edit_view;
    private Gtk.Stack stack;
    private Gtk.HeaderBar header_bar;

    public MainWindow () {
        Object (
            resizable: false,
            default_width: 400
        );
    }

    construct {
        var welcome_view = new WelcomeView (this);
        edit_view = new EditView (this);

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT
        };
        stack.add_named (welcome_view, "welcome_view");
        stack.add_named (edit_view, "edit_view");
        add (stack);

        var open_image = new Gtk.Image.from_icon_name ("document-open", Gtk.IconSize.SMALL_TOOLBAR);
        var open_button = new Gtk.ToolButton (open_image, null) {
            tooltip_markup = Granite.markup_accel_tooltip ({"<Ctrl>O"}, _("Open an existing desktop file"))
        };

        header_bar = new Gtk.HeaderBar () {
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

        open_button.clicked.connect (() => {
            open_file ();
        });

        DesktopFileOperator.get_default ().notify["last-edited"].connect (() => {
            update_header_label ();
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

    public void open_file () {
        var filefilter = new Gtk.FileFilter ();
        filefilter.add_mime_type ("application/x-desktop");

        var filechooser = new Gtk.FileChooserNative (_("Open a desktop file"), this, Gtk.FileChooserAction.OPEN, _("Open"), _("Cancel")) {
            local_only = true,
            filter = filefilter
        };
        filechooser.response.connect ((response_id) => {
            if (response_id == Gtk.ResponseType.ACCEPT) {
                var desktop_file = DesktopFileOperator.get_default ().load_from_file (filechooser.get_filename ());
                edit_view.set_desktop_file (desktop_file);
                set_visible_view ("edit_view");
            }
        });
        filechooser.show ();
    }

    public void set_visible_view (string view_name) {
        if (view_name == "edit_view") {
            update_header_label ();
        }

        stack.visible_child_name = view_name;
    }

    private void update_header_label () {
        if (DesktopFileOperator.get_default ().last_edited != null) {
            header_bar.title = _("Editing “%s”").printf (DesktopFileOperator.get_default ().last_edited.id + ".desktop");
        } else {
            header_bar.title = _("Untitled desktop file");
        }
    }
}
