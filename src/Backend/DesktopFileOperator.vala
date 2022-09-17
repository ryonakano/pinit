/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Inspired from:
 * - elementary/switchboard-plug-keyboard, #374
 * - pantheon-tweaks/pantheon-tweaks, src/Settings/ThemeSettings.vala
 */

public class DesktopFileOperator : GLib.Object {
    /*
     * A singleton class to handle desktop files in the DesktopFile type.
     */

    /*
     * These signals are emitted when some desktop file is created/updated or deleted.
     * We catch this signal in the front end and tell users these changes using the toast.
     */
    public signal void file_updated ();
    public signal void file_deleted ();

    // The list of desktop files in the GLib.DesktopAppInfo data type.
    public Gee.ArrayList<GLib.DesktopAppInfo> files {
        get {
            _files.clear ();

            try {
                var emumerator = desktop_dir.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
                FileInfo file_info = null;

                // Check and address the files in the DESTINATION_PATH directory one by one
                while ((file_info = emumerator.next_file ()) != null) {
                    // We handle only the desktop file in this app, so ignore any files without the .desktop suffix
                    string name = file_info.get_name ();
                    if (!name.has_suffix (DESKTOP_SUFFIX)) {
                        continue;
                    }

                    // Add the desktop file found just now to the list
                    var desktop_file = new GLib.DesktopAppInfo.from_filename (Path.build_filename (DESTINATION_PATH, name));
                    _files.add (desktop_file);
                }
            } catch (Error e) {
                warning (e.message);
            }

            return _files;
        }
    }
    private Gee.ArrayList<GLib.DesktopAppInfo> _files = new Gee.ArrayList<GLib.DesktopAppInfo> ();

    /*
     * We don't want to override these two strings so it's desired to declare as `const`,
     * but couldn't because of the compiling error.
     * Also we're telling the vala linter not to warn about using UPPER_SNAKE_CASE with non-const variables here.
     */
    // The path all of the user desktop files are saved.
    private string DESTINATION_PATH { //vala-lint=naming-convention
        private get;
        default = "/home/%s/.local/share/applications".printf (Environment.get_user_name ());
    }

    // The path where this app automatically saves the latest state of unsaved changes
    private string UNSAVED_FILE_PATH { //vala-lint=naming-convention
        private get;
        default = Environment.get_user_cache_dir ();
    }

    private const string DESKTOP_SUFFIX = ".desktop";
    private const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;

    // The representation of the destination path in GLib.File type
    private File desktop_dir;

    // We uses this info to show the KEY_NAME and KEY_COMMENT in the user's system language
    private string preferred_language;

    // This object is singleton because it's kind of a manager of desktop files
    public static DesktopFileOperator get_default () {
        if (_instance == null) {
            _instance = new DesktopFileOperator ();
        }

        return _instance;
    }
    private static DesktopFileOperator _instance;

