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
     * A key under ``g_key_file_desktop_group``, whose value is a list of strings giving the keywords which may be used in
     * addition to other metadata to describe this entry.
     *
     * Note: Using ``KeyFileDesktop.KEY_KEYWORDS`` will cause the cc failing with ``‘G_KEY_FILE_DESKTOP_KEY_KEYWORDS’ undeclared``
     * error.<<BR>>
     * This constant does not seem to be defined in the original glib and defined in the following patch.<<BR>>
     * (and maybe valac uses glibc with this patch and thus it does not complain any error.)<<BR>>
     * <<BR>>
     * [[https://sources.debian.org/patches/glib2.0/2.78.3-2/01_gettext-desktopfiles.patch/]]<<BR>>
     * <<BR>>
     * We just keep to borrow the definition of KEY_KEYWORDS here instead of applying the patch,
     * since it might have side effect.
     */
    public const string KEY_KEYWORDS = "Keywords";

    /**
     * The absolute path to the desktop file.
     */
    public string path { get; construct; }

    /**
     * Value of "Name" entry.
     */
    public string value_name {
        owned get {
            string? locale = get_locale_for_key (KeyFileDesktop.KEY_NAME, Application.preferred_language);
            string name = get_locale_string (KeyFileDesktop.KEY_NAME, locale);

            return name;
        }

        set {
            set_string (KeyFileDesktop.KEY_NAME, value);
        }
    }

    /**
     * Value of "Exec" entry.
     */
    public string value_exec {
        owned get {
            return get_string (KeyFileDesktop.KEY_EXEC);
        }

        set {
            set_string (KeyFileDesktop.KEY_EXEC, value);
        }
    }

    /**
     * Value of "Icon" entry.
     */
    public string value_icon {
        owned get {
            return get_string (KeyFileDesktop.KEY_ICON);
        }

        set {
            set_string (KeyFileDesktop.KEY_ICON, value);
        }
    }

    /**
     * Value of "GenericName" entry.
     */
    public string value_generic_name {
        owned get {
            string? locale = get_locale_for_key (KeyFileDesktop.KEY_GENERIC_NAME, Application.preferred_language);
            string generic_name = get_locale_string (KeyFileDesktop.KEY_GENERIC_NAME, locale);

            return generic_name;
        }

        set {
            set_string (KeyFileDesktop.KEY_GENERIC_NAME, value);
        }
    }

    /**
     * Value of "Comment" entry.
     */
    public string value_comment {
        owned get {
            string? locale = get_locale_for_key (KeyFileDesktop.KEY_COMMENT, Application.preferred_language);
            string comment = get_locale_string (KeyFileDesktop.KEY_COMMENT, locale);

            return comment;
        }

        set {
            set_string (KeyFileDesktop.KEY_COMMENT, value);
        }
    }

    /**
     * Value of "Categories" entry.
     */
    public string[] value_categories {
        owned get {
            return get_string_list (KeyFileDesktop.KEY_CATEGORIES);
        }

        set {
            set_string_list (KeyFileDesktop.KEY_CATEGORIES, value);
        }
    }

    /**
     * Value of "Keywords" entry.
     */
    public string[] value_keywords {
        owned get {
            return get_string_list (KEY_KEYWORDS);
        }

        set {
            set_string_list (KEY_KEYWORDS, value);
        }
    }

    /**
     * Value of "StartupWMClass" entry.
     */
    public string value_startup_wm_class {
        owned get {
            return get_string (KeyFileDesktop.KEY_STARTUP_WM_CLASS);
        }

        set {
            set_string (KeyFileDesktop.KEY_STARTUP_WM_CLASS, value);
        }
    }

    /**
     * Value of "Terminal" entry.
     */
    public bool value_terminal {
        get {
            return get_boolean (KeyFileDesktop.KEY_TERMINAL);
        }

        set {
            set_boolean (KeyFileDesktop.KEY_TERMINAL, value);
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

    ////////////////////////////////////////////////////////////////////////////
    //
    // Key Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Return the value associated with ``key`` as a boolean.
     *
     * @param key a key
     * @return the value associated with the key as a boolean, or false if the key was not found or could not be parsed
     * @see GLib.KeyFile.get_boolean
     */
    public bool get_boolean (string key) {
        bool val = false;

        if (!has_key (key)) {
            return val;
        }

        try {
            val = keyfile.get_boolean (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_boolean: key=%s: %s", key, err.message);
        }

        return val;
    }

    public string get_string (string key) {
        string val = "";

        if (!has_key (key)) {
            return val;
        }

        try {
            val = keyfile.get_string (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_string: key=%s: %s", key, err.message);
        }

        return val;
    }

    public bool has_key (string key) {
        bool ret = false;

        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return ret;
        }

        try {
            ret = keyfile.has_key (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.has_key: key=%s: %s", key, err.message);
        }

        return ret;
    }

    public string[] get_string_list (string key) {
        string[] val = {};

        if (!has_key (key)) {
            return val;
        }

        try {
            val = keyfile.get_string_list (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_string_list: key=%s: %s", key, err.message);
        }

        return val;
    }

    public void set_boolean (string key, bool val) {
        if (val) {
            // Update the value when the corresponding entry has some value.
            keyfile.set_boolean (KeyFileDesktop.GROUP, key, val);
        } else {
            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key (key)) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError err) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, err.message);
                }
            }
        }
    }

    public void set_string (string key, string val) {
        if (val != "") {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string (KeyFileDesktop.GROUP, key, val);
        } else {
            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key (key)) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError err) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, err.message);
                }
            }
        }
    }

    public void set_string_list (string key, string[] list) {
        if (list.length > 0) {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string_list (KeyFileDesktop.GROUP, key, list);
        } else {
            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key (key)) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError err) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, err.message);
                }
            }
        }
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
    // Localized Key Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public string? get_locale_for_key (string key, string? locale = null) {
        return keyfile.get_locale_for_key (KeyFileDesktop.GROUP, key, locale);
    }

    public string get_locale_string (string key, string? locale = null) {
        string val = "";

        if (!has_key (key)) {
            return val;
        }

        try {
            val = keyfile.get_locale_string (KeyFileDesktop.GROUP, key, locale);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_locale_string: key=%s: %s", key, err.message);
        }

        return val;
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // File Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public bool load_file () {
        bool ret = false;

        try {
            ret = keyfile.load_from_file (path, KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (FileError err) {
            warning ("Failed to load from file. path=%s: %s", path, err.message);
        } catch (KeyFileError err) {
            warning ("Invalid keyfile. path=%s: %s", path, err.message);
        }

        return ret;
    }

    public bool save_file () {
        bool ret = false;

        try {
            ret = keyfile.save_to_file (path);
        } catch (FileError err) {
            warning ("Failed to save file. path=%s: %s", path, err.message);
        }

        return ret;
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
