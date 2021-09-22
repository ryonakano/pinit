/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class FilesView : Gtk.Grid {
    public MainWindow window { get; construct; }

    public FilesView (MainWindow window) {
        Object (
            window: window,
            margin: 12,
            row_spacing: 12
        );
    }

    construct {
        var file_list = new Gtk.ListBox () {
            expand = true
        };
        file_list.get_style_context ().add_class (Gtk.STYLE_CLASS_FRAME);

        var files = DesktopFileOperator.get_default ().get_file_list ();
        for (int i = 0; i < files.size; i++) {
            var label = new Gtk.Label (files.get (i).basename) {
                margin = 6
            };
            var list_item = new Gtk.ListBoxRow ();
            list_item.add (label);
            file_list.add (list_item);
        }

        var cancel_button = new Gtk.Button.with_label (_("Cancel"));
        var open_button = new Gtk.Button.with_label (_("Open"));
        open_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        var buttons_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        buttons_box.pack_end (open_button, false, false);
        buttons_box.pack_end (cancel_button, false, false);

        attach (file_list, 0, 0, 1, 1);
        attach (buttons_box, 0, 1, 1, 1);

        cancel_button.clicked.connect (() => {
            window.show_welcome_view ();
        });

        open_button.clicked.connect (() => {
            string path = files.get (file_list.get_selected_row ().get_index ()).path;

            var desktop_file = DesktopFileOperator.get_default ().load_from_file (path);
            window.show_edit_view (desktop_file);
        });

        if (file_list.get_children () != null) {
            file_list.get_row_at_index (0).grab_focus ();
        } else {
            open_button.sensitive = false;
        }
    }
}
