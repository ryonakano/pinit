/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Inspired from:
 * - https://github.com/elementary/switchboard-plug-keyboard/blob/caef4fd900b41c669d48fc1c91eced6a89709f62/src/Views/InputMethod.vala#L369
 * - https://github.com/pantheon-tweaks/pantheon-tweaks/blob/7d366f5e4774175be2d7177d1b8486e0c97d7bfe/src/Settings/ThemeSettings.vala#L62
 */

/**
 * The class to load desktop files and store them in the type of {@link DesktopFile}.
 */
public class Model.DesktopFileModel : Object {
    /**
     * Notifies loading desktop files succeeded.
     */
    public signal void load_success ();

    /**
     * Notifies loading desktop files failed.
     */
    public signal void load_failure ();

    /**
     * List of {@link DesktopFile}.
     */
    public Gee.ArrayList<DesktopFile> files_list { get; private set; }

    /**
     * The directory where user desktop files are stored.
     */
    private string desktop_files_path;

    public DesktopFileModel () {
    }

    construct {
        files_list = new Gee.ArrayList<DesktopFile> ();

        desktop_files_path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications");

        // Create the desktop files directory if not exists
        if (!FileUtils.test (desktop_files_path, FileTest.EXISTS)) {
            var desktop_files_dir = File.new_for_path (desktop_files_path);

            try {
                desktop_files_dir.make_directory_with_parents ();
            } catch (Error err) {
                warning ("Failed to make directory. path=%s: %s", desktop_files_path, err.message);
            }
        }
    }

    /**
     * Search for desktop files and store in the {@link DesktopFile} data type.
     *
     * Search ``~/.local/share/applications`` for files with .desktop suffix. Create a new
     * {@link DesktopFile} if a matching file found and is valid. Repeat this for all files in the directory.
     *
     * Emits {@link load_success} if loaded successfully, {@link load_failure} otherwise.
     */
    public async void load () {
        bool is_success = false;

        new Thread<void> (null, () => {
            files_list.clear ();

            var desktop_files_dir = File.new_for_path (desktop_files_path);
            FileEnumerator enumerator;
            try {
                enumerator = desktop_files_dir.enumerate_children (FileAttribute.STANDARD_NAME,
                                                                   FileQueryInfoFlags.NONE);
            } catch (Error err) {
                warning ("Failed to get information of files: %s", err.message);
                // Schedule to let the UI thread resume from the yield sentence.
                Idle.add (load.callback);
                return;
            }

            FileInfo file_info;
            try {
                // Check all files in the directory one by one
                while ((file_info = enumerator.next_file ()) != null) {
                    // Ignore any files without the .desktop suffix
                    string name = file_info.get_name ();
                    if (!name.has_suffix (DesktopFile.DESKTOP_SUFFIX)) {
                        continue;
                    }

                    File relative_path = desktop_files_dir.resolve_relative_path (name);
                    string path = relative_path.get_path ();

                    var file = new DesktopFile (path);
                    bool ret = file.load_file ();
                    // Skip adding to the list if we fail to load.
                    if (!ret) {
                        continue;
                    }

                    files_list.add (file);
                }
            } catch (Error err) {
                warning ("Failed to load file info: %s", err.message);
                // Schedule to let the UI thread resume from the yield sentence.
                Idle.add (load.callback);
                return;
            }

            is_success = true;
            // Schedule to let the UI thread resume from the yield sentence.
            Idle.add (load.callback);
        });

        // Give up control of the CPU to the calling method.
        yield;

        if (is_success) {
            load_success ();
        } else {
            load_failure ();
        }
    }

    /**
     * Create a new {@link DesktopFile} with random filename.
     *
     * @return Created {@link DesktopFile}
     */
    public Model.DesktopFile create_file () {
        string filename = Config.APP_ID + "." + Uuid.string_random ();
        string path = Path.build_filename (
            desktop_files_path,
            filename + Model.DesktopFile.DESKTOP_SUFFIX
        );

        var file = new Model.DesktopFile (path);

        files_list.add (file);

        return file;
    }

    /**
     * Delete desktop file from list and the disk.
     *
     * @param file A {@link DesktopFile} to delete
     * @return true if succeeded, false otherwise
     */
    public bool delete_file (Model.DesktopFile file) {
        bool ret = delete_from_disk (file.path);
        if (!ret) {
            return false;
        }

        files_list.remove (file);

        return true;
    }

    /**
     * Delete file at path from the disk.
     *
     * @param path A file to delete
     * @return true if succeeded, false otherwise
     */
    private bool delete_from_disk (string path) {
        var file = File.new_for_path (path);

        if (!file.query_exists ()) {
            return true;
        }

        bool ret = false;
        try {
            ret = file.delete ();
        } catch (Error err) {
            warning ("Failed to delete file. path=%s: %s", path, err.message);
        }

        return ret;
    }
}
