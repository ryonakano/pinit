/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class to represents a single desktop file.
 */
public class Model.DesktopFile : Object {
    /**
     * The suffix of the desktop files.
     */
    public const string DESKTOP_SUFFIX = ".desktop";

    /**
     * The absolute path to the desktop file.
     */
    public string path { get; construct; }

    /**
     * Value of "Type" entry.
     */
    public string value_type {
        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_TYPE, value);
        }
    }

    /**
     * Value of "Name" entry.
     */
    public string value_name {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile_dirty, KeyFileDesktop.KEY_NAME, Application.preferred_language);
            string name = Util.KeyFileUtil.get_locale_string (keyfile_dirty, KeyFileDesktop.KEY_NAME, locale);

            return name;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_NAME, value);
        }
    }

    /**
     * Value of "Exec" entry.
     */
    public string value_exec {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile_dirty, KeyFileDesktop.KEY_EXEC);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_EXEC, value);
        }
    }

    /**
     * Value of "Icon" entry.
     */
    public string value_icon {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile_dirty, KeyFileDesktop.KEY_ICON);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_ICON, value);
        }
    }

    /**
     * Value of "GenericName" entry.
     */
    public string value_generic_name {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile_dirty, KeyFileDesktop.KEY_GENERIC_NAME, Application.preferred_language);
            string generic_name = Util.KeyFileUtil.get_locale_string (keyfile_dirty, KeyFileDesktop.KEY_GENERIC_NAME, locale);

            return generic_name;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_GENERIC_NAME, value);
        }
    }

    /**
     * Value of "Comment" entry.
     */
    public string value_comment {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile_dirty, KeyFileDesktop.KEY_COMMENT, Application.preferred_language);
            string comment = Util.KeyFileUtil.get_locale_string (keyfile_dirty, KeyFileDesktop.KEY_COMMENT, locale);

            return comment;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_COMMENT, value);
        }
    }

    /**
     * Value of "Categories" entry.
     */
    public string[] value_categories {
        owned get {
            return Util.KeyFileUtil.get_string_list (keyfile_dirty, KeyFileDesktop.KEY_CATEGORIES);
        }

        set {
            Util.KeyFileUtil.set_string_list (keyfile_dirty, KeyFileDesktop.KEY_CATEGORIES, value);
        }
    }

    /**
     * Value of "Keywords" entry.
     */
    public string[] value_keywords {
        owned get {
            return Util.KeyFileUtil.get_string_list (keyfile_dirty, Util.KeyFileUtil.KEY_KEYWORDS);
        }

        set {
            Util.KeyFileUtil.set_string_list (keyfile_dirty, Util.KeyFileUtil.KEY_KEYWORDS, value);
        }
    }

    /**
     * Value of "StartupWMClass" entry.
     */
    public string value_startup_wm_class {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile_dirty, KeyFileDesktop.KEY_STARTUP_WM_CLASS);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_STARTUP_WM_CLASS, value);
        }
    }

    /**
     * Value of "Terminal" entry.
     */
    public bool value_terminal {
        get {
            return Util.KeyFileUtil.get_boolean (keyfile_dirty, KeyFileDesktop.KEY_TERMINAL);
        }

        set {
            Util.KeyFileUtil.set_boolean (keyfile_dirty, KeyFileDesktop.KEY_TERMINAL, value);
        }
    }

    /**
     * Value of "Name" entry without unsaved changes.
     */
    public string saved_value_name {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile_clean, KeyFileDesktop.KEY_NAME, Application.preferred_language);
            string name = Util.KeyFileUtil.get_locale_string (keyfile_clean, KeyFileDesktop.KEY_NAME, locale);

            return name;
        }
    }

    /**
     * Value of "Icon" entry without unsaved changes.
     */
    public string saved_value_icon {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile_clean, KeyFileDesktop.KEY_ICON);
        }
    }

    /**
     * Value of "Comment" entry without unsaved changes.
     */
    public string saved_value_comment {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile_clean, KeyFileDesktop.KEY_COMMENT, Application.preferred_language);
            string comment = Util.KeyFileUtil.get_locale_string (keyfile_clean, KeyFileDesktop.KEY_COMMENT, locale);

            return comment;
        }
    }

    /**
     * Returns if this contains unsaved changes to the disk.
     */
    public bool is_clean {
        get {
            return Util.KeyFileUtil.equals (keyfile_dirty, keyfile_clean);
        }
    }

    /**
     * Data in a single desktop file that loaded from the disk.
     */
    private KeyFile keyfile_clean;
    /**
     * Data in a single desktop file that may contain unsaved changes to the disk.
     */
    private KeyFile keyfile_dirty;

    /**
     * The constructor.
     *
     * @param path the absolute path to the desktop file
     */
    public DesktopFile (string path) {
        Object (
            path: path
        );
    }

    construct {
        keyfile_clean = new KeyFile ();
        keyfile_dirty = new KeyFile ();
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // File Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public bool load_file () {
        bool ret = Util.KeyFileUtil.load_file (keyfile_clean, path, KeyFileFlags.KEEP_TRANSLATIONS);
        if (!ret) {
            return false;
        }

        return Util.KeyFileUtil.copy (keyfile_dirty, keyfile_clean);
    }

    public bool save_file () {
        bool ret = Util.KeyFileUtil.save_file (keyfile_dirty, path);
        if (!ret) {
            return false;
        }

        return Util.KeyFileUtil.copy (keyfile_clean, keyfile_dirty);
    }
}