    private DesktopFileOperator () {
        // Get the user's system language and use it when loading/creating desktop files
        var languages = Intl.get_language_names ();
        preferred_language = languages[0];

        // Create the destination directory if not existing
        desktop_dir = File.new_for_path (DESTINATION_PATH);
        if (!FileUtils.test (DESTINATION_PATH, FileTest.EXISTS)) {
            try {
                desktop_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    /*
     * Create the new and blank desktop file.
     */
    public GLib.DesktopAppInfo? create_new () {
        DesktopFileOperator.get_default ().delete_backup ();
        //  return new DesktopFile ();
        return new GLib.DesktopAppInfo ("com.github.ryonakano.test.desktop");
    }

    /*
     * Write the content of `desktop_file@ into the desktop file at `desktop_file.file_name` through KeyFile object.
     */
    public void write_to_file (DesktopFile desktop_file) {
        var keyfile = new KeyFile ();

        keyfile.set_locale_string (
            KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language, desktop_file.app_name
        );

        keyfile.set_locale_string (
            KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language, desktop_file.comment
        );

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, desktop_file.exec_file);

        if (desktop_file.icon_file != "") {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON, desktop_file.icon_file);
        } else {
            bool has_icon_key = false;
            try {
                has_icon_key = keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON);
            } catch (KeyFileError e) {
                warning ("Failed to check if the key \"Icon\" exists: %s", e.message);
            }

            /*
             * Section "Icon" is not required.
             * Remove the key when it exists and the corresponding entry has no value.
             */
            if (has_icon_key) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON);
                } catch (KeyFileError e) {
                    warning ("Failed to remove the blank key \"Icon\": %s", e.message);
                }
            }
        }

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES, desktop_file.categories);

        if (desktop_file.startup_wm_class != "") {
            // Update the value when the corresponding entry has some value.
            keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_STARTUP_WM_CLASS, desktop_file.startup_wm_class);
        } else {
            bool has_startup_wm_class_key = false;
            try {
                has_startup_wm_class_key = keyfile.has_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_STARTUP_WM_CLASS);
            } catch (KeyFileError e) {
                warning ("Failed to check if the key \"StartupWMClass\" exists: %s", e.message);
            }

            /*
             * Section "StartupWMClass" is not required.
             * Remove the key when it exists and the corresponding entry has no value.
             */
            if (has_startup_wm_class_key) {
                try {
                    keyfile.remove_key (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_STARTUP_WM_CLASS);
                } catch (KeyFileError e) {
                    warning ("Failed to remove the blank key \"StartupWMClass\": %s", e.message);
                }
            }
        }

        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TYPE, "Application");

        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL, desktop_file.is_cli);

        /*
         * Setup the filename and saving destination depending on if it's a backup file that
         * the app automatically saves the latest state, or the actual desktop file that
         * users saved clicking by the "Save" button.
         */
        string path;
        if (desktop_file.is_backup) {
            path = Path.build_filename (UNSAVED_FILE_PATH, desktop_file.file_name + DESKTOP_SUFFIX);
            // Get the app remember that it should automatically show this file in the next time app launched
            Application.settings.set_string ("last-edited-file", path);
        } else {
            path = Path.build_filename (DESTINATION_PATH, desktop_file.file_name + DESKTOP_SUFFIX);
            // Delete the backup because unsaved work is now saved
            delete_backup ();
        }

        try {
            keyfile.save_to_file (path);
        } catch (Error e) {
            warning ("Could not write to file %s: %s", path, e.message);
        }

        file_updated ();
    }

    /*
     * Add executable permission to the given file at `path`.
     * @return: 0 when succeed and 1 when failed.
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

    /*
     * Get an unsaved file if exists.
     * @return: The unsaved file in the DesktopFile type. `null` when none exists
     */
    public GLib.DesktopAppInfo? get_unsaved_file () {
        string last_edited_file = Application.settings.get_string ("last-edited-file");

        if (last_edited_file != "") {
            return new GLib.DesktopAppInfo.from_filename (last_edited_file);
        } else {
            return null;
        }
    }

    /*
     * Delete an unsaved file in the backup directory if exists.
     */
    public void delete_backup () {
        string unsaved_file_path = Application.settings.get_string ("last-edited-file");
        if (unsaved_file_path != "") {
            // It tells unsaved work exists, so try deleting it and clearing that info
            delete_from_path (unsaved_file_path);
            Application.settings.set_string ("last-edited-file", "");
        }
    }

    /*
     * Delete the given desktop file from the storage.
     */
    public void delete_file (GLib.DesktopAppInfo desktop_file) {
        delete_from_path (Path.build_filename (DESTINATION_PATH, desktop_file.filename + DESKTOP_SUFFIX));
        file_deleted ();
    }

    /*
     * Delete the given file from the storage if it really exists.
     */
    private void delete_from_path (string path) {
        var file = File.new_for_path (path);
        if (file.query_exists ()) {
            try {
                file.delete ();
            } catch (Error e) {
                warning ("Could not delete file %s: %s", path, e.message);
            }
        }
    }
}
