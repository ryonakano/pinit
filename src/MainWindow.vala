/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The window of the application.
 *
 * It contains a ``Adw.NavigationSplitView`` as a view which has a {@link View.FilesView} and
 * {@link View.EditView} inside.
 *
 * It also has a instance of {@link Model.DesktopFileModel} and calls {@link Model.DesktopFileModel.load} when:
 *
 *  * constructed
 *  * {@link View.FilesView.deleted} is emitted
 *  * {@link View.EditView.saved} is emitted
 *  * the action ``win.new`` is called
 *
 * If {@link Model.DesktopFileModel.load} succeeded, this calls {@link View.FilesView.set_list_data} to reflect
 * load result.<<BR>>
 * Otherwise, this shows a dialog to tell the user about the failure.
 */
public class MainWindow : Adw.ApplicationWindow {
    private const ActionEntry[] ACTION_ENTRIES = {
        { "about", on_about_activate },
        { "new", on_new_activate },
    };

    private View.FilesView files_view;
    private View.EditView edit_view;
    private Adw.NavigationSplitView split_view;

    private Model.DesktopFileModel model;
    private Model.DesktopFile desktop_file;
    private Model.DesktopFile backup_desktop_file;

    public MainWindow () {
        Object (
            // On Pantheon, the app name "Pin It!" is shown in Multitasking View by setting this
            title: Define.APP_NAME
        );
    }

    construct {
        // Distinct development build visually
        if (".Devel" in Config.APP_ID) {
            add_css_class ("devel");
        }

        add_action_entries (ACTION_ENTRIES, this);

        width_request = 450;
        height_request = 400;

        model = new Model.DesktopFileModel ();
        model.load_failure.connect (on_load_failure);
        model.load_success.connect (on_load_success);

        model.load.begin ();

        files_view = new View.FilesView ();
        edit_view = new View.EditView ();

        split_view = new Adw.NavigationSplitView () {
            sidebar = files_view,
            content = edit_view
        };

        var breakpoint = new Adw.Breakpoint (
            new Adw.BreakpointCondition.length (Adw.BreakpointConditionLengthType.MAX_WIDTH, 800, Adw.LengthUnit.SP)
        );
        var val = Value (typeof (bool));
        val.set_boolean (true);
        breakpoint.add_setter (split_view, "collapsed", val);
        add_breakpoint (breakpoint);

        var overlay = new Adw.ToastOverlay () {
            child = split_view
        };

        content = overlay;

        files_view.new_activated.connect (() => {
            on_new_activate ();
        });

        files_view.deleted.connect ((is_success) => {
            desktop_file = null;
            backup_desktop_file = null;
            edit_view.hide_all ();
            model.load.begin ();

            if (is_success) {
                var deleted_toast = new Adw.Toast (_("Entry deleted.")) {
                    timeout = 5
                };
                overlay.add_toast (deleted_toast);
            }
        });

        files_view.selected.connect ((entry) => {
            show_edit_view (entry);
        });

        edit_view.saved.connect (() => {
            desktop_file.copy_to (backup_desktop_file);
            model.load.begin ();

            var updated_toast = new Adw.Toast (_("Entry updated.")) {
                timeout = 5
            };
            overlay.add_toast (updated_toast);
        });

        close_request.connect (() => {
            prep_destroy ();
            return Gdk.EVENT_STOP;
        });
    }

    /**
     * The callback when loading the list of desktop files failed.
     *
     * Tell the user the failure through a dialog.
     */
    private void on_load_failure () {
        var error_dialog = new Adw.MessageDialog (this,
                                                  _("Failed to Load Entries"),
                                                  _("There was an error while loading app entries.")
        );
        error_dialog.add_response (Define.DialogResponse.CLOSE, _("_Close"));
        error_dialog.default_response = Define.DialogResponse.CLOSE;
        error_dialog.close_response = Define.DialogResponse.CLOSE;
        error_dialog.present ();
    }

    /**
     * The callback when loading the list of desktop files succeeded.
     */
    private void on_load_success () {
        files_view.set_list_data (model.files_list);
    }

