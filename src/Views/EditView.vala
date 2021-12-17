/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class EditView : Gtk.Grid {
    public bool is_unsaved {
        get {
            return (
                file_name_entry.text.length > 0 || name_entry.text.length > 0 ||
                comment_entry.text.length > 0 || exec_entry.text.length > 0 ||
                icon_entry.text.length > 0 || category_chooser.selected != "" || terminal_checkbox.active
            );
        }
    }

    private Granite.ValidatedEntry file_name_entry;
    private Granite.ValidatedEntry name_entry;
    private Granite.ValidatedEntry comment_entry;
    private Gtk.Entry exec_entry;
    private Gtk.Entry icon_entry;
    private CategoryChooser category_chooser;
    private Gtk.CheckButton terminal_checkbox;
    private Gtk.Button action_button;

    public EditView () {
        Object (
            margin: 24,
            margin_top: 12
        );
    }

    construct {
        var file_name_label = new Granite.HeaderLabel (_("File Name"));
        var file_name_desc_label = new DimLabel (
            _("Name of the file where these app info is saved. Only lowercase letters and numbers are allowed.")
        );
        file_name_entry = new Granite.ValidatedEntry.from_regex (/^[a-z1-9]+$/) {
            expand = true
        };
        var suffix_label = new Gtk.Label (".desktop") {
            tooltip_text = _("Suffix of the file"),
            margin_start = 6
        };
        var file_name_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        file_name_grid.attach (file_name_label, 0, 0, 1, 1);
        file_name_grid.attach (file_name_desc_label, 0, 1, 1, 1);
        file_name_grid.attach (file_name_entry, 0, 2, 1, 1);
        file_name_grid.attach (suffix_label, 1, 2, 1, 1);

        var name_label = new Granite.HeaderLabel (_("App Name"));
        var name_desc_label = new DimLabel (_("Shown in the launcher or Dock."));
        name_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var name_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        name_grid.attach (name_label, 0, 0, 1, 1);
        name_grid.attach (name_desc_label, 0, 1, 1, 1);
        name_grid.attach (name_entry, 0, 2, 1, 1);

        var comment_label = new Granite.HeaderLabel (_("Comment"));
        var comment_desc_label = new DimLabel (_("A tooltip text to describe what the app helps you to do."));
        comment_entry = new Granite.ValidatedEntry.from_regex (/^.+$/) {
            expand = true
        };
        var comment_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        comment_grid.attach (comment_label, 0, 0, 1, 1);
        comment_grid.attach (comment_desc_label, 0, 1, 1, 1);
        comment_grid.attach (comment_entry, 0, 2, 1, 1);

        var exec_label = new Granite.HeaderLabel (_("Exec File"));
        var exec_desc_label = new DimLabel (
            _("The command/app launched when you click the app entry in the launcher. Specify in an absolute path or an app's alias name.")
        );
        exec_entry = new Gtk.Entry () {
            expand = true,
            secondary_icon_name = "document-open-symbolic"
        };
        var exec_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        exec_grid.attach (exec_label, 0, 0, 1, 1);
        exec_grid.attach (exec_desc_label, 0, 1, 1, 1);
        exec_grid.attach (exec_entry, 0, 2, 1, 1);

        var icon_label = new Granite.HeaderLabel (_("Icon File"));
        var icon_desc_label = new DimLabel (
            _("The icon branding the app. Specify in an absolute path or an icon's alias name.")
        );
        icon_entry = new Gtk.Entry () {
            expand = true,
            secondary_icon_name = "document-open-symbolic"
        };
        var icon_grid = new Gtk.Grid () {
            margin_bottom = 12
        };
        icon_grid.attach (icon_label, 0, 0, 1, 1);
        icon_grid.attach (icon_desc_label, 0, 1, 1, 1);
        icon_grid.attach (icon_entry, 0, 2, 1, 1);

        var categories_label = new Granite.HeaderLabel (_("App Categories"));
        var categories_desc_label = new DimLabel (_("Type of the app, multiplly selectable."));
        category_chooser = new CategoryChooser ();
        var categories_grid = new Gtk.Grid () {
            margin_bottom = 24
        };
        categories_grid.attach (categories_label, 0, 0, 1, 1);
        categories_grid.attach (categories_desc_label, 0, 1, 1, 1);
        categories_grid.attach (category_chooser, 0, 2, 1, 1);

        terminal_checkbox = new Gtk.CheckButton.with_label (_("Run in Terminal")) {
            margin_bottom = 6
        };
        var terminal_desc_label = new DimLabel (_("Check this in if you want to registar a CUI app."));

        action_button = new Gtk.Button.with_label (_("Save entry")) {
            margin_top = 24,
            sensitive = (
                file_name_entry.is_valid && name_entry.is_valid && comment_entry.is_valid &&
                exec_entry.text.length > 0 && category_chooser.selected != ""
            )
        };
        action_button.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);

        attach (file_name_grid, 0, 0, 1, 3);
        attach (name_grid, 0, 3, 1, 3);
        attach (comment_grid, 0, 6, 1, 3);
        attach (exec_grid, 0, 9, 1, 3);
        attach (icon_grid, 0, 12, 1, 3);
        attach (categories_grid, 0, 15, 1, 3);
        attach (terminal_checkbox, 0, 20, 1, 1);
        attach (terminal_desc_label, 0, 21, 1, 1);
        attach (action_button, 0, 22, 1, 1);

        exec_entry.icon_press.connect ((icon_pos, event) => {
            if (icon_pos != Gtk.EntryIconPosition.SECONDARY) {
                return;
            }

            var filechooser = new Gtk.FileChooserNative (
                _("Select an executable file"), ((Application) GLib.Application.get_default ()).window, Gtk.FileChooserAction.OPEN,
                _("Open"), _("Cancel")
            ) {
                local_only = true
            };
            filechooser.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    exec_entry.text = filechooser.get_filename ();
                }
            });
            filechooser.show ();
        });

        icon_entry.icon_press.connect ((icon_pos, event) => {
            if (icon_pos != Gtk.EntryIconPosition.SECONDARY) {
                return;
            }

            // See https://specifications.freedesktop.org/icon-theme-spec/latest/ar01s02.html
            var filefilter = new Gtk.FileFilter ();
            filefilter.add_mime_type ("image/png");
            filefilter.add_mime_type ("image/svg+xml");
            filefilter.add_mime_type ("image/x-xpixmap");
            filefilter.set_filter_name (_("PNG, SVG, or XMP files"));

            var filechooser = new Gtk.FileChooserNative (
                _("Select an icon file"), ((Application) GLib.Application.get_default ()).window, Gtk.FileChooserAction.OPEN,
                _("Open"), _("Cancel")
            ) {
                local_only = true
            };
            filechooser.add_filter (filefilter);
            filechooser.response.connect ((response_id) => {
                if (response_id == Gtk.ResponseType.ACCEPT) {
                    icon_entry.text = filechooser.get_filename ();
                }
            });
            filechooser.show ();
        });

        action_button.clicked.connect (() => {
            save_file ();
        });

        key_release_event.connect (() => {
            set_action_button_sensitivity ();
            return false;
        });

        category_chooser.toggled.connect (set_action_button_sensitivity);
    }

    public void set_desktop_file (DesktopFile desktop_file) {
        file_name_entry.text = desktop_file.file_name;
        name_entry.text = desktop_file.app_name;
        comment_entry.text = desktop_file.comment;
        exec_entry.text = desktop_file.exec_file;
        icon_entry.text = desktop_file.icon_file;
        category_chooser.selected = desktop_file.categories;
        terminal_checkbox.active = desktop_file.is_cli;

        set_action_button_sensitivity ();
        file_name_entry.grab_focus ();
    }

    private void set_action_button_sensitivity () {
        action_button.sensitive = (
            file_name_entry.is_valid && name_entry.is_valid && comment_entry.is_valid &&
            exec_entry.text.length > 0 && category_chooser.selected != ""
        );
    }

    public void save_file (bool is_backup = false) {
        var desktop_file = new DesktopFile (
            file_name_entry.text,
            name_entry.text,
            comment_entry.text,
            exec_entry.text,
            icon_entry.text,
            category_chooser.selected,
            terminal_checkbox.active,
            is_backup
        );
        DesktopFileOperator.get_default ().write_to_file (desktop_file);
    }
}
