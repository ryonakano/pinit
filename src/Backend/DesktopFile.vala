/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A class to represents a single desktop file.
 */
public class DesktopFile : GLib.Object {
    public string path { get; private set; }

    private KeyFile keyfile = new KeyFile ();

    /**
     * The constructor.
     */
    public DesktopFile () throws FileError {
        string filename = "pinit-" + Uuid.string_random ();
        path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications",
                                    filename + DesktopFileDefine.DESKTOP_SUFFIX);

        try {
            save_file ();
        } catch (FileError e) {
            throw e;
        }
    }

    public DesktopFile.from_path (string path) throws KeyFileError, FileError {
        this.path = path;

        try {
            keyfile.load_from_file (path, KeyFileFlags.KEEP_TRANSLATIONS);
        } catch (FileError e) {
            throw e;
        } catch (KeyFileError e) {
            throw e;
        }
    }

    public void delete_file () throws Error {
        var f = File.new_for_path (path);

        try {
            f.delete ();
        } catch (Error e) {
            throw e;
        }
    }

    public string? get_locale_for_key (string key, string? locale = null) {
        return keyfile.get_locale_for_key (KeyFileDesktop.GROUP, key, locale);
    }

    public string get_locale_string (string key, string? locale = null) throws KeyFileError {
        return keyfile.get_locale_string (KeyFileDesktop.GROUP, key, locale);
    }

    public bool get_boolean (string key) throws KeyFileError {
        return keyfile.get_boolean (KeyFileDesktop.GROUP, key);
    }

    public string get_string (string key) throws KeyFileError {
        return keyfile.get_string (KeyFileDesktop.GROUP, key);
    }

    [ CCode ( array_length = true , array_length_type = "gsize" , array_null_terminated = true ) ]
    public string[] get_string_list (string key) throws KeyFileError {
        return keyfile.get_string_list (KeyFileDesktop.GROUP, key);
    }

    public bool has_key (string key) throws KeyFileError {
        return keyfile.has_key (KeyFileDesktop.GROUP, key);
    }

    public void save_file () throws FileError {
        save_to_file (path);
    }

    public void set_boolean (string key, bool value) {
        keyfile.set_boolean (KeyFileDesktop.GROUP, key, value);
    }

    public void set_string (string key, string str) {
        keyfile.set_string (KeyFileDesktop.GROUP, key, str);
    }

    public void set_string_list (string key, string[] list) {
        keyfile.set_string_list (KeyFileDesktop.GROUP, key, list);
    }

    /**
     * Update value of optional key to val.
     *
     * @param key       Name of the key to update.<<BR>>
     *                  The key is expected to be a optional key. Refer to [[https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html | Desktop Entry Specification]]
     *                  for which key is optional.
     * @param val       Value to set to key, in string.
     */
    public void set_optkey_string (string key, string val) {
        if (val != "") {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string (KeyFileDesktop.GROUP, key, val);
        } else {
            bool has_key = false;
            try {
                has_key = keyfile.has_key (KeyFileDesktop.GROUP, key);
            } catch (KeyFileError e) {
                warning ("Failed to check if the key exists (key: %s): %s", key, e.message);
            }

            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError e) {
                    warning ("Failed to remove the key (key: %s): %s", key, e.message);
                }
            }
        }
    }

    /**
     * Update value of optional key to val.
     *
     * @param key       Name of the key to update.<<BR>>
     *                  The key is expected to be a optional key. Refer to [[https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html | Desktop Entry Specification]]
     *                  for which key is optional.
     * @param val       Value to set to key, in boolean.
     */
    public void set_optkey_boolean (string key, bool val) {
        if (val) {
            // Update the value when the corresponding entry has some value.
            keyfile.set_boolean (KeyFileDesktop.GROUP, key, val);
        } else {
            bool has_key = false;
            try {
                has_key = keyfile.has_key (KeyFileDesktop.GROUP, key);
            } catch (KeyFileError e) {
                warning ("Failed to check if the key exists (key: %s): %s", key, e.message);
            }

            // Remove the key when it exists and the corresponding entry has no value.
            if (has_key) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, key);
                } catch (KeyFileError e) {
                    warning ("Failed to remove the key (key: %s): %s", key, e.message);
                }
            }
        }
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

    private bool load_from_file (string file, KeyFileFlags flags) throws KeyFileError, FileError {
        return keyfile.load_from_file (file, flags);
    }

    private void save_to_file (string file) throws FileError {
        try {
            keyfile.save_to_file (file);
        } catch (FileError e) {
            throw e;
        }
    }
}
