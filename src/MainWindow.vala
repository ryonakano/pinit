/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private FilesView files_view;
    private EditView edit_view;
    private Adw.Leaflet leaflet;
    private Gtk.Button create_new_button;
    private Gtk.HeaderBar headerbar;

    private enum Views {
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
        Gtk.StyleContext.add_provider_for_display (Gdk.Display.get_default (),
                                                    cssprovider,
                                                    Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        files_view = new FilesView ();
        edit_view = new EditView ();

        leaflet = new Adw.Leaflet () {
            can_navigate_back = true,
            transition_type = Adw.LeafletTransitionType.SLIDE
        };
        leaflet.append (files_view);
        leaflet.append (edit_view);

        var overlay = new Adw.ToastOverlay () {
            child = leaflet
        };

        var toast = new Adw.Toast (_("Saved changes!")) {
            timeout = 5
        };

        create_new_button = new Gtk.Button.from_icon_name ("document-new-symbolic") {
            tooltip_text = _("Create a new app entry")
        };

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        //  preferences_box.append (new StyleSwitcher ());

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("")
        };
        headerbar.pack_start (create_new_button);
        headerbar.pack_end (preferences_button);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.append (headerbar);
        main_box.append (overlay);

        content = main_box;
        set_visible_view ();

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.q) {
                destroy ();
            }

            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.n) {
                show_edit_view (DesktopFileOperator.get_default ().create_new ());
            }

            return false;
        });
        ((Gtk.Widget) this).add_controller (event_controller);

        create_new_button.clicked.connect (() => {
            show_edit_view (DesktopFileOperator.get_default ().create_new ());
        });

        DesktopFileOperator.get_default ().file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (toast);
        });

        close_request.connect (() => {
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

    public void show_files_view () {
        files_view.update_list ();
        ((Gtk.Label) headerbar.title_widget).label = _("Edit Entry");
        create_new_button.sensitive = true;
        leaflet.reorder_child_after (files_view, edit_view);
        leaflet.visible_child = files_view;
    }

    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        set_header_file_info (desktop_file);
        create_new_button.sensitive = false;
        leaflet.reorder_child_after (edit_view, files_view);
        leaflet.visible_child = edit_view;
    }

    private void set_header_file_info (DesktopFile desktop_file) {
        if (desktop_file.file_name != "") {
            if (desktop_file.app_name != "") {
                ((Gtk.Label) headerbar.title_widget).label = _("Editing “%s”").printf (desktop_file.app_name);
            } else {
                ((Gtk.Label) headerbar.title_widget).label = _("Editing Entry");
            }
        } else {
            ((Gtk.Label) headerbar.title_widget).label = _("New Entry");
        }
    }

    private Views get_visible_view () {
        if (leaflet.visible_child == files_view) {
            return Views.FILES_VIEW;
        } else {
            return Views.EDIT_VIEW;
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
            default:
                warning ("Unexpected view %s, falling back to the files view".printf (last_view.to_string ()));
                show_files_view ();
                break;
        }
    }

    private void save_window_size () {
        Application.settings.set ("window-size", "(ii)", default_width, default_height);
    }
}
