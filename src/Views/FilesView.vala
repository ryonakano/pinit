/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class FilesView : Gtk.ScrolledWindow {
    private Gtk.ListBox files_list;
    private Gtk.Stack stack;

    public FilesView () {
        Object (
            margin: 12,
            hscrollbar_policy: Gtk.PolicyType.NEVER
        );
    }

    construct {
        files_list = new Gtk.ListBox () {
            expand = true
        };

        var no_files_grid = new Granite.Widgets.AlertView (
            _("No valid app entries found"),
            _("If you've never created one, go back to Welcome View and click “New Entry”."),
            "dialog-information"
        );

        stack = new Gtk.Stack ();
        stack.add_named (files_list, "files_list");
        stack.add_named (no_files_grid, "no_files_grid");

        get_style_context ().add_class (Gtk.STYLE_CLASS_FRAME);
        add (stack);
        show_all ();
    }

    public void update_list () {
        foreach (var row in files_list.get_children ()) {
            row.destroy ();
        }

        var files = DesktopFileOperator.get_default ().files;
        for (int i = 0; i < files.size; i++) {
            var file = files.get (i);

            // Fallback icon
            var app_icon = new Gtk.Image.from_icon_name ("image-missing", Gtk.IconSize.DIALOG);
            // Inspired from https://stackoverflow.com/a/42800483
            if (file.icon_file != "") {
                try {
                    var pixbuf = new Gdk.Pixbuf.from_file_at_scale (file.icon_file, 48, 48, true);
                    app_icon = new Gtk.Image.from_pixbuf (pixbuf);
                } catch (Error e) {
                    warning (e.message);
                }
            }

            app_icon.margin_end = 12;

            var app_name_label = new Gtk.Label (file.app_name) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END,
                tooltip_text = file.app_name,
                margin_bottom = 12
            };
            app_name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            var app_comment_label = new Gtk.Label (file.comment) {
                halign = Gtk.Align.START,
                ellipsize = Pango.EllipsizeMode.END,
                tooltip_text = file.comment
            };
            app_comment_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic", Gtk.IconSize.BUTTON) {
                tooltip_text = _("Delete…"),
                expand = true,
                halign = Gtk.Align.END
            };

            var edit_button = new Gtk.Button.from_icon_name ("document-edit-symbolic", Gtk.IconSize.BUTTON) {
                tooltip_text = _("Edit…"),
                expand = false,
                halign = Gtk.Align.END
            };

            var app_grid = new Gtk.Grid () {
                margin = 12,
                column_spacing = 6
            };
            app_grid.attach (app_icon, 0, 0, 1, 2);
            app_grid.attach (app_name_label, 1, 0, 1, 1);
            app_grid.attach (app_comment_label, 1, 1, 1, 1);
            app_grid.attach (delete_button, 2, 0, 1, 2);
            app_grid.attach (edit_button, 3, 0, 1, 2);

            delete_button.clicked.connect (() => {
                if (Application.IS_ON_PANTHEON) {
                    var delete_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        _("Are you sure you want to delete “%s”?").printf (file.app_name),
                        _("This removes the app from the launcher."),
                        "dialog-warning",
                        Gtk.ButtonsType.NONE
                    ) {
                        modal = true,
                        transient_for = ((Application) GLib.Application.get_default ()).window
                    };
                    delete_dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);

                    var confirm_button = delete_dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                    confirm_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

                    delete_dialog.response.connect ((response_id) => {
                        if (response_id == Gtk.ResponseType.OK) {
                            DesktopFileOperator.get_default ().delete_file (file);
                            update_list ();
                        }

                        delete_dialog.destroy ();
                    });

                    delete_dialog.show ();
                } else {
                    var delete_dialog = new Gtk.MessageDialog (
                        ((Application) GLib.Application.get_default ()).window, Gtk.DialogFlags.MODAL, Gtk.MessageType.QUESTION, Gtk.ButtonsType.CANCEL, null
                    ) {
                        text = _("Are you sure you want to delete “%s”?").printf (file.app_name),
                        secondary_text = _("This removes the app from the launcher.")
                    };

                    var confirm_button = delete_dialog.add_button (_("Delete"), Gtk.ResponseType.OK);
                    confirm_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DESTRUCTIVE_ACTION);

                    delete_dialog.response.connect ((response_id) => {
                        if (response_id == Gtk.ResponseType.OK) {
                            DesktopFileOperator.get_default ().delete_file (file);
                            update_list ();
                        }

                        delete_dialog.destroy ();
                    });

                    delete_dialog.show ();
                }
            });

            edit_button.clicked.connect (() => {
                ((Application) GLib.Application.get_default ()).window.show_edit_view (file);
            });

            var list_item = new Gtk.ListBoxRow ();
            list_item.add (app_grid);

            files_list.add (list_item);
        }

        files_list.show_all ();

        if (files_list.get_children () != null) {
            stack.visible_child_name = "files_list";
            files_list.select_row (files_list.get_row_at_index (0));
        } else {
            stack.visible_child_name = "no_files_grid";
        }
    }
}
