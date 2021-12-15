/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class WelcomeView : Granite.Widgets.Welcome {
    public WelcomeView () {
        Object (
            title: "Pin It!",
            subtitle: _("Pin any apps into the launcher")
        );
    }

    construct {
        // The background color of this widget is rgb(255, 255, 255) by default.
        // Remove this class so that the background color of the headerbar and the welcome view matches
        get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        append ("document-new", _("New File"), _("Create a new desktop file."));
        append ("document-edit", _("Edit File"), _("Edit an existing desktop file."));

        DesktopFile unsaved_file;
        if (DesktopFileOperator.get_default ().get_unsaved_file () != null) {
            append ("document-revert", _("Last Unsaved File"), _("Continue with the unsaved desktop file last opened."));
            unsaved_file = DesktopFileOperator.get_default ().get_unsaved_file ();
        }

        activated.connect ((i) => {
            unowned var window = ((Application) GLib.Application.get_default ()).window;

            switch (i) {
                case 0:
                    window.show_edit_view (new DesktopFile ());
                    break;
                case 1:
                    window.show_files_view ();
                    break;
                case 2:
                    window.show_edit_view (unsaved_file);
                    break;
            }
        });
    }
}
