/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class to represents a single desktop file.
 */
public class Model.DesktopFile : Object {
    /**
     * The path of the desktop file.
     */
    public string path { get; construct; }

    /**
     * The prefix of the desktop file.
     */
    public const string DESKTOP_SUFFIX = ".desktop";

    private KeyFile keyfile;

    /**
     * The constructor.
     *
     * @param path The path to the desktop file.
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
     * Returns true if this and other contains the same values.
     *
     * @param other Another DesktopFile.
     * @return true if this and other contains the same values.
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
     * @param dest Another DesktopFile to copy this data to.
     * @return true if successfully copied, false otherwise.
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

    public bool get_boolean (string key, bool is_required = true) {
        bool val = false;

        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return val;
        }

        // Return if the key is not required and does not exist.
        if (!is_required) {
            if (!has_key (key)) {
                return val;
            }
        }

        try {
            val = keyfile.get_boolean (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.get_boolean: key=%s: %s", key, e.message);
        }

        return val;
    }

    public string get_string (string key, bool is_required = true) {
        string val = "";

        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return val;
        }

        // Return if the key is not required and does not exist.
        if (!is_required) {
            if (!has_key (key)) {
                return val;
            }
        }

        try {
            val = keyfile.get_string (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.get_string: key=%s: %s", key, e.message);
        }

        return val;
    }

    public bool has_key (string key) {
        bool ret = false;

        try {
            ret = keyfile.has_key (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.has_key: key=%s: %s", key, e.message);
        }

        return ret;
    }

    public string[] get_string_list (string key, bool is_required = true) {
        string[] val = {};

        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return val;
        }

        // Return if the key is not required and does not exist.
        if (!is_required) {
            if (!has_key (key)) {
                return val;
            }
        }

        try {
            val = keyfile.get_string_list (KeyFileDesktop.GROUP, key);
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.get_string_list: key=%s: %s", key, e.message);
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
                } catch (KeyFileError e) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, e.message);
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
                } catch (KeyFileError e) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, e.message);
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
                } catch (KeyFileError e) {
                    warning ("Failed to KeyFile.remove_key: key=%s: %s", key, e.message);
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
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.load_from_data: %s", e.message);
        }

        return ret;
    }

    ////////////////////////////////////////////////////////////////////////////
    //
    // Localized Key Opearations
    //
    ////////////////////////////////////////////////////////////////////////////

    public string? get_locale_for_key (string key, string? locale = null) {
        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return null;
        }

        return keyfile.get_locale_for_key (KeyFileDesktop.GROUP, key, locale);
    }

    public string get_locale_string (string key, string? locale = null, bool is_required = true) {
        string val = "";

        // Maybe keyfile is new and has no key yet
        if (!keyfile.has_group (KeyFileDesktop.GROUP)) {
            return val;
        }

        // Return if the key is not required and does not exist.
        if (!is_required) {
            if (!has_key (key)) {
                return val;
            }
        }

        try {
            val = keyfile.get_locale_string (KeyFileDesktop.GROUP, key, locale);
        } catch (KeyFileError e) {
            warning ("Failed to KeyFile.get_locale_string: key=%s: %s", key, e.message);
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
        } catch (FileError e) {
            warning ("Failed to load from file. path=%s: %s", path, e.message);
        } catch (KeyFileError e) {
            warning ("Invalid keyfile. path=%s: %s", path, e.message);
        }

        return ret;
    }

    public bool save_file () {
        bool ret = false;

        try {
            ret = keyfile.save_to_file (path);
        } catch (FileError e) {
            warning ("Failed to save file. path=%s: %s", path, e.message);
        }

        return ret;
    }

    public bool delete_file () {
        var file = File.new_for_path (path);
        bool ret = false;

        try {
            ret = file.delete ();
        } catch (Error e) {
            warning ("Failed to delete file. path=%s: %s", path, e.message);
        }

        return ret;
    }

    /**
     * Open this in an external editor.
     *
     * @param parent the parent GtkWindow
     * @return true if successfully opened this, false otherwise.
     * @throws Error failed to open this externally.
     */
    public async bool open_external (Gtk.Window? parent) throws Error {
        var file = File.new_for_path (path);

        var file_launcher = new Gtk.FileLauncher (file) {
            always_ask = true
        };

        bool ret = false;
        try {
            ret = yield file_launcher.launch (parent, null);
        } catch (Error e) {
            warning ("Failed to open file externally. path=%s: %s", path, e.message);
            throw e;
        }

        return ret;
    }
}
