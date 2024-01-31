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
                    if (!name.has_suffix (DesktopFileDefine.DESKTOP_SUFFIX)) {
                        continue;
                    }

                    // Add the desktop file found just now to the list
                    File relative_path = desktop_files_dir.resolve_relative_path (name);
                    var desktop_file = new DesktopFile.from_path (relative_path.get_path ());
                    _files.add (desktop_file);
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
     * The representation of the {@link desktop_files_path} in GLib.File type.
     */
    private File desktop_files_dir;

    /**
     * The language name that the user prefers in the system settings, e.g. "en_US", "ja_JP", etc.
     *
     * Used to show the KEY_NAME and KEY_COMMENT in the user's system language.
     */
    public unowned string preferred_language { get; private set; }

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

        Posix.mode_t cur_perm = sbuf.st_mode & DesktopFileDefine.PERMISSION_BIT;

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

}
