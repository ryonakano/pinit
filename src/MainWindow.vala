/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private FilesView files_view;
    private EditView edit_view;
    private Adw.Leaflet leaflet;

    private enum Views {
        FILES_VIEW,
        EDIT_VIEW;
    }

    public MainWindow () {
        Object (
            title: Constants.APP_NAME
        );
    }

    construct {
        files_view = new FilesView (this);
        edit_view = new EditView (this);

        leaflet = new Adw.Leaflet () {
            can_navigate_back = true,
            transition_type = Adw.LeafletTransitionType.SLIDE
        };
        leaflet.notify["folded"].connect (() => {
            set_header_buttons_form ();
        });
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
        set_header_buttons_form ();
        set_visible_view ();

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.q) {
                close_request ();
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
            edit_view.hide_all ();
            files_view.update_list ();
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

            destroy ();
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

    // Show or hide the close button, maximize button, etc. depending on if the leaflet is folded
    private void set_header_buttons_form () {
        edit_view.set_header_buttons_form (leaflet.folded);
        // We can use the end title buttons in the edit view when the leaflet is folded
        files_view.headerbar.show_end_title_buttons = leaflet.folded;
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
        var last_edited_file = DesktopFileOperator.get_default ().get_unsaved_file ();
        if (last_view == Views.FILES_VIEW || last_edited_file == null) {
            show_files_view ();
        } else {
            show_edit_view (last_edited_file);
        }
    }

    private void save_window_size () {
        Application.settings.set ("window-size", "(ii)", default_width, default_height);
    }
}