    /**
     * Preprocess before destruction of this.
     *
     * Just destroy this if we never edited entries or no changes made for desktop files.
     * Otherwise, tell the user unsaved work through a dialog.
     */
    public void prep_destroy () {
        // Never edited entries
        if (desktop_file == null || backup_desktop_file == null) {
            destroy ();
            return;
        }

        // No changes made
        if (desktop_file.equals (backup_desktop_file)) {
            destroy ();
            return;
        }

        var unsaved_dialog = new Adw.MessageDialog (this, _("Save Changes?"),
                                                    _("Open entries contain unsaved changes. Changes which are not saved will be permanently lost."));
        unsaved_dialog.add_css_class ("save-changes");
        unsaved_dialog.add_responses (Define.DialogResponse.CANCEL, _("_Cancel"),
                                      Define.DialogResponse.DISCARD, _("_Discard"),
                                      Define.DialogResponse.SAVE, _("_Save"));
        unsaved_dialog.set_response_appearance (Define.DialogResponse.DISCARD, Adw.ResponseAppearance.DESTRUCTIVE);
        unsaved_dialog.set_response_appearance (Define.DialogResponse.SAVE, Adw.ResponseAppearance.SUGGESTED);
        unsaved_dialog.close_response = Define.DialogResponse.CANCEL;
        unsaved_dialog.response.connect ((response) => {
            if (response == Define.DialogResponse.CANCEL) {
                return;
            }

            if (response == Define.DialogResponse.SAVE) {
                edit_view.save_file ();
            }

            unsaved_dialog.destroy ();
            destroy ();
        });

        unsaved_dialog.present ();
    }

    /**
     * Reload and show the file list.
     */
    public void show_files_view () {
        model.load.begin ();
        split_view.show_content = false;
    }

    /**
     * Start editing the given {@link Model.DesktopFile}.
     *
     * It first backups the given {@link Model.DesktopFile} and then calls {@link View.EditView.load_file} to start
     * editing, so that the app can recognize unsaved changes before destruction.
     *
     * @param file The {@link Model.DesktopFile} to edit
     */
    public void show_edit_view (Model.DesktopFile file) {
        desktop_file = file;
        backup_desktop_file = new Model.DesktopFile (desktop_file.path);
        desktop_file.copy_to (backup_desktop_file);

        edit_view.load_file (desktop_file);
        split_view.show_content = true;
    }

    /**
     * The callback for new file.
     *
     * Create a new DesktopFile with random filename and start editing it.
     */
    private void on_new_activate () {
        string filename = Config.APP_ID + "." + Uuid.string_random ();
        string path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications",
                                            filename + Model.DesktopFile.DESKTOP_SUFFIX);

        var file = new Model.DesktopFile (path);

        bool ret = file.save_file ();
        if (!ret) {
            return;
        }

        model.load.begin ();
        show_edit_view (file);
    }

    /**
     * The callback for about window.
     */
    private void on_about_activate () {
        // List of code maintainers
        const string[] DEVELOPERS = {
            "Ryo Nakano https://github.com/ryonakano",
        };
        // List of icon authors
        const string[] ARTISTS = {
            "hanaral https://github.com/hanaral",
        };

        var about_window = new Adw.AboutWindow.from_appdata (
            "%s/%s.metainfo.xml".printf (Config.RESOURCE_PREFIX, Config.APP_ID),
            null
        ) {
            transient_for = this,
            modal = true,
            comments = _("Pin portable apps to the launcher"),
            copyright = "© 2021-2024 Ryo Nakano",
            developers = DEVELOPERS,
            artists = ARTISTS,
            ///TRANSLATORS: A newline-separated list of translators. Don't translate literally.
            ///You may add your name and your email address if you want, e.g.:
            ///John Doe <john-doe@example.com>
            translator_credits = _("translator-credits")
        };

        // Distinct development build visually
        if (".Devel" in Config.APP_ID) {
            about_window.add_css_class ("devel");
        }

        about_window.present ();
    }
}
