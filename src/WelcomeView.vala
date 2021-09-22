/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class WelcomeView : Granite.Widgets.Welcome {
    public MainWindow window { private get; construct; }

    public WelcomeView (MainWindow window) {
        Object (
            title: _("Pin It!"),
            subtitle: _("Pin any apps into the launcher"),
            window: window
        );
    }

    construct {
        // The background color of this widget is rgb(255, 255, 255) by default.
        // Remove this class so that the background color of the headerbar and the welcome view matches
        get_style_context ().remove_class (Gtk.STYLE_CLASS_VIEW);

        append ("document-new", _("New File"), _("Create a new desktop file."));
        append ("document-open", _("Open File"), _("Open an existing desktop file."));

        activated.connect ((i) => {
            if (i == 0) {
                window.show_edit_view (DesktopFileOperator.get_default ().create_new ());
            } else {
                window.show_files_view ();
            }
        });
    }
}
