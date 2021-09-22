/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Application : Gtk.Application {
    private MainWindow window;

    public Application () {
        Object (
            application_id: "com.github.ryonakano.pinit",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        GLib.Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        GLib.Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        GLib.Intl.textdomain (GETTEXT_PACKAGE);
    }

    protected override void activate () {
        if (window != null) {
            return;
        }

        window = new MainWindow ();
        window.set_application (this);
        window.show_all ();
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
