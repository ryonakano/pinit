/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Inspired from:
 * - https://github.com/elementary/switchboard-plug-keyboard/blob/caef4fd900b41c669d48fc1c91eced6a89709f62/src/Views/InputMethod.vala#L369
 * - https://github.com/pantheon-tweaks/pantheon-tweaks/blob/7d366f5e4774175be2d7177d1b8486e0c97d7bfe/src/Settings/ThemeSettings.vala#L62
 */

/**
 * The class to manage desktop file.
 */
public class DesktopFileOperator : GLib.Object {
    /**
     * The list of desktop files in the {@link DesktopFile} data type.
     *
     * Getting this search ~/.local/share/applications for files with .desktop suffix. Create a new
     * {@link DesktopFile} if a matching file found. Repeat this for all files in the directory
     * and then return the list of {@link DesktopFile}.
     */
    public Gee.ArrayList<DesktopFile> files {
        get {
            _files.clear ();

            try {
                var emumerator = desktop_files_dir.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                // Check and address the files in the desktop_files_path directory one by one
                while ((file_info = emumerator.next_file ()) != null) {
                    // We handle only the desktop file in this app, so ignore any files without the .desktop suffix
                    string name = file_info.get_name ();
                    if (!name.has_suffix (DESKTOP_SUFFIX)) {
                        continue;
                    }

                    // Add the desktop file found just now to the list
                    var desktop_file = load_from_file (Path.build_filename (desktop_files_path, name));
                    if (desktop_file != null) {
                        _files.add (desktop_file);
                    }
                }
            } catch (Error e) {
                warning (e.message);
            }

            return _files;
        }
    }
    private Gee.ArrayList<DesktopFile> _files = new Gee.ArrayList<DesktopFile> ();

    /**
     * The path where desktop files are saved.
     *
     * Not intended to be overwritten after initialization.
     */
    private string desktop_files_path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications");

    /**
     * The path where the app saves the latest state of unsaved works.
     *
     * Not intended to be overwritten after initialization.
     */
    private string backup_path = Environment.get_user_cache_dir ();

    /**
     * The prefix of the desktop file.
     */
    private const string DESKTOP_SUFFIX = ".desktop";
    private const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;

    /**
     * The representation of the {@link desktop_files_path} in GLib.File type.
     */
    private File desktop_files_dir;

    /**
     * The language name that the user prefers in the system settings, e.g. "en_US", "ja_JP", etc.
     *
     * Used to show the KEY_NAME and KEY_COMMENT in the user's system language.
     */
    private unowned string preferred_language;

    /**
     * Get the default instance of this.
     *
     * @return          The default instance of {@link DesktopFileOperator}.
     */
    public static DesktopFileOperator get_default () {
        if (_instance == null) {
            _instance = new DesktopFileOperator ();
        }

        return _instance;
    }
    private static DesktopFileOperator _instance;

