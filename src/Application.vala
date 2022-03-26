/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    public static Settings settings;
    public MainWindow window { get; private set; }

    public Application () {
        Object (
            application_id: "com.github.ryonakano.pinit",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
        Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (GETTEXT_PACKAGE);
    }

    static construct {
        settings = new Settings ("com.github.ryonakano.pinit");
    }

    protected override void activate () {
        if (window != null) { // The app is already launched
            window.present ();
            return;
        }

        window = new MainWindow ();
        window.set_application (this);

        int window_width, window_height;
        settings.get ("window-size", "(ii)", out window_width, out window_height);

        if (Application.settings.get_boolean ("window-maximized")) {
            window.maximize ();
        }

        window.default_width = window_width;
        window.default_height = window_height;

        window.present ();
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
