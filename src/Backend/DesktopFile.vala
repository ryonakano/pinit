/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class to represents a single desktop file.
 */
public class DesktopFile : GLib.Object {
    public string path { get; construct; }

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

    public void set_boolean (string key, bool val, bool is_required = true) {
        // Just set in case of required keys
        if (is_required) {
            keyfile.set_boolean (KeyFileDesktop.GROUP, key, val);
            return;
        }

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

    public void set_string (string key, string val, bool is_required = true) {
        // Just set in case of required keys
        if (is_required) {
            keyfile.set_string (KeyFileDesktop.GROUP, key, val);
            return;
        }

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

    public void set_string_list (string key, string[] list, bool is_required = true) {
        // Just set in case of required keys
        if (is_required) {
            keyfile.set_string_list (KeyFileDesktop.GROUP, key, list);
            return;
        }

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

    public void load_file (KeyFileFlags flags) throws KeyFileError, FileError {
        try {
            keyfile.load_from_file (path, flags);
        } catch (FileError e) {
            throw e;
        } catch (KeyFileError e) {
            throw e;
        }
    }

    public void save_file () throws FileError {
        try {
            keyfile.save_to_file (path);
        } catch (FileError e) {
            throw e;
        }
    }

    public bool delete_file () throws Error {
        var file = File.new_for_path (path);
        bool ret;

        try {
            ret = file.delete ();
        } catch (Error e) {
            throw e;
        }

        return ret;
    }

    /**
     * Open the specified file in an external editor.
     *
     * @throws Error    An error while opening.
     */
    public void open_external () throws Error {
        try {
            ExternalAppLauncher.open_default_handler (path);
        } catch (Error e) {
            throw e;
        }
    }
}
