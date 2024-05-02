/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * The foundation class to manage the app and its window.
 */
public class Application : Adw.Application {
    /**
     * Action names and their callbacks.
     */
    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };

    /**
     * The instance of the application settings.
     */
    public static Settings settings { get; private set; }

    /**
     * The language name that the user prefers in the system settings, e.g. "en_US", "ja_JP", etc.
     *
     * Used to show the ``KEY_NAME`` and ``KEY_COMMENT`` in the user's system language.
     */
    public static unowned string preferred_language { get; private set; }

    /**
     * The instance of the app window.
     */
    private MainWindow main_window;

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS,
            resource_base_path: Config.RESOURCE_PREFIX
        );
    }

    static construct {
        settings = new Settings (Config.APP_ID);

        // Get the user's system language and use it when loading desktop files
        unowned var languages = Intl.get_language_names ();
        preferred_language = languages[0];
    }

    /**
     * Convert ``from_value`` to ``to_value``.
     *
     * @param binding a binding
     * @param from_value the value of Action.state property
     * @param to_value the value of Adw.StyleManager.color_scheme property
     * @return true if the transformation was successful, false otherwise
     *
     * @see GLib.BindingTransformFunc
     */
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

    /**
     * Convert ``from_value`` to ``to_value``.
     *
     * @param binding a binding
     * @param from_value the value of Adw.StyleManager.color_scheme property
     * @param to_value the value of Action.state property
     * @return true if the transformation was successful, false otherwise
     *
     * @see GLib.BindingTransformFunc
     */
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

    /**
     * Convert from the "style" enum defined in the gschema to Adw.ColorScheme.
     *
     * @param to_value return location for the "color-scheme" property value of ``style_manager``
     * @param from_variant the Variant containing "style" enum value of {@link settings}
     * @param user_data unused (null)
     * @return true if the conversion succeeded, false otherwise
     *
     * @see GLib.SettingsBindGetMappingShared
     */
    private static bool color_scheme_get_mapping_cb (Value to_value, Variant from_variant, void* user_data) {
        var val = from_variant.get_string ();
        switch (val) {
            case Define.Style.DEFAULT:
                to_value.set_enum (Adw.ColorScheme.DEFAULT);
                break;
            case Define.Style.LIGHT:
                to_value.set_enum (Adw.ColorScheme.FORCE_LIGHT);
                break;
            case Define.Style.DARK:
                to_value.set_enum (Adw.ColorScheme.FORCE_DARK);
                break;
            default:
                warning ("color_scheme_get_mapping_cb: Invalid style: %s", val);
                return false;
        }

        return true;
    }

    /**
     * Convert from Adw.ColorScheme to the "style" enum defined in the gschema.
     *
     * @param from_value the "color-scheme" property value of ``style_manager``
     * @param expected_type the expected type of Variant that this method returns
     * @param user_data unused (null)
     * @return a new Variant holding the data from ``from_value``
     *
     * @see GLib.SettingsBindSetMappingShared
     */
    private static Variant color_scheme_set_mapping_cb (Value from_value, VariantType expected_type, void* user_data) {
        string color_scheme;

        var val = (Adw.ColorScheme) from_value;
        switch (val) {
            case Adw.ColorScheme.DEFAULT:
                color_scheme = Define.Style.DEFAULT;
                break;
            case Adw.ColorScheme.FORCE_LIGHT:
                color_scheme = Define.Style.LIGHT;
                break;
            case Adw.ColorScheme.FORCE_DARK:
                color_scheme = Define.Style.DARK;
                break;
            default:
                warning ("color_scheme_set_mapping_cb: Invalid Adw.ColorScheme: %d", val);
                // fallback to default
                color_scheme = Define.Style.DEFAULT;
                break;
        }

        return new Variant.string (color_scheme);
    }

    /**
     * Make it possible to change the app style with the following action names
     * and remember that preference to {@link settings}.
     *
     * You can change the app style by passsing Adw.ColorScheme value as a target value
     * to the ``app.color-scheme`` action.
     */
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

    /**
     * Setup localization, app style, and accel keys.
     */
    protected override void startup () {
        base.startup ();

        // Make sure the app is shown in the user's language.
        // https://docs.gtk.org/glib/i18n.html#internationalization
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        setup_style ();

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q" });
        set_accels_for_action ("win.new", { "<Control>n" });
    }

    /**
     * Show {@link MainWindow}.
     *
     * If there is an instance of {@link MainWindow}, show it and leave the method.<<BR>>
     * Otherwise, initialize it, show it, and binding window sizes/states.
     */
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

        // Binding of window maximization with "SettingsBindFlags.DEFAULT" results the window getting bigger and bigger on open.
        // So we use the prepared binding only for setting
        bool is_maximized = Application.settings.get_boolean ("window-maximized");
        if (is_maximized) {
            main_window.maximize ();
        }

        settings.bind ("window-maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    /**
     * The callback for "app.quit" action.
     *
     * Perform pre-destruction process if there is an instance of {@link MainWindow}, otherwise quit the app immediately.
     */
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
