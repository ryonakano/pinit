/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Inspired from:
 * - https://github.com/elementary/switchboard-plug-keyboard/blob/caef4fd900b41c669d48fc1c91eced6a89709f62/src/Views/InputMethod.vala#L369
 * - https://github.com/pantheon-tweaks/pantheon-tweaks/blob/7d366f5e4774175be2d7177d1b8486e0c97d7bfe/src/Settings/ThemeSettings.vala#L62
 */

/**
 * The class to load desktop files and stores in the form of DesktopFile class.
 */
public class DesktopFileModel : GLib.Object {
    public signal void load_success ();
    public signal void load_failure ();

    public GLib.ListStore files_list { get; private set; }

    /**
     * The prefix of the desktop file.
     */
    public const string DESKTOP_SUFFIX = ".desktop";

    /**
     * The representation of the {@link desktop_files_path} in GLib.File type.
     */
    private File desktop_files_dir;

    public DesktopFileModel () {
    }

    construct {
        files_list = new GLib.ListStore (typeof (DesktopFile));

        string desktop_files_path = Path.build_filename (Environment.get_home_dir (), ".local/share/applications");
        desktop_files_dir = File.new_for_path (desktop_files_path);

        // Create the desktop files directory if not exists
        if (!FileUtils.test (desktop_files_path, FileTest.EXISTS)) {
            try {
                desktop_files_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
            }
        }
    }

    public bool load () {
        files_list.remove_all ();

        try {
            var enumerator = desktop_files_dir.enumerate_children (FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
            FileInfo file_info = null;

            // Check and address the files in the desktop_files_path directory one by one
            while ((file_info = enumerator.next_file ()) != null) {
                // We handle only the desktop file in this app, so ignore any files without the .desktop suffix
                string name = file_info.get_name ();
                if (!name.has_suffix (DESKTOP_SUFFIX)) {
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

                files_list.append (file);
            }
        } catch (Error e) {
            warning (e.message);
            load_failure ();
            return false;
        }

        load_success ();
        return true;
    }
}
