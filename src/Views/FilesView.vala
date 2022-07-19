/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class FilesView : Gtk.Box {

    /* We need to get access to the instance of MainWindow to execute some functions inside. */
    public MainWindow window { private get; construct; }
    public Adw.HeaderBar headerbar { get; private set; }

    private Gtk.ListBox files_list;
    private Gtk.Stack stack;

    public FilesView (MainWindow window) {
        Object (window: window);
    }

    construct {
        // HeaderBar part
        var create_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Create a new entry")
        };

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
        files_list = new Gtk.ListBox () {
            vexpand = true,
            hexpand = true
        };

        var files_list_page = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        files_list_page.append (files_list);

        var no_files_page = new Adw.StatusPage () {
            title = _("No valid app entries found"),
            description = _("If you've never created one, click the + button on the top."),
            icon_name = "dialog-information"
        };

        stack = new Gtk.Stack ();
        stack.add_named (files_list_page, "files_list_page");
        stack.add_named (no_files_page, "no_files_page");

        var scrolled = new Gtk.ScrolledWindow () {
            child = stack,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            margin_top = 12,
            margin_bottom = 24,
            margin_start = 24,
            margin_end = 24
        };

        create_button.clicked.connect (() => {
            window.show_edit_view (DesktopFileOperator.get_default ().create_new ());
        });

        update_list ();

        orientation = Gtk.Orientation.VERTICAL;
        append (headerbar);
        append (scrolled);
    }

    public void update_list () {
        while ((Gtk.ListBoxRow) files_list.get_last_child () != null) {
            files_list.remove ((Gtk.ListBoxRow) files_list.get_last_child ());
        }

        var files = DesktopFileOperator.get_default ().files;
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
                var delete_dialog = new Gtk.MessageDialog (
                    window, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.CANCEL, null
                ) {
                    text = _("Are you sure you want to delete “%s”?").printf (file.app_name),
                    secondary_text = _("This removes the app from the launcher.")
                };

                var confirm_button = delete_dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                confirm_button.get_style_context ().add_class ("destructive-action");

                delete_dialog.response.connect ((response_id) => {
                    if (response_id == Gtk.ResponseType.OK) {
                        DesktopFileOperator.get_default ().delete_file (file);
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

        if (files_list.get_last_child () != null) {
            stack.visible_child_name = "files_list_page";
        } else {
            stack.visible_child_name = "no_files_page";
        }
    }
}
