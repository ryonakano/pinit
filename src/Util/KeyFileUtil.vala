/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
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
     * Return the value associated with ``key`` as a boolean.
     *
     * @param keyfile a KeyFile
     * @param key a key
     * @return the value associated with the key as a boolean, or false if the key was not found or could not be parsed
     * @see GLib.KeyFile.get_boolean
     */
    public static bool get_boolean (KeyFile keyfile, string key) {
        bool val = false;

        if (!has_key (keyfile, key)) {
            return val;
        }

        try {
            val = keyfile.get_boolean (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_boolean: key=%s: %s", key, err.message);
        }

        return val;
    }

    public static string get_string (KeyFile keyfile, string key) {
        string val = "";

        if (!has_key (keyfile, key)) {
            return val;
        }

        try {
            val = keyfile.get_string (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_string: key=%s: %s", key, err.message);
        }

        return val;
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

    public static string[] get_string_list (KeyFile keyfile, string key) {
        string[] val = {};

        if (!has_key (keyfile, key)) {
            return val;
        }

        try {
            val = keyfile.get_string_list (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError err) {
            warning ("Failed to KeyFile.get_string_list: key=%s: %s", key, err.message);
        }

        return val;
    }

    public static void set_boolean (KeyFile keyfile, string key, bool val) {
        if (val) {
            // Update the value when the corresponding entry has some value.
            keyfile.set_boolean (KeyFileDesktop.GROUP, key, val);
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

    public static void set_string (KeyFile keyfile, string key, string val) {
        if (val != "") {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string (KeyFileDesktop.GROUP, key, val);
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

    public static void set_string_list (KeyFile keyfile, string key, string[] list) {
        if (list.length > 0) {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string_list (KeyFileDesktop.GROUP, key, list);
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

    ////////////////////////////////////////////////////////////////////////////
    //
    // Localized Key Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public static string? get_locale_for_key (KeyFile keyfile, string key, string? locale = null) {
        return keyfile.get_locale_for_key (KeyFileDesktop.GROUP, key, locale);
    }

    public static string get_locale_string (KeyFile keyfile, string key, string? locale = null) {
        string val = "";

        if (!has_key (keyfile, key)) {
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
