/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    public static Settings settings;
    private MainWindow main_window;

    public Application () {
        Object (
            application_id: Constants.PROJECT_NAME,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Constants.PROJECT_NAME, Constants.LOCALEDIR);
        Intl.bind_textdomain_codeset (Constants.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Constants.PROJECT_NAME);

        var style_manager = Adw.StyleManager.get_default ();
        style_manager.color_scheme = (Adw.ColorScheme) Application.settings.get_enum ("color-scheme");

        var style_light_action = new SimpleAction ("style-light", null);
        style_light_action.activate.connect (() => {
            set_app_style (Adw.ColorScheme.FORCE_LIGHT);
        });
        set_accels_for_action ("app.style-light", {""});
        add_action (style_light_action);

        var style_dark_action = new SimpleAction ("style-dark", null);
        style_dark_action.activate.connect (() => {
            set_app_style (Adw.ColorScheme.FORCE_DARK);
        });
        set_accels_for_action ("app.style-dark", {""});
        add_action (style_dark_action);

        var style_system_action = new SimpleAction ("style-system", null);
        style_system_action.activate.connect (() => {
            set_app_style (Adw.ColorScheme.PREFER_LIGHT);
        });
        set_accels_for_action ("app.style-system", {""});
        add_action (style_system_action);

        // elementary prefers AppData for showcasing the app info, so don't construct useless AboutDialog on Pantheon
        if (IS_ON_PANTHEON) {
            return;
        }

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (() => {
            var about_dialog = new Gtk.AboutDialog () {
                transient_for = main_window,
                modal = true,
                logo_icon_name = Constants.PROJECT_NAME,
                program_name = Constants.APP_NAME,
                version = Constants.PROJECT_VERSION,
                comments = _("Create the shortcut to your favorite portable apps into your app launcher"),
                website = "https://github.com/ryonakano/pinit",
                copyright = "© 2021-2022 Ryo Nakano",
                license_type = Gtk.License.GPL_3_0,
                authors = { "Ryo Nakano" },
                artists = { "hanaral" },
                ///TRANSLATORS: Replace with your name; don't translate literally
                translator_credits = _("translator-credits")
            };
            about_dialog.present ();
        });
        set_accels_for_action ("app.about", {"F1"});
        add_action (about_action);
    }

    static construct {
        settings = new Settings (Constants.PROJECT_NAME);
    }

    private void set_app_style (Adw.ColorScheme color_scheme) {
        Application.settings.set_enum ("color-scheme", color_scheme);
        style_manager.color_scheme = color_scheme;
    }

    protected override void activate () {
        if (main_window != null) { // The app is already launched
            main_window.present ();
            return;
        }

        main_window = new MainWindow ();
        main_window.set_application (this);
        // The main_window seems to need showing before restoring its size in Gtk4
        main_window.present ();

        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        /*
         * Binding of main_window maximization with "SettingsBindFlags.DEFAULT" results the main_window getting bigger and bigger on open.
         * So we use the prepared binding only for setting
         */
        if (Application.settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    public static int main (string[] args) {
        return new Application ().run ();
    }
}
