/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    /*
     * MainWindow, the window designated for the app.
     */

    private FilesView files_view;
    private EditView edit_view;
    private Adw.Leaflet leaflet;

    private enum Views {
        FILES_VIEW,
        EDIT_VIEW;
    }

    public MainWindow () {
        Object (
            // On Pantheon, the app name "Pin It!" is shown in Multitasking View by setting this
            title: Constants.APP_NAME
        );
    }

    construct {
        /*
         * The two views are switched/holded using Leaflet
         */
        files_view = new FilesView (this);
        edit_view = new EditView (this);

        leaflet = new Adw.Leaflet () {
            can_navigate_back = true,
            transition_type = Adw.LeafletTransitionType.SLIDE
        };
        // Set button forms when the leaflet gets holded/unfolded.
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

        /*
         * Set button forms depending on whether the leaflet is holded.
         * Set the visible view depending on the last saved state of the app.
         */
        set_header_buttons_form ();
        set_visible_view ();

        var event_controller = new Gtk.EventControllerKey ();
        event_controller.key_pressed.connect ((keyval, keycode, state) => {
            // Ctrl + Q: Save the last state and quit the app
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.q) {
                close_request ();
            }

            // Ctrl + N: Create the new blank desktop file
            if (Gdk.ModifierType.CONTROL_MASK in state && keyval == Gdk.Key.n) {
                show_edit_view (DesktopFileOperator.get_default ().create_new ());
            }

            return false;
        });
        /*
         * Gtk.Window inherits Gtk.Widget and Gtk.ShortcutManager
         * and both of them overloads add_controller methods.
         * So we need explicitly call the one in Gtk.Widget by casting.
         */
        ((Gtk.Widget) this).add_controller (event_controller);

        // When the desktop file updated, go back to the files list and show the toast "Updated entry."
        edit_view.file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (updated_toast);
        });

        // When the desktop file deleted, clear the edit view, update the files list, and show the toast "Deleted entry."
        files_view.file_deleted.connect (() => {
            edit_view.hide_all ();
            files_view.update_list ();
            overlay.add_toast (deleted_toast);
        });

        /*
         * Executed when the app window requested to closed,
         * e.g. when pressed Ctrl + Q or clicked the close button.
         */
        close_request.connect (() => {
            unowned Views visible_view = get_visible_view ();

            // Remember the currently open view
            Application.settings.set_enum ("last-view", (int) visible_view);

            if (visible_view == Views.EDIT_VIEW) {
                if (edit_view.is_unsaved) {
                    // If there are unsaved work, save it as a backup
                    edit_view.save_file (true);
                } else {
                    // If there are no unsaved work, delete the backup (if exists)
                    DesktopFileOperator.get_default ().delete_backup ();
                }
            }

            destroy ();
        });
    }

    // Show or hide the close button, maximize button, etc. depending on if the leaflet is folded
    private void set_header_buttons_form () {
        edit_view.set_header_buttons_form (leaflet.folded);
        files_view.headerbar.show_end_title_buttons = leaflet.folded;
    }

    /*
     * Update the files list and show the files view
     */
    public void show_files_view () {
        files_view.update_list ();
        leaflet.visible_child = files_view;
    }

    /*
     * Show the edit view with entries, buttons, etc filled
     * with the content in the specified desktop file,
     */
    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        leaflet.visible_child = edit_view;
    }

    /*
     * Returns which view is open now in the Views enum type.
     */
    private Views get_visible_view () {
        if (leaflet.visible_child == files_view) {
            return Views.FILES_VIEW;
        } else {
            return Views.EDIT_VIEW;
        }
    }

    /*
     * Get the last opened view and show it.
     * If there were unsaved work in the last session, restore it too.
     */
    private void set_visible_view () {
        unowned var last_view = (Views) Application.settings.get_enum ("last-view");
        var last_edited_file = DesktopFileOperator.get_default ().get_unsaved_file ();

        if (last_view == Views.FILES_VIEW || last_edited_file == null) {
            show_files_view ();
        } else {
            show_edit_view (last_edited_file);
        }
    }
}
