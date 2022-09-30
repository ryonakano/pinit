/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    /*
     * The app launches from this class.
     */

    /*
     * Returns if the current desktop environment is Pantheon or not.
     * We'll use this later to provide more appropriate functions or design
     * both on Pantheon and on another desktop environment.
     */
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    // A global variable storing GSettings for this app.
    public static Settings settings;

    /*
     * Private properties and variables
     */
    private MainWindow main_window;

    public Application () {
        Object (
            application_id: Constants.PROJECT_NAME,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    construct {
        // Make sure the app is shown in the user's language.
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Constants.PROJECT_NAME, Constants.LOCALEDIR);
        Intl.bind_textdomain_codeset (Constants.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Constants.PROJECT_NAME);

        // Setup theme things
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

        // Setup "About" window (only on non-Pantheon desktop environment)
        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (() => {
            var about_window = new Adw.AboutWindow () {
                transient_for = main_window,
                modal = true,
                application_icon = Constants.PROJECT_NAME,
                application_name = Constants.APP_NAME,
                version = Constants.PROJECT_VERSION,
                comments = _("Create the shortcut to your favorite portable apps into your app launcher"),
                website = "https://github.com/ryonakano/pinit",
                support_url = "https://github.com/ryonakano/pinit/discussions",
                issue_url = "https://github.com/ryonakano/pinit/issues",
                copyright = "© 2021-2022 Ryo Nakano",
                license_type = Gtk.License.GPL_3_0,
                developer_name = "Ryo Nakano",
                developers = { "Ryo Nakano https://github.com/ryonakano", "Jeyson Flores https://github.com/JeysonFlores", null },
                artists = { "hanaral https://github.com/hanaral", null },
                ///TRANSLATORS: Replace with your name; don't translate literally
                translator_credits = _("translator-credits")
            };
            about_window.present ();
        });
        set_accels_for_action ("app.about", {"F1"});
        add_action (about_action);
    }

    static construct {
        settings = new Settings (Constants.PROJECT_NAME);
    }

    /*
     * Called when user switches the theme setting in the popover.
     * Save that selection into GSettings and reflect that change into the app now
     */
    private void set_app_style (Adw.ColorScheme color_scheme) {
        Application.settings.set_enum ("color-scheme", color_scheme);
        style_manager.color_scheme = color_scheme;
    }

    protected override void activate () {
        if (main_window != null) {
            // The app is already launched; show that window and do nothing else
            main_window.present ();
            return;
        }

        main_window = new MainWindow ();
        main_window.set_application (this);
        // The window seems to need showing before restoring its size in Gtk4
        main_window.present ();

        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        /*
         * Binding of window maximization with "SettingsBindFlags.DEFAULT" results the window getting bigger and bigger on open.
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
