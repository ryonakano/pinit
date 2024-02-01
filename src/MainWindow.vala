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
    private Adw.NavigationSplitView leaflet;

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

        width_request = 450;
        height_request = 400;

        /*
         * The two views are switched/holded using Leaflet
         */
        files_view = new FilesView (this);
        edit_view = new EditView (this);

        leaflet = new Adw.NavigationSplitView () {
            sidebar = files_view,
            content = edit_view
        };

        var breakpoint = new Adw.Breakpoint (
            new Adw.BreakpointCondition.length (Adw.BreakpointConditionLengthType.MAX_WIDTH, 800, Adw.LengthUnit.SP)
        );
        var val = Value (typeof (bool));
        val.set_boolean (true);
        breakpoint.add_setter (leaflet, "collapsed", val);
        add_breakpoint (breakpoint);

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

        edit_view.file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (updated_toast);
        });

        files_view.create_new.connect (() => {
            on_new_activate ();
        });

        files_view.file_deleted.connect (() => {
            edit_view.hide_all ();
            files_view.update_list ();
            overlay.add_toast (deleted_toast);
        });

        close_request.connect (() => {
            prep_destroy ();
            destroy ();
        });
    }

    public void prep_destroy () {
        unowned Views visible_view = get_visible_view ();

        Application.settings.set_enum ("last-view", (int) visible_view);

        // TODO Drop backup function
        /*
        if (visible_view == Views.EDIT_VIEW) {
            if (edit_view.is_unsaved) {
                // If there are unsaved work, save it as a backup
                edit_view.save_file (true);
            } else {
                // If there are no unsaved work, delete the backup (if exists)
                DesktopFileOperator.get_default ().delete_backup ();
            }
        }
        */
    }

    public void show_files_view () {
        files_view.update_list ();
        leaflet.show_content = false;
    }

    public void show_edit_view (DesktopFile desktop_file) {
        edit_view.set_desktop_file (desktop_file);
        leaflet.show_content = true;
    }

    private Views get_visible_view () {
        if (!leaflet.show_content) {
            return Views.FILES_VIEW;
        } else {
            return Views.EDIT_VIEW;
        }
    }

    private void set_visible_view () {
        /*
        unowned var last_view = (Views) Application.settings.get_enum ("last-view");
        var last_edited_file = DesktopFileOperator.get_default ().get_unsaved_file ();

        if (last_view == Views.FILES_VIEW || last_edited_file == null) {
            show_files_view ();
        } else {
            // If there were unsaved work in the last session, restore it too.
            show_edit_view (last_edited_file);
        }
        */
    }

    private void on_new_activate () {
        var file = new DesktopFile ();

        try {
            file.save_file ();
        } catch (FileError e) {
            warning (e.message);
        }

        show_edit_view (file);
        files_view.update_list ();
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
            comments = _("Pin portable apps to the launcher"),
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
