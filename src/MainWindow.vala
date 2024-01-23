/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class MainWindow : Adw.ApplicationWindow {
    private const ActionEntry[] ACTION_ENTRIES = {
        { "about", on_about_activate },
        { "new", on_new_activate },
    };

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
        add_action_entries (ACTION_ENTRIES, this);

        /*
         * The two views are switched/holded using Leaflet
         */
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

        edit_view.file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (updated_toast);
        });

        files_view.file_deleted.connect (() => {
            edit_view.hide_all ();
            files_view.update_list ();
            overlay.add_toast (deleted_toast);
        });

        close_request.connect (() => {
            unowned Views visible_view = get_visible_view ();

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

    private void set_header_buttons_form () {
        edit_view.set_header_buttons_form (leaflet.folded);
        files_view.set_header_buttons_form (leaflet.folded);
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
            // If there were unsaved work in the last session, restore it too.
            show_edit_view (last_edited_file);
        }
    }

    private void on_new_activate () {
        show_edit_view (DesktopFileOperator.get_default ().create_new ());
    }

    private void on_about_activate () {
        const string[] DEVELOPERS = {
            "Ryo Nakano https://github.com/ryonakano",
            "Jeyson Flores https://github.com/JeysonFlores",
        };
        const string[] ARTISTS = {
            "hanaral https://github.com/hanaral",
        };

        var about_window = new Adw.AboutWindow () {
            transient_for = this,
            modal = true,
            application_icon = Constants.PROJECT_NAME,
            application_name = Constants.APP_NAME,
            version = Constants.PROJECT_VERSION,
            comments = _("Pin shortcuts for your favorite portable apps to your app launcher"),
            website = "https://github.com/ryonakano/pinit",
            support_url = "https://github.com/ryonakano/pinit/discussions",
            issue_url = "https://github.com/ryonakano/pinit/issues",
            copyright = "© 2021-2024 Ryo Nakano",
            license_type = Gtk.License.GPL_3_0,
            developer_name = "Ryo Nakano",
            developers = DEVELOPERS,
            artists = ARTISTS,
            ///TRANSLATORS: Replace with your name; don't translate literally
            translator_credits = _("translator-credits")
        };

        about_window.present ();
    }
}
