/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class FilesView : Gtk.Box {
    /*
     * The view where you can select a desktop file to open and edit in the EditView.
     * If the `leaflet` in MainWindow isn't folded, this is shown in the left pane.
     * Otherwise it's shown when you save or cancel editing desktop files in FilesView.
     */

    public signal void file_deleted ();

    /*
     * Private properties and variables
     */
    public MainWindow window { private get; construct; }
    public Adw.HeaderBar headerbar { get; private set; }

    private Gtk.ListBox files_list;
    private Gtk.Stack stack;

    public FilesView (MainWindow window) {
        Object (window: window);
    }

    construct {
        // Headerbar part

        var create_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Create a new entry")
        };

        // Construct the settings menu
        var theme_submenu = new GLib.Menu ();
        theme_submenu.append (_("Light"), "app.style-light");
        theme_submenu.append (_("Dark"), "app.style-dark");
        theme_submenu.append (_("System"), "app.style-system");

        var menu = new GLib.Menu ();
        menu.append_submenu (_("Style"), theme_submenu);

        // elementary prefers AppData for showcasing the app info, so don't construct useless AboutDialog on Pantheon
        if (!Application.IS_ON_PANTHEON) {
            ///TRANSLATORS: %s will be replaced by the app name (Pin It!)
            menu.append (_("About %s…").printf (Constants.APP_NAME), "app.about");
        }

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            menu_model = menu
        };

        headerbar = new Adw.HeaderBar () {
            title_widget = new Gtk.Label (Constants.APP_NAME)
        };
        headerbar.pack_start (create_button);
        headerbar.pack_end (preferences_button);

        // Main part

        // FilesListPage: The page to list available desktop files.
        files_list = new Gtk.ListBox ();

        // Pack into a scrolled window in case there are many desktop files in the files list
        var files_list_page = new Gtk.ScrolledWindow () {
            child = files_list,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            hexpand = true
        };

        // NoFilesPage: Shown when no desktop files available.
        var no_files_page = new Adw.StatusPage () {
            title = _("No valid app entries found"),
            description = _("If you've never created one, click the + button on the top."),
            icon_name = "dialog-information",
            vexpand = true,
            hexpand = true
        };

        stack = new Gtk.Stack ();
        stack.add_named (files_list_page, "files_list_page");
        stack.add_named (no_files_page, "no_files_page");

        orientation = Gtk.Orientation.VERTICAL;
        append (headerbar);
        append (stack);

        update_list ();

        create_button.clicked.connect (() => {
            window.show_edit_view (DesktopFileOperator.get_default ().create_new ());
        });
    }

    /*
     * Update the files list.
     */
    public void update_list () {
        // Clear all of the currently added entries
        for (
            var child = (Gtk.ListBoxRow) files_list.get_last_child ();
                child != null;
                child = (Gtk.ListBoxRow) files_list.get_last_child ()
        ) {
            files_list.remove (child);
        }

        var files = DesktopFileOperator.get_default ().files;

        // Create a listbox per each entry
        for (int i = 0; i < files.size; i++) {
            var file = files.get (i);

            // Fallback icon
            var app_icon = new Gtk.Image.from_icon_name ("image-missing");
            if (file.icon_file != "") {
                // Check if icon_file represents a path to the icon or just the alias
                if (File.new_for_path (file.icon_file).query_exists ()) {
                    app_icon.file = file.icon_file;
                } else {
                    app_icon.icon_name = file.icon_file;
                }
            }

            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
                tooltip_text = _("Delete…"),
                valign = Gtk.Align.CENTER
            };
            delete_button.clicked.connect (() => {
                var delete_dialog = new Adw.MessageDialog (
                    window,
                    _("Are you sure you want to delete “%s”?").printf (file.app_name),
                    _("This removes the app from the launcher.")
                );
                delete_dialog.add_response (DialogResponse.CANCEL, _("Cancel"));
                delete_dialog.add_response (DialogResponse.OK, _("Delete"));
                delete_dialog.set_response_appearance (DialogResponse.OK, Adw.ResponseAppearance.DESTRUCTIVE);
                delete_dialog.default_response = DialogResponse.CANCEL;
                delete_dialog.close_response = DialogResponse.CANCEL;
                delete_dialog.response.connect ((response_id) => {
                    if (response_id == DialogResponse.OK) {
                        try {
                            DesktopFileOperator.get_default ().delete_file (file);
                            file_deleted ();
                        } catch (Error e) {
                            var error_dialog = new Adw.MessageDialog (
                                window,
                                _("Could not delete file “%s”").printf (file.app_name),
                                e.message
                            );
                            error_dialog.add_response (DialogResponse.CLOSE, _("Close"));
                            error_dialog.default_response = DialogResponse.CLOSE;
                            error_dialog.close_response = DialogResponse.CLOSE;
                            error_dialog.response.connect ((response_id) => {
                                if (response_id == DialogResponse.CLOSE) {
                                    error_dialog.destroy ();
                                }
                            });
                            error_dialog.present ();
                        }
                    }

                    delete_dialog.destroy ();
                });

                delete_dialog.show ();
            });

            var list_item = new Adw.ActionRow () {
                title = file.app_name,
                subtitle = file.comment,
                activatable = true
            };
            list_item.add_prefix (app_icon);
            list_item.add_suffix (delete_button);
            list_item.activated.connect (() => {
                window.show_edit_view (file);
            });

            files_list.append (list_item);
        }

        // Set visible page
        if (files_list.get_last_child () != null) {
            stack.visible_child_name = "files_list_page";
        } else {
            // There are no listboxes, that means we have no valid desktop files
            stack.visible_child_name = "no_files_page";
        }
    }
}
