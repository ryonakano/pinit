/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Application : Adw.Application {
    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };

    public static Settings settings { get; private set; }

    /**
     * The language name that the user prefers in the system settings, e.g. "en_US", "ja_JP", etc.
     *
     * Used to show the KEY_NAME and KEY_COMMENT in the user's system language.
     */
    public static unowned string preferred_language { get; private set; }

    private MainWindow main_window;

    public Application () {
        Object (
            application_id: Config.PROJECT_NAME,
            flags: ApplicationFlags.DEFAULT_FLAGS
        );
    }

    static construct {
        settings = new Settings (Config.PROJECT_NAME);

        // Get the user's system language and use it when loading desktop files
        unowned var languages = Intl.get_language_names ();
        preferred_language = languages[0];
    }

    protected override void startup () {
        base.startup ();

        /*
         * Make sure the app is shown in the user's language.
         * https://docs.gtk.org/glib/i18n.html#internationalization
         */
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.PROJECT_NAME, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Config.PROJECT_NAME);

        setup_style ();

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q" });
        set_accels_for_action ("win.new", { "<Control>n" });
    }

    private bool style_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
        Variant? variant = from_value.dup_variant ();
        if (variant == null) {
            warning ("Failed to Variant.dup_variant");
            return false;
        }

        var val = (Adw.ColorScheme) variant.get_int32 ();
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
            case Adw.ColorScheme.FORCE_LIGHT:
            case Adw.ColorScheme.FORCE_DARK:
                to_value.set_enum (val);
                break;
            default:
                warning ("style_action_transform_to_cb: Invalid ColorScheme: %d", val);
                return false;
        }

        return true;
    }

    private bool style_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
        var val = (Adw.ColorScheme) from_value;
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
            case Adw.ColorScheme.FORCE_LIGHT:
            case Adw.ColorScheme.FORCE_DARK:
                to_value.set_variant (new Variant.int32 (val));
                break;
            default:
                warning ("style_action_transform_from_cb: Invalid ColorScheme: %d", val);
                return false;
        }

        return true;
    }

    private static bool color_scheme_get_mapping_cb (Value value, Variant variant, void* user_data) {
        // Convert from the "style" enum defined in the gschema to Adw.ColorScheme
        var val = variant.get_string ();
        switch (val) {
            case "default":
                value.set_enum (Adw.ColorScheme.DEFAULT);
                break;
            case "light":
                value.set_enum (Adw.ColorScheme.FORCE_LIGHT);
                break;
            case "dark":
                value.set_enum (Adw.ColorScheme.FORCE_DARK);
                break;
            default:
                warning ("color_scheme_get_mapping_cb: Invalid enum: %s", val);
                return false;
        }

        return true;
    }

    private static Variant color_scheme_set_mapping_cb (Value value, VariantType expected_type, void* user_data) {
        string color_scheme;

        // Convert from Adw.ColorScheme to the "style" enum defined in the gschema
        var val = (Adw.ColorScheme) value;
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
                color_scheme = "default";
                break;
            case Adw.ColorScheme.FORCE_LIGHT:
                color_scheme = "light";
                break;
            case Adw.ColorScheme.FORCE_DARK:
                color_scheme = "dark";
                break;
            default:
                warning ("color_scheme_set_mapping_cb: Invalid Style: %d", val);
                // fallback to default
                color_scheme = "default";
                break;
        }

        return new Variant.string (color_scheme);
    }

    private void setup_style () {
        var style_action = new SimpleAction.stateful (
            "color-scheme", VariantType.INT32, new Variant.int32 (Adw.ColorScheme.DEFAULT)
        );
        style_action.bind_property ("state", style_manager, "color-scheme",
                                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                                    style_action_transform_to_cb,
                                    style_action_transform_from_cb);
        settings.bind_with_mapping ("color-scheme", style_manager, "color-scheme", SettingsBindFlags.DEFAULT,
                                    color_scheme_get_mapping_cb,
                                    color_scheme_set_mapping_cb,
                                    null, null);
        add_action (style_action);
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

    private void on_quit_activate () {
        if (main_window != null) {
            main_window.prep_destroy ();
            // Prevent quit() for now to show unsaved dialog
            return;
        }

        quit ();
    }

    public static int main (string[] args) {
        var app = new Application ();
        return app.run ();
    }
}
