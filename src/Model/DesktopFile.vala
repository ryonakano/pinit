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
     * Value of "Name" entry.
     */
    public string value_name {
        owned get {
            Value? name = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_NAME, Util.KeyFileUtil.get_locale_string);
            if (name == null) {
                return "";
            }

            return (string) name;
        }

        set {
            Value? name = null;
            if (value != "") {
                name = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_NAME, name, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "Exec" entry.
     */
    public string value_exec {
        owned get {
            Value? exec = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_EXEC, Util.KeyFileUtil.get_string);
            if (exec == null) {
                return "";
            }

            return (string) exec;
        }

        set {
            Value? exec = null;
            if (value != "") {
                exec = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_EXEC, exec, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "Icon" entry.
     */
    public string value_icon {
        owned get {
            Value? icon = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_ICON, Util.KeyFileUtil.get_string);
            if (icon == null) {
                return "";
            }

            return (string) icon;
        }

        set {
            Value? icon = null;
            if (value != "") {
                icon = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_ICON, icon, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "GenericName" entry.
     */
    public string value_generic_name {
        owned get {
            Value? generic_name = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_GENERIC_NAME, Util.KeyFileUtil.get_locale_string);
            if (generic_name == null) {
                return "";
            }

            return (string) generic_name;
        }

        set {
            Value? generic_name = null;
            if (value != "") {
                generic_name = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_GENERIC_NAME, generic_name, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "Comment" entry.
     */
    public string value_comment {
        owned get {
            Value? comment = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_COMMENT, Util.KeyFileUtil.get_locale_string);
            if (comment == null) {
                return "";
            }

            return (string) comment;
        }

        set {
            Value? comment = null;
            if (value != "") {
                comment = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_COMMENT, comment, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "Categories" entry.
     */
    public string[] value_categories {
        owned get {
            Value? categories = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_CATEGORIES, Util.KeyFileUtil.get_strv);
            if (categories == null) {
                return {};
            }

            return (string[]) categories;
        }

        set {
            Value? categories = null;
            if (value.length > 0) {
                categories = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_CATEGORIES, categories, Util.KeyFileUtil.set_strv);
        }
    }

    /**
     * Value of "Keywords" entry.
     */
    public string[] value_keywords {
        owned get {
            Value? keywords = Util.KeyFileUtil.get_value (keyfile_dirty, Util.KeyFileUtil.KEY_KEYWORDS, Util.KeyFileUtil.get_strv);
            if (keywords == null) {
                return {};
            }

            return (string[]) keywords;
        }

        set {
            Value? keywords = null;
            if (value.length > 0) {
                keywords = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, Util.KeyFileUtil.KEY_KEYWORDS, keywords, Util.KeyFileUtil.set_strv);
        }
    }

    /**
     * Value of "StartupWMClass" entry.
     */
    public string value_startup_wm_class {
        owned get {
            Value? startup_wm_class = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_STARTUP_WM_CLASS, Util.KeyFileUtil.get_string);
            if (startup_wm_class == null) {
                return "";
            }

            return (string) startup_wm_class;
        }

        set {
            Value? startup_wm_class = null;
            if (value != "") {
                startup_wm_class = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_STARTUP_WM_CLASS, startup_wm_class, Util.KeyFileUtil.set_string);
        }
    }

    /**
     * Value of "Terminal" entry.
     */
    public bool value_terminal {
        get {
            Value? terminal = Util.KeyFileUtil.get_value (keyfile_dirty, KeyFileDesktop.KEY_TERMINAL, Util.KeyFileUtil.get_boolean);
            if (terminal == null) {
                return false;
            }

            return (bool) terminal;
        }

        set {
            Value? terminal = null;
            if (value) {
                terminal = value;
            }

            Util.KeyFileUtil.set_value (keyfile_dirty, KeyFileDesktop.KEY_TERMINAL, terminal, Util.KeyFileUtil.set_boolean);
        }
    }

    /**
     * Value of "Name" entry without unsaved changes.
     */
    public string saved_value_name {
        owned get {
            Value? name = Util.KeyFileUtil.get_value (keyfile_clean, KeyFileDesktop.KEY_NAME, Util.KeyFileUtil.get_locale_string);
            if (name == null) {
                return "";
            }

            return (string) name;
        }
    }

    /**
     * Value of "Icon" entry without unsaved changes.
     */
    public string saved_value_icon {
        owned get {
            Value? icon = Util.KeyFileUtil.get_value (keyfile_clean, KeyFileDesktop.KEY_ICON, Util.KeyFileUtil.get_string);
            if (icon == null) {
                return "";
            }

            return (string) icon;
        }
    }

    /**
     * Value of "Comment" entry without unsaved changes.
     */
    public string saved_value_comment {
        owned get {
            Value? comment = Util.KeyFileUtil.get_value (keyfile_clean, KeyFileDesktop.KEY_COMMENT, Util.KeyFileUtil.get_locale_string);
            if (comment == null) {
                return "";
            }

            return (string) comment;
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

    /**
     * Read content of the desktop file from the disk.
     *
     * @return true if succeeded, false otherwise
     */
    public bool load_file () {
        bool ret = Util.KeyFileUtil.load_file (keyfile_clean, path, KeyFileFlags.KEEP_TRANSLATIONS);
        if (!ret) {
            return false;
        }

        return Util.KeyFileUtil.copy (keyfile_dirty, keyfile_clean);
    }

    /**
     * Write content of the desktop file to the disk.
     *
     * @return true if succeeded, false otherwise
     */
    public bool save_file () {
        Util.KeyFileUtil.set_string (keyfile_dirty, KeyFileDesktop.KEY_TYPE, "Application");

        bool ret = Util.KeyFileUtil.save_file (keyfile_dirty, path);
        if (!ret) {
            return false;
        }

        return Util.KeyFileUtil.copy (keyfile_clean, keyfile_dirty);
    }
}
