/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Gtk.ApplicationWindow {
    private uint configure_id;

    private WelcomeView welcome_view;
    private FilesView files_view;
    private EditView edit_view;
    private Adw.Leaflet leaflet;
    private Gtk.Button home_button;
    private Gtk.HeaderBar header_bar;

    private enum Views {
        WELCOME_VIEW,
        EDIT_VIEW,
        FILES_VIEW;
    }

    public MainWindow () {
        Object (
            title: "Pin It!"
        );
    }

    construct {
        var cssprovider = new Gtk.CssProvider ();
        cssprovider.load_from_resource ("/com/github/ryonakano/pinit/Application.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        if (Application.IS_ON_PANTHEON) {
            var extra_cssprovider = new Gtk.CssProvider ();
            extra_cssprovider.load_from_resource ("/com/github/ryonakano/pinit/Extra.css");
            Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                        extra_cssprovider,
                                                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
        }

        welcome_view = new WelcomeView ();
        files_view = new FilesView ();
        edit_view = new EditView ();

        leaflet = new Adw.Leaflet () {
            can_navigate_back = true,
            transition_type = Adw.LeafletTransitionType.SLIDE
        };
        leaflet.add (welcome_view);
        leaflet.add (files_view);
        leaflet.add (edit_view);

        var overlay = new Adw.ToastOverlay () {
            child = leaflet
        };

        var toast = new Adw.Toast (_("Saved changes!"));
        overlay.add_toast (toast);

        home_button = new Gtk.Button.from_icon_name (home_image) {
            //  tooltip_markup = Granite.markup_accel_tooltip ({"<Alt>Home"}, _("Create new or edit"))
        };

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        preferences_box.append (new StyleSwitcher ());

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("")
        };
        headerbar.pack_start (home_button);
        headerbar.pack_end (preferences_button);
        set_titlebar (headerbar);

        unowned var header_bar_style = header_bar.get_style_context ();
        header_bar_style.add_class (Gtk.STYLE_CLASS_FLAT);
        //  header_bar_style.add_class (Granite.STYLE_CLASS_DEFAULT_DECORATION);

        child = overlay;
        set_visible_view ();

        home_button.clicked.connect (() => {
            show_welcome_view ();
        });

        DesktopFileOperator.get_default ().file_updated.connect (() => {
            show_welcome_view ();
            toast.send_notification ();
        });

        key_press_event.connect ((key) => {
            if (Gdk.ModifierType.CONTROL_MASK in key.state && key.keyval == Gdk.Key.q) {
                destroy ();
            }

            if (Gdk.ModifierType.MOD1_MASK in key.state && key.keyval == Gdk.Key.Home) {
                show_welcome_view ();
            }

            return false;
        });

        destroy.connect (() => {
            unowned Views visible_view = get_visible_view ();
            Application.settings.set_enum ("last-view", (int) visible_view);
            if (visible_view == Views.EDIT_VIEW) {
                if (edit_view.is_unsaved) {
                    edit_view.save_file (true);
                } else {
                    DesktopFileOperator.get_default ().delete_backup ();
                }
            }
        });

        notify["default-width"].connect (() => {
            save_window_size ();
        });

        notify["default-height"].connect (() => {
            save_window_size ();
        });

        notify["maximized"].connect (() => {
            Application.settings.set_boolean ("window-maximized", maximized);
        });
    }

    public void show_welcome_view () {
        header_bar.title = "Pin It!";
        home_button.sensitive = false;
        leaflet.visible_child = welcome_view;
    }

    public void show_files_view () {
        files_view.update_list ();
        header_bar.title = _("Edit Entry");
        home_button.sensitive = true;
        leaflet.reorder_child_after (files_view, welcome_view);
        leaflet.visible_child = files_view;
    }

    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        set_header_file_info (desktop_file);
        home_button.sensitive = true;
        leaflet.reorder_child_after (edit_view, welcome_view);
        leaflet.visible_child = edit_view;
    }

    private void set_header_file_info (DesktopFile desktop_file) {
        if (desktop_file.file_name != "") {
            if (desktop_file.app_name != "") {
                header_bar.title = _("Editing “%s”").printf (desktop_file.app_name);
            } else {
                header_bar.title = _("Editing Entry");
            }
        } else {
            header_bar.title = _("New Entry");
        }
    }

    private Views get_visible_view () {
        if (leaflet.visible_child == files_view) {
            return Views.FILES_VIEW;
        } else if (leaflet.visible_child == edit_view) {
            return Views.EDIT_VIEW;
        } else {
            return Views.WELCOME_VIEW;
        }
    }

    private void set_visible_view () {
        unowned var last_view = (Views) Application.settings.get_enum ("last-view");
        switch (last_view) {
            case Views.FILES_VIEW:
                show_files_view ();
                break;
            case Views.EDIT_VIEW:
                show_edit_view (DesktopFileOperator.get_default ().get_unsaved_file () ?? DesktopFileOperator.get_default ().create_new ());
                break;
            case Views.WELCOME_VIEW:
            default:
                show_welcome_view ();
                break;
        }
    }

    private void save_window_size () {
        Application.settings.set ("window-size", "(ii)", default_width, default_height);
    }
}
