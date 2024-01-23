/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class AboutWindow : GLib.Object {
    public MainWindow parent { get; construct; }

    private Adw.AboutWindow instance;

    private const string[] DEVELOPERS = {
        "Ryo Nakano https://github.com/ryonakano",
        "Jeyson Flores https://github.com/JeysonFlores",
    };
    private const string[] ARTISTS = {
        "hanaral https://github.com/hanaral",
    };

    public AboutWindow (MainWindow parent) {
        Object (parent: parent);
    }

    construct {
        instance = new Adw.AboutWindow () {
            transient_for = parent,
            modal = true,
            application_icon = Constants.PROJECT_NAME,
            application_name = Constants.APP_NAME,
            version = Constants.PROJECT_VERSION,
            comments = _("Pin shortcuts for your favorite portable apps to your app launcher"),
            website = "https://github.com/ryonakano/pinit",
            support_url = "https://github.com/ryonakano/pinit/discussions",
            issue_url = "https://github.com/ryonakano/pinit/issues",
            copyright = "© 2021-2024 Ryo Nakano",
            license_type = Gtk.License.GPL_3_0,
            developer_name = "Ryo Nakano",
            developers = DEVELOPERS,
            artists = ARTISTS,
            ///TRANSLATORS: Replace with your name; don't translate literally
            translator_credits = _("translator-credits")
        };
    }

    public void present () {
        if (instance != null) {
            instance.present ();
        }
    }
}
