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

        edit_view.file_updated.connect (() => {
            show_files_view ();
            overlay.add_toast (updated_toast);
        });

        files_view.create_new.connect (() => {
            on_new_activate ();
        });

        files_view.file_deleted.connect ((is_success) => {
            edit_view.hide_all ();
            files_view.update_list ();

            if (is_success) {
                overlay.add_toast (deleted_toast);
            }
        });

        close_request.connect (() => {
            prep_destroy ();
            return Gdk.EVENT_STOP;
        });
    }

    public void prep_destroy () {
        if (DesktopFileOperator.get_default ().desktop_file == null
            || !DesktopFileOperator.get_default ().desktop_file.is_updated) {
            destroy ();
        }

        var unsaved_dialog = new Adw.MessageDialog (this, _("Save Changes?"),
                                                    _("Open entries contain unsaved changes. Changes which are not saved will be permanently lost."));
        unsaved_dialog.add_css_class ("save-changes");
        unsaved_dialog.add_responses (DialogResponse.CANCEL, _("_Cancel"),
                                      DialogResponse.DISCARD, _("_Discard"),
                                      DialogResponse.SAVE, _("_Save"));
        unsaved_dialog.set_response_appearance (DialogResponse.DISCARD, Adw.ResponseAppearance.DESTRUCTIVE);
        unsaved_dialog.set_response_appearance (DialogResponse.SAVE, Adw.ResponseAppearance.SUGGESTED);
        unsaved_dialog.response.connect ((response) => {
            if (response == DialogResponse.CANCEL) {
                return;
            }

            if (response == DialogResponse.SAVE) {
                edit_view.save_file ();
            }

            unsaved_dialog.destroy ();
            destroy ();
        });

        unsaved_dialog.present ();
    }

    public void show_files_view () {
        files_view.update_list ();
        leaflet.show_content = false;
    }

    public void show_edit_view () {
        edit_view.load_file ();
        leaflet.show_content = true;
    }

    private void on_new_activate () {
        unowned var operator = DesktopFileOperator.get_default ();

        string filename = "pinit-" + Uuid.string_random ();
        string path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications",
                                            filename + DesktopFileOperator.DESKTOP_SUFFIX);

        operator.desktop_file = new DesktopFile (path);

        try {
            operator.desktop_file.save_file ();
        } catch (FileError e) {
            warning (e.message);
        }

        show_edit_view ();
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
