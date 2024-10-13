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
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_TYPE, value);
        }
    }

    /**
     * Value of "Name" entry.
     */
    public string value_name {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile, KeyFileDesktop.KEY_NAME, Application.preferred_language);
            string name = Util.KeyFileUtil.get_locale_string (keyfile, KeyFileDesktop.KEY_NAME, locale);

            return name;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_NAME, value);
        }
    }

    /**
     * Value of "Exec" entry.
     */
    public string value_exec {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile, KeyFileDesktop.KEY_EXEC);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_EXEC, value);
        }
    }

    /**
     * Value of "Icon" entry.
     */
    public string value_icon {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile, KeyFileDesktop.KEY_ICON);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_ICON, value);
        }
    }

    /**
     * Value of "GenericName" entry.
     */
    public string value_generic_name {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile, KeyFileDesktop.KEY_GENERIC_NAME, Application.preferred_language);
            string generic_name = Util.KeyFileUtil.get_locale_string (keyfile, KeyFileDesktop.KEY_GENERIC_NAME, locale);

            return generic_name;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_GENERIC_NAME, value);
        }
    }

    /**
     * Value of "Comment" entry.
     */
    public string value_comment {
        owned get {
            string? locale = Util.KeyFileUtil.get_locale_for_key (keyfile, KeyFileDesktop.KEY_COMMENT, Application.preferred_language);
            string comment = Util.KeyFileUtil.get_locale_string (keyfile, KeyFileDesktop.KEY_COMMENT, locale);

            return comment;
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_COMMENT, value);
        }
    }

    /**
     * Value of "Categories" entry.
     */
    public string[] value_categories {
        owned get {
            return Util.KeyFileUtil.get_string_list (keyfile, KeyFileDesktop.KEY_CATEGORIES);
        }

        set {
            Util.KeyFileUtil.set_string_list (keyfile, KeyFileDesktop.KEY_CATEGORIES, value);
        }
    }

    /**
     * Value of "Keywords" entry.
     */
    public string[] value_keywords {
        owned get {
            return Util.KeyFileUtil.get_string_list (keyfile, Util.KeyFileUtil.KEY_KEYWORDS);
        }

        set {
            Util.KeyFileUtil.set_string_list (keyfile, Util.KeyFileUtil.KEY_KEYWORDS, value);
        }
    }

    /**
     * Value of "StartupWMClass" entry.
     */
    public string value_startup_wm_class {
        owned get {
            return Util.KeyFileUtil.get_string (keyfile, KeyFileDesktop.KEY_STARTUP_WM_CLASS);
        }

        set {
            Util.KeyFileUtil.set_string (keyfile, KeyFileDesktop.KEY_STARTUP_WM_CLASS, value);
        }
    }

    /**
     * Value of "Terminal" entry.
     */
    public bool value_terminal {
        get {
            return Util.KeyFileUtil.get_boolean (keyfile, KeyFileDesktop.KEY_TERMINAL);
        }

        set {
            Util.KeyFileUtil.set_boolean (keyfile, KeyFileDesktop.KEY_TERMINAL, value);
        }
    }

    /**
     * Store data in a single desktop file.
     */
    private KeyFile keyfile;

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
        keyfile = new KeyFile ();
    }

    /**
     * Check if this and other contains the same values as desktop files.
     *
     * @param other another DesktopFile
     * @return true if this and other contains the same values
     */
    public bool equals (DesktopFile other) {
        // Compare other than the path
        string this_data = this.to_data ();
        string other_data = other.to_data ();

        return this_data == other_data;
    }

    /**
     * Copy and set data from this to another DesktopFile.
     *
     * @param dest another DesktopFile to copy this data to
     * @return true if successfully copied, false otherwise
     */
    public bool copy_to (DesktopFile dest) {
        string data = to_data ();
        return dest.load_from_data (data);
    }

    public string to_data () {
        return keyfile.to_data ();
    }

    public bool load_from_data (string data) {
        bool ret = false;

        try {
            ret = keyfile.load_from_data (data, data.length, KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.load_from_data: %s", err.message);
        }

        return ret;
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // File Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public bool load_file () {
        return Util.KeyFileUtil.load_file (keyfile, path, KeyFileFlags.KEEP_TRANSLATIONS);
    }

    public bool save_file () {
        return Util.KeyFileUtil.save_file (keyfile, path);
    }

    public bool delete_file () {
        var file = File.new_for_path (path);
        bool ret = false;

        try {
            ret = file.delete ();
        } catch (Error err) {
            warning ("Failed to delete file. path=%s: %s", path, err.message);
        }

        return ret;
    }
}
