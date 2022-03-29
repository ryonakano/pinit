/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private FilesView files_view;
    private EditView edit_view;
    private Adw.Leaflet leaflet;

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

        files_view = new FilesView (this);
        edit_view = new EditView (this);

        leaflet = new Adw.Leaflet () {
            can_navigate_back = true,
            transition_type = Adw.LeafletTransitionType.SLIDE
        };
        leaflet.bind_property ("folded", files_view.headerbar, "show-end-title-buttons", GLib.BindingFlags.SYNC_CREATE);
        leaflet.bind_property ("folded", edit_view.back_button, "visible", GLib.BindingFlags.SYNC_CREATE);
        leaflet.append (files_view);
        leaflet.append (new Gtk.Separator (Gtk.Orientation.VERTICAL));
        leaflet.append (edit_view);

        var overlay = new Adw.ToastOverlay () {
            child = leaflet
        };

        var updated_toast = new Adw.Toast (_("Updated entry.")) {
            timeout = 5
        };

        var deleted_toast = new Adw.Toast (_("Deleted entry.")) {
            timeout = 5
        };

        content = overlay;
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

        DesktopFileOperator.get_default ().file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (updated_toast);
        });

        DesktopFileOperator.get_default ().file_deleted.connect (() => {
            overlay.add_toast (deleted_toast);
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
        leaflet.visible_child = files_view;
    }

    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        leaflet.visible_child = edit_view;
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
