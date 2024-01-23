/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    struct Style {
        string name;
        Adw.ColorScheme color_scheme;
    }

    // Returns if the current desktop environment is Pantheon or not.
    // We'll use this later to provide more appropriate functions or design
    // both on Pantheon and on another desktop environment.
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    public static Settings settings { get; private set; }

    private MainWindow main_window;

    public Application () {
        Object (
            application_id: Constants.PROJECT_NAME,
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    static construct {
        settings = new Settings (Constants.PROJECT_NAME);
    }

    protected override void startup () {
        base.startup ();

        /*
         * Make sure the app is shown in the user's language.
         * https://docs.gtk.org/glib/i18n.html#internationalization
         */
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Constants.PROJECT_NAME, Constants.LOCALEDIR);
        Intl.bind_textdomain_codeset (Constants.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Constants.PROJECT_NAME);

        setup_style ();

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (() => {
            var about_window = new AboutWindow (main_window);
            about_window.present ();
        });
        add_action (about_action);
    }

    private void setup_style () {
        const Style[] STYLES = {
            { "style-light", Adw.ColorScheme.FORCE_LIGHT },
            { "style-dark", Adw.ColorScheme.FORCE_DARK },
            { "style-system", Adw.ColorScheme.PREFER_LIGHT }
        };

        var style_manager = Adw.StyleManager.get_default ();
        style_manager.color_scheme = (Adw.ColorScheme) Application.settings.get_enum ("color-scheme");

        foreach (var STYLE in STYLES) {
            var style_light_action = new SimpleAction (STYLE.name, null);
            style_light_action.activate.connect (() => {
                set_app_style (STYLE.color_scheme);
            });
            set_accels_for_action ("app." + STYLE.name, {""});
            add_action (style_light_action);
        }
    }

    private void set_app_style (Adw.ColorScheme color_scheme) {
        Application.settings.set_enum ("color-scheme", color_scheme);
        style_manager.color_scheme = color_scheme;
    }

    protected override void activate () {
        if (main_window != null) {
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
        bool is_maximized = Application.settings.get_boolean ("window-maximized");
        if (is_maximized) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
