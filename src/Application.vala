/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    public static Settings settings;
    private MainWindow window;

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

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (() => {
            var about_dialog = new Gtk.AboutDialog () {
                transient_for = window,
                modal = true,
                logo_icon_name = Constants.PROJECT_NAME,
                program_name = Constants.APP_NAME,
                version = Constants.PROJECT_VERSION,
                comments = _("Pin portable apps into your application launcher"),
                website = "https://github.com/ryonakano/pinit",
                copyright = "© 2021-2022 Ryo Nakano",
                license_type = Gtk.License.GPL_3_0,
                authors = { "Ryo Nakano" },
                artists = { "hanaral" },
                ///TRANSLATORS: Replace with your name and email address, don't translate literally
                translator_credits = _("translator-credits")
            };
            about_dialog.present ();
        });
        set_accels_for_action ("app.about", {"F1"});
        add_action (about_action);

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

        var style_manager = Adw.StyleManager.get_default ();
        style_manager.color_scheme = (Adw.ColorScheme) Application.settings.get_enum ("color-scheme");
    }

    static construct {
        settings = new Settings (Constants.PROJECT_NAME);
    }

    private void set_app_style (Adw.ColorScheme color_scheme) {
        Application.settings.set_enum ("color-scheme", color_scheme);
        style_manager.color_scheme = color_scheme;
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
