/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class FilesView : Adw.NavigationPage {
    public signal void new_activated ();
    public signal void deleted (bool is_success);
    public signal void selected (DesktopFile file);

    public MainWindow window { private get; construct; }
    public ListStore list { get; construct; }

    private Adw.HeaderBar headerbar;
    private Gtk.ListBox files_list;

    public FilesView (MainWindow window, ListStore list) {
        Object (
            window: window,
            list: list
        );
    }

    construct {
        /*
         * Headerbar part
         */
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
        menu.append (_("Keyboard Shortcuts"), "win.show-help-overlay");
        ///TRANSLATORS: %s will be replaced by the app name (Pin It!)
        menu.append (_("About %s").printf (Constants.APP_NAME), "win.about");

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            menu_model = menu
        };

        headerbar = new Adw.HeaderBar ();
        headerbar.pack_start (create_button);
        headerbar.pack_end (preferences_button);

        /*
         * Content part
         */
        // NoFilesPage: Shown when no desktop files available.
        var no_files_page = new Adw.StatusPage () {
            title = _("No entries found"),
            description = _("Click the + button on the top to create one."),
            icon_name = "dialog-information",
            vexpand = true,
            hexpand = true
        };

        // FilesListPage: The page to list available desktop files.
        files_list = new Gtk.ListBox ();
        files_list.set_placeholder (no_files_page);
        files_list.bind_model (list, files_row_func);
        files_list.add_css_class ("navigation-sidebar");

        // Pack into a scrolled window in case there are many desktop files in the files list
        var files_list_page = new Gtk.ScrolledWindow () {
            child = files_list,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true,
            hexpand = true
        };

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.set_content (files_list_page);

        title = Constants.APP_NAME;
        child = toolbar_view;

        create_button.clicked.connect (() => {
            new_activated ();
        });
    }

    private Gtk.Widget files_row_func (Object item) {
        var file = item as DesktopFile;
        assert (file != null);

        var app_icon = new Gtk.Image.from_gicon (new ThemedIcon ("application-x-executable")) {
            pixel_size = 48,
            margin_top = 6,
            margin_bottom = 6
        };
        try {
            app_icon.gicon = Icon.new_for_string (file.get_string (KeyFileDesktop.KEY_ICON, false));
        } catch (Error e) {
            warning ("Failed to update app_icon: %s", e.message);
        }

        string locale = file.get_locale_for_key (KeyFileDesktop.KEY_NAME, Application.preferred_language);
        string app_name = file.get_locale_string (KeyFileDesktop.KEY_NAME, locale);

        string dialog_title = _("Are you sure you want to delete entry?");
        if (app_name != "") {
            dialog_title = _("Are you sure you want to delete entry of “%s”?").printf (app_name);
        }

        var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
            tooltip_text = _("Delete…"),
            valign = Gtk.Align.CENTER
        };
        delete_button.add_css_class ("flat");
        delete_button.clicked.connect (() => {
            var delete_dialog = new Adw.MessageDialog (
                window,
                dialog_title,
                _("This removes the app from the launcher.")
            );
            delete_dialog.add_response (DialogResponse.CANCEL, _("Cancel"));
            delete_dialog.add_response (DialogResponse.OK, _("Delete"));
            delete_dialog.set_response_appearance (DialogResponse.OK, Adw.ResponseAppearance.DESTRUCTIVE);
            delete_dialog.default_response = DialogResponse.CANCEL;
            delete_dialog.close_response = DialogResponse.CANCEL;
            delete_dialog.response.connect ((response_id) => {
                if (response_id == DialogResponse.OK) {
                    bool ret = file.delete_file ();
                    if (!ret) {
                        var error_dialog = new Adw.MessageDialog (
                            window,
                            _("Could not delete entry of “%s”").printf (app_name),
                            _("There was an error while removing the app entry.")
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

                    deleted (ret);
                }

                delete_dialog.destroy ();
            });

            delete_dialog.present ();
        });

        locale = file.get_locale_for_key (KeyFileDesktop.KEY_COMMENT, Application.preferred_language);
        string comment = file.get_locale_string (KeyFileDesktop.KEY_COMMENT, locale, false);

        var row = new Adw.ActionRow () {
            title = app_name,
            subtitle = comment,
            title_lines = 1,
            subtitle_lines = 1,
            activatable = true
        };
        row.width_request = 350;
        row.add_prefix (app_icon);
        row.add_suffix (delete_button);
        row.activated.connect (() => {
            selected (file);
        });

        return row;
    }
}