    /**
     * The constructor.
     */
    private DesktopFileOperator () {
        // Get the user's system language and use it when loading desktop files
        unowned var languages = Intl.get_language_names ();
        preferred_language = languages[0];

        // Create the destination directory if not exists
        desktop_files_dir = File.new_for_path (desktop_files_path);
        if (!FileUtils.test (desktop_files_path, FileTest.EXISTS)) {
            try {
                desktop_files_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    /**
     * Create the new and blank desktop file.
     *
     * @return          A new {@link DesktopFile}.
     */
    public DesktopFile create_new () {
        DesktopFileOperator.get_default ().delete_backup ();
        return new DesktopFile ();
    }

    /**
     * Update value of optional key to val.
     *
     * @param keyfile   Keyfile to update.
     * @param key       Name of the key to update.<<BR>>
     *                  The key needs to be a optional key. Refer to [[https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html | Desktop Entry Specification]]
     *                  for which key is optional.
     * @param val       Value to set to key, in string.
     */
    private void update_optkey_with_string (KeyFile keyfile, string key, string val) {
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
     * @param keyfile   Keyfile to update.
     * @param key       Name of the key to update.<<BR>>
     *                  The key needs to be a optional key. Refer to [[https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html | Desktop Entry Specification]]
     *                  for which key is optional.
     * @param val       Value to set to key, in boolean.
     */
    private void update_optkey_with_boolean (KeyFile keyfile, string key, bool val) {
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
     * Write the content of desktop_file to the path specified in desktop_file.file_name through KeyFile object.
     *
     * @throws Error    An error while saving the file to the path.
     */
    public void write_to_file (DesktopFile desktop_file) throws Error {
        var keyfile = new KeyFile ();

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, desktop_file.app_name);

        update_optkey_with_string (keyfile, KeyFileDesktop.KEY_COMMENT, desktop_file.comment);

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, desktop_file.exec_file);

        update_optkey_with_string (keyfile, KeyFileDesktop.KEY_ICON, desktop_file.icon_file);

        update_optkey_with_string (keyfile, KeyFileDesktop.KEY_CATEGORIES, desktop_file.categories);

        update_optkey_with_string (keyfile, KeyFileDesktop.KEY_STARTUP_WM_CLASS, desktop_file.startup_wm_class);

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TYPE, "Application");

        update_optkey_with_boolean (keyfile, KeyFileDesktop.KEY_TERMINAL, desktop_file.is_cli);

        /*
         * Setup the filename and saving destination depending on if it's a backup file that
         * the app automatically saves the latest state, or the actual desktop file that
         * users saved clicking by the "Save" button.
         */
        string path;
        if (desktop_file.is_backup) {
            path = Path.build_filename (backup_path, desktop_file.file_name + DESKTOP_SUFFIX);
            // Get the app remember that it should automatically show this file in the next time app launched
            Application.settings.set_string ("last-edited-file", path);
        } else {
            path = Path.build_filename (desktop_files_path, desktop_file.file_name + DESKTOP_SUFFIX);
            // Delete the backup because unsaved work is now saved
            delete_backup ();
        }

        try {
            keyfile.save_to_file (path);
        } catch (Error e) {
            throw e;
        }
    }

    /**
     * Load the content of the desktop file at path and construct new {@link DesktopFile} through KeyFile object.
     *
     * @param path      The path where to load from.
     * @return          A new {@link DesktopFile} or null if failed.
     */
    public DesktopFile? load_from_file (string path) {
        string file_name = "";
        string app_name = "";
        string comment = "";
        string exec_file = "";
        string icon_file = "";
        string categories = "";
        string startup_wm_class = "";
        bool is_cli = false;
        bool is_backup = false;

        try {
            var keyfile = new KeyFile ();
            keyfile.load_from_file (path, KeyFileFlags.KEEP_TRANSLATIONS);

            string basename = Path.get_basename (path);

            // Get the filename without the .desktop suffix
            file_name = basename.slice (0, basename.length - DESKTOP_SUFFIX.length);

            string locale = keyfile.get_locale_for_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language);
            app_name = keyfile.get_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, locale);

            locale = keyfile.get_locale_for_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language);
            bool has_key = keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT);
            // Either has a localized or unlocalized Comment key
            if (locale != null || has_key) {
                comment = keyfile.get_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, locale);
            }

            exec_file = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC);

            if (keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON)) {
                icon_file = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON);
            }

            if (keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES)) {
                categories = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES);
            }

            if (keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_STARTUP_WM_CLASS)) {
                startup_wm_class = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_STARTUP_WM_CLASS);
            }

            if (keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL)) {
                is_cli = keyfile.get_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL);
            }

            is_backup = backup_path in path;
        } catch (KeyFileError e) {
            warning (e.message);
            return null;
        } catch (FileError e) {
            warning (e.message);
            return null;
        }

        var desktop_file = new DesktopFile (
            file_name,
            app_name,
            comment,
            exec_file,
            icon_file,
            categories,
            startup_wm_class,
            is_cli,
            is_backup
        );

        return desktop_file;
    }

    /**
     * Add executable permission to the given file at path.
     *
     * @return          0 when succeed, 1 otherwise.
     */
    public int add_exec_permission (string path) {
        int ret;
        Posix.Stat sbuf;

        ret = Posix.stat (path, out sbuf);
        if (ret != 0) {
            warning ("Failed to get the current mode of '%s': %s",
                    path, Posix.strerror (Posix.errno));
            return 1;
        }

        Posix.mode_t cur_perm = sbuf.st_mode & PERMISSION_BIT;

        /*
         * If the current user already has exec permission to the specified file,
         * do nothing.
         */
        if ((cur_perm & Posix.S_IXUSR) == Posix.S_IXUSR) {
            return 0;
        }

        ret = Posix.chmod (path, cur_perm | Posix.S_IXUSR);
        if (ret != 0) {
            warning ("Failed to give exec permission to '%s': %s",
                    path, Posix.strerror (Posix.errno));
            return 1;
        }

        return 0;
    }

    /**
     * Get an unsaved file if exists.
     *
     * @return          The unsaved file in the {@link DesktopFile} type. Returns null when none exists.
     */
    public DesktopFile? get_unsaved_file () {
        string last_edited_file = Application.settings.get_string ("last-edited-file");
        return last_edited_file != "" ? load_from_file (last_edited_file) : null;
    }

    /**
     * Delete an unsaved file in the backup directory if exists.
     */
    public void delete_backup () {
        string unsaved_file_path = Application.settings.get_string ("last-edited-file");
        if (unsaved_file_path != "") {
            // It tells unsaved work exists, so try deleting it and clearing that info
            try {
                delete_from_path (unsaved_file_path);
                Application.settings.set_string ("last-edited-file", "");
            } catch (Error e) {
                warning ("Failed to delete the backup: %s", e.message);
            }
        }
    }

    /**
     * Delete the given desktop file from the storage.
     *
     * @param desktop_file      The {@link DesktopFile} to delete
     * @throws Error            An error while deleting file.
     */
    public void delete_file (DesktopFile desktop_file) throws Error {
        try {
            delete_from_path (Path.build_filename (desktop_files_path, desktop_file.file_name + DESKTOP_SUFFIX));
        } catch (Error e) {
            throw e;
        }
    }

    /**
     * Delete the given file from the storage if exists.
     *
     * @param path      The path of the file to delete.
     * @throws Error    An error while deleting file.
     */
    private void delete_from_path (string path) throws Error {
        var file = File.new_for_path (path);
        if (file.query_exists ()) {
            try {
                file.delete ();
            } catch (Error e) {
                throw e;
            }
        }
    }

    /**
     * Open the specified file in an external editor.
     *
     * @param file_name The path of the file to open.
     * @throws Error    An error while opening.
     */
    public void open_external (string file_name) throws Error {
        try {
            ExternalAppLauncher.open_default_handler (Path.build_filename (desktop_files_path, file_name + DESKTOP_SUFFIX));
        } catch (Error e) {
            throw e;
        }
    }
}
