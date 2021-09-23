/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class FilesView : Gtk.Grid {
    public MainWindow window { get; construct; }

    private Gee.ArrayList<DesktopFile> files;
    private Gtk.ListBox files_list;
    private Gtk.Stack stack;
    private Gtk.Button open_button;

    public FilesView (MainWindow window) {
        Object (
            window: window,
            margin: 12,
            row_spacing: 12
        );
    }

    construct {
        files_list = new Gtk.ListBox () {
            expand = true
        };

        var no_files_grid = new Granite.Widgets.AlertView (
            _("No valid desktop files found"),
            _("If you've never created one, go back to Welcome View and click “New File”."),
            "dialog-information"
        );

        stack = new Gtk.Stack ();
        stack.get_style_context ().add_class (Gtk.STYLE_CLASS_FRAME);
        stack.add_named (files_list, "files_list");
        stack.add_named (no_files_grid, "no_files_grid");

        open_button = new Gtk.Button.with_label (_("Open")) {
            expand = false,
            halign = Gtk.Align.END
        };
        open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        attach (stack, 0, 0, 1, 1);
        attach (open_button, 0, 1, 1, 1);

        open_button.clicked.connect (() => {
            DesktopFile desktop_file = files.get (files_list.get_selected_row ().get_index ());
            window.show_edit_view (desktop_file);
        });
    }

    public void update_list () {
        foreach (var row in files_list.get_children ()) {
            row.destroy ();
        }

        files = DesktopFileOperator.get_default ().get_files_list ();
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
                margin_bottom = 12
            };
            app_name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            var app_comment_label = new Gtk.Label (file.comment) {
                halign = Gtk.Align.START
            };
            app_comment_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

            var app_grid = new Gtk.Grid () {
                margin = 12,
                column_spacing = 6
            };
            app_grid.attach (app_icon, 0, 0, 1, 2);
            app_grid.attach (app_name_label, 1, 0, 1, 1);
            app_grid.attach (app_comment_label, 1, 1, 1, 1);

            var list_item = new Gtk.ListBoxRow ();
            list_item.add (app_grid);

            files_list.add (list_item);
        }

        files_list.show_all ();

        if (files_list.get_children () != null) {
            stack.visible_child_name = "files_list";
            open_button.sensitive = true;
            files_list.select_row (files_list.get_row_at_index (0));
        } else {
            stack.visible_child_name = "no_files_grid";
            open_button.sensitive = false;
        }
    }
}
