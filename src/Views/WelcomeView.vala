/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class WelcomeView : Granite.Widgets.Welcome {
    public WelcomeView () {
        Object (
            title: Constants.APP_NAME,
            subtitle: _("Pin any apps into the launcher")
        );
    }

    construct {
        // The background color of this widget is rgb(255, 255, 255) by default.
        // Remove this class so that the background color of the headerbar and the welcome view matches
        get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        append ("document-new", _("New Entry"), _("Create a new app entry."));
        append ("document-edit", _("Edit Entry"), _("Edit an existing app entry."));

        activated.connect ((i) => {
            unowned var window = ((Application) GLib.Application.get_default ()).window;

            if (i == 0) {
                window.show_edit_view (DesktopFileOperator.get_default ().create_new ());
            } else {
                window.show_files_view ();
            }
        });
    }
}
