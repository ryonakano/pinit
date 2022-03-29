/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class FilesView : Gtk.Box {
    public MainWindow window { private get; construct; }

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

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        //  preferences_box.append (new StyleSwitcher ());

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var headerbar = new Adw.HeaderBar () {
            title_widget = new Gtk.Label ("Pin It!")
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

        files_list.row_selected.connect ((row) => {
            window.show_edit_view (DesktopFileOperator.get_default ().files.get (row.get_index ()));
        });

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

            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
                tooltip_text = _("Delete…"),
                //  expand = true,
                halign = Gtk.Align.END
            };

            var edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic") {
                tooltip_text = _("Edit…"),
                //  expand = false,
                halign = Gtk.Align.END
            };

            var app_grid = new Gtk.Grid () {
                column_spacing = 6,
                valign = Gtk.Align.CENTER
            };
            app_grid.attach (delete_button, 0, 0, 1, 1);
            app_grid.attach (edit_button, 1, 0, 1, 1);

            delete_button.clicked.connect (() => {
                var delete_dialog = new Gtk.MessageDialog (
                    ((Application) GLib.Application.get_default ()).window, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.CANCEL, null
                ) {
                    text = _("Are you sure you want to delete “%s”?").printf (file.app_name),
                    secondary_text = _("This removes the app from the launcher.")
                };

                var confirm_button = delete_dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                confirm_button.get_style_context ().add_class ("destructive-action");

                delete_dialog.response.connect ((response_id) => {
                    if (response_id == Gtk.ResponseType.OK) {
                        DesktopFileOperator.get_default ().delete_file (file);
                        update_list ();
                    }

                    delete_dialog.destroy ();
                });

                delete_dialog.show ();
            });

            edit_button.clicked.connect (() => {
                ((Application) GLib.Application.get_default ()).window.show_edit_view (file);
            });

            var list_item = new Adw.ActionRow () {
                icon_name = file.icon_file != "" ? file.icon_file : "image-missing",
                title = file.app_name,
                subtitle = file.comment,
            };
            list_item.get_style_context ().add_class ("boxed-list");
            list_item.add_suffix (app_grid);

            files_list.append (list_item);
        }

        if (files_list.get_last_child () != null) {
            stack.visible_child_name = "files_list_page";
        } else {
            stack.visible_child_name = "no_files_page";
        }
    }
}
