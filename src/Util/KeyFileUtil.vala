/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * Definitions and wrapper methods related to KeyFile.
 */
namespace Util.KeyFileUtil {
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
     * The language name that the user prefers in the system settings, e.g. "en_US", "ja_JP", etc.
     *
     * Used to show the ``KEY_NAME`` and ``KEY_COMMENT`` in the user's system language.
     */
    private static unowned string? preferred_language = null;
    private static unowned string get_preferred_language () {
        if (preferred_language == null) {
            unowned var languages = Intl.get_language_names ();
            preferred_language = languages[0];
        }

        return preferred_language;
    }

    /**
     * Check if two KeyFiles have the same content.
     *
     * @param a KeyFile to compare
     * @param b KeyFile to compare
     * @return true if two KeyFiles have the same content
     */
    public static bool equals (KeyFile a, KeyFile b) {
        string a_data = a.to_data ();
        string b_data = b.to_data ();

        return a_data == b_data;
    }

    /**
     * Sync content of KeyFile between.
     *
     * @param src KeyFile to be copied from
     * @param dst KeyFile to be copied to
     * @return true if successfully copied, false otherwise
     */
    public static bool copy (KeyFile dst, KeyFile src) {
        string data = src.to_data ();

        try {
            dst.load_from_data (data, data.length, KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.load_from_data: %s", err.message);
            return false;
        }

        return true;
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // Key Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    /**
     * Return the value associated with ``key``.
     *
     * @param keyfile   a ``KeyFile``
     * @param key       a key
     * @return          the value associated with the key
     */
    public delegate Value GetValueFunc (KeyFile keyfile, string key) throws KeyFileError;
    /**
     * Associates a new value with ``key``.
     *
     * If ``key`` cannot be found then it is created.
     *
     * @param keyfile   a ``KeyFile``
     * @param key       a key
     * @param val       a value to associate
     */
    public delegate void SetValueFunc (KeyFile keyfile, string key, Value val);

    /**
     * Return the value associated with ``key``.
     *
     * @param keyfile   a ``KeyFile``
     * @param key       a key
     * @param get_func  a function to actually get value from ``keyfile``
     * @return          the value associated with the key, or null if the key was not found or could not be parsed
     */
    public static Value? get_value (KeyFile keyfile, string key, GetValueFunc get_func) {
        Value? val = null;

        if (!has_key (keyfile, key)) {
            return val;
        }

        try {
            val = get_func (keyfile, key);
        } catch (KeyFileError err) {
            warning ("Failed to get value from keyfile: key=%s: %s", key, err.message);
        }

        return val;
    }

    /**
     * Associates a new value with ``key``.
     *
     * If ``key`` cannot be found then it is created. If ``val`` is ``null`` then ``key`` is removed.
     *
     * @param keyfile   a ``KeyFile``
     * @param key       a key
     * @param val       a value to associate or ``null`` to remove ``key``
     * @param set_func  a function to actually set value to ``keyfile``
     */
    public static void set_value (KeyFile keyfile, string key, Value? val, SetValueFunc set_func) {
        if (val != null) {
            // Update the value when the corresponding entry has some value.
            set_func (keyfile, key, val);
        } else {
            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key (keyfile, key)) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError err) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, err.message);
                }
            }
        }
    }

    public static Value get_boolean (KeyFile keyfile, string key) throws KeyFileError {
        return keyfile.get_boolean (KeyFileDesktop.GROUP, key);
    }

    public static void set_boolean (KeyFile keyfile, string key, Value val) {
        keyfile.set_boolean (KeyFileDesktop.GROUP, key, (bool) val);
    }

    public static Value get_string (KeyFile keyfile, string key) throws KeyFileError {
        return keyfile.get_string (KeyFileDesktop.GROUP, key);
    }

    public static void set_string (KeyFile keyfile, string key, Value val) {
        keyfile.set_string (KeyFileDesktop.GROUP, key, (string) val);
    }

    public static Value get_strv (KeyFile keyfile, string key) throws KeyFileError {
        return keyfile.get_string_list (KeyFileDesktop.GROUP, key);
    }

    public static void set_strv (KeyFile keyfile, string key, Value val) {
        keyfile.set_string_list (KeyFileDesktop.GROUP, key, (string[]) val);
    }

    public static Value get_locale_string (KeyFile keyfile, string key) throws KeyFileError {
        string? locale = keyfile.get_locale_for_key (KeyFileDesktop.GROUP, key, get_preferred_language ());

        return keyfile.get_locale_string (KeyFileDesktop.GROUP, key, locale);
    }

    public static bool has_key (KeyFile keyfile, string key) {
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

    ////////////////////////////////////////////////////////////////////////////
    //
    // File Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public static bool load_file (KeyFile keyfile, string path, KeyFileFlags flags) {
        bool ret = false;

        try {
            ret = keyfile.load_from_file (path, flags);
        } catch (FileError err) {
            warning ("Failed to load from file. path=%s: %s", path, err.message);
        } catch (KeyFileError err) {
            warning ("Invalid keyfile. path=%s: %s", path, err.message);
        }

        return ret;
    }

    public static bool save_file (KeyFile keyfile, string path) {
        bool ret = false;

        try {
            ret = keyfile.save_to_file (path);
        } catch (FileError err) {
            warning ("Failed to save file. path=%s: %s", path, err.message);
        }

        return ret;
    }
}
