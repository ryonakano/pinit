/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Gtk.Application {
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

        int window_x, window_y;
        settings.get ("window-position", "(ii)", out window_x, out window_y);

        window = new MainWindow ();
        window.set_application (this);

        if (window_x != -1 || window_y != -1) { // Not a first time launch
            window.move (window_x, window_y);
        } else { // First time launch
            window.window_position = Gtk.WindowPosition.CENTER;
        }
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
