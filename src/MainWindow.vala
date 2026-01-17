/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The window of the application.
 *
 * It contains a ``Adw.NavigationSplitView`` as a view which has a {@link View.FilesView} and
 * {@link View.EditView} inside.
 *
 * It also has a instance of {@link Model.DesktopFileModel} and calls {@link Model.DesktopFileModel.load} when
 * constructed. If the call succeeded, it calls {@link View.FilesView.set_list_data} to reflect
 * load result.<<BR>>
 * Otherwise, it shows a dialog to tell the user about the failure.
 */
public class MainWindow : Adw.ApplicationWindow {
    private const ActionEntry[] ACTION_ENTRIES = {
        { "new", on_new_activate },
    };

    private View.FilesView files_view;
    private View.EditView edit_view;
    private Adw.NavigationSplitView split_view;

    private Model.DesktopFileModel model;

    public MainWindow () {
    }

    construct {
        // Distinct development build visually
        if (".Devel" in Config.APP_ID) {
            add_css_class ("devel");
        }

        add_action_entries (ACTION_ENTRIES, this);

        width_request = 450;
        height_request = 400;
        title = Define.APP_NAME;

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
        breakpoint.add_setter (split_view, "collapsed", true);
        add_breakpoint (breakpoint);

        var overlay = new Adw.ToastOverlay () {
            child = split_view
        };

        content = overlay;

        files_view.delete_activated.connect ((file) => {
            edit_view.hide_all ();

            bool ret = model.delete_file (file);
            if (!ret) {
                var error_dialog = new Adw.AlertDialog (
                    _("Failed to Delete Entry of “%s”").printf (file.value_name),
                    _("There was an error while removing the app entry.")
                );

                error_dialog.add_response (Define.DialogResponse.CLOSE, _("_Close"));

                error_dialog.default_response = Define.DialogResponse.CLOSE;
                error_dialog.close_response = Define.DialogResponse.CLOSE;

                error_dialog.present ((Adw.ApplicationWindow) get_root ());
                return;
            }

            show_files_view ();

            var deleted_toast = new Adw.Toast (_("Entry deleted.")) {
                timeout = 5
            };
            overlay.add_toast (deleted_toast);
        });

        files_view.selected.connect ((entry) => {
            show_edit_view (entry);
        });

        edit_view.saved.connect (() => {
            files_view.set_list_data (model.files_list);

            var updated_toast = new Adw.Toast (_("Entry updated.")) {
                timeout = 5
            };
            overlay.add_toast (updated_toast);
        });

        close_request.connect (() => {
            bool can_destroy = check_destroy ();
            if (can_destroy) {
                return Gdk.EVENT_PROPAGATE;
            }

            return Gdk.EVENT_STOP;
        });
    }

    /**
     * The callback when loading the list of desktop files failed.
     *
     * Tell the user the failure through a dialog.
     */
    private void on_load_failure () {
        var error_dialog = new Adw.AlertDialog (
            _("Failed to Load Entries"),
            _("There was an error while loading app entries.")
        );
        error_dialog.add_response (Define.DialogResponse.CLOSE, _("_Close"));
        error_dialog.default_response = Define.DialogResponse.CLOSE;
        error_dialog.close_response = Define.DialogResponse.CLOSE;
        error_dialog.present (this);
    }

    /**
     * The callback when loading the list of desktop files succeeded.
     */
    private void on_load_success () {
        files_view.set_list_data (model.files_list);
    }

    /**
     * Check if we can quit the app immediately.
     *
     * If we have unsaved changes and can't, confirm interactivelly by presenting a dialog.
     *
     * @return true if we can quit the app, false otherwise.
     */
    public bool check_destroy () {
        if (!model.has_unsaved_changes ()) {
            return true;
        }

        var unsaved_dialog = new Adw.AlertDialog (
            _("Save Changes?"),
            _("Open entries contain unsaved changes. Changes which are not saved will be permanently lost.")
        );
        unsaved_dialog.add_css_class ("save-changes");
        unsaved_dialog.add_responses (
            Define.DialogResponse.CANCEL, _("_Cancel"),
            Define.DialogResponse.DISCARD, _("_Discard"),
            Define.DialogResponse.SAVE, _("_Save")
        );
        unsaved_dialog.set_response_appearance (Define.DialogResponse.DISCARD, Adw.ResponseAppearance.DESTRUCTIVE);
        unsaved_dialog.set_response_appearance (Define.DialogResponse.SAVE, Adw.ResponseAppearance.SUGGESTED);
        unsaved_dialog.close_response = Define.DialogResponse.CANCEL;

        string unsaved_dialog_resp = Define.DialogResponse.CANCEL;
        var resp_wait_loop = new MainLoop ();
        unsaved_dialog.response.connect ((response) => {
            unsaved_dialog_resp = response;
            resp_wait_loop.quit ();
        });

        // Show the dialog and wait for its response
        unsaved_dialog.present (this);
        resp_wait_loop.run ();

        switch (unsaved_dialog_resp) {
            case Define.DialogResponse.CANCEL:
                return false;
            case Define.DialogResponse.SAVE:
                edit_view.save_file ();
                break;
            case Define.DialogResponse.DISCARD:
                break;
            default:
                warning ("Unexpected response from unsaved dialog: %s", unsaved_dialog_resp);
                break;
        }

        unsaved_dialog.destroy ();
        return true;
    }

    /**
     * Refresh and show the file list.
     */
    public void show_files_view () {
        files_view.set_list_data (model.files_list);
        split_view.show_content = false;
    }

    /**
     * Start editing the given {@link Model.DesktopFile}.
     *
     * @param file      the {@link Model.DesktopFile} to edit
     */
    public void show_edit_view (Model.DesktopFile file) {
        edit_view.load_file (file);
        split_view.show_content = true;
    }

    /**
     * The callback for new file.
     *
     * Create a new DesktopFile and start editing it.
     */
    private void on_new_activate () {
        Model.DesktopFile file = model.create_file ();

        files_view.set_list_data (model.files_list);
        show_edit_view (file);
    }
}
