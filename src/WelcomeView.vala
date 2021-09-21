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
        append ("document-new", _("New File"), _("Create a new desktop file."));
        append ("document-open", _("Open File"), _("Open an existing desktop file."));

        activated.connect ((i) => {
            if (i == 0) {
                window.set_visible_view ("edit_view");
            } else {
                window.open_file ();
            }
        });
    }
}
