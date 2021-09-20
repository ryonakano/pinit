/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Code borrowed from elementary/switchboard-plug-keyboard#374
 */

public class DesktopFileOperator : GLib.Object {
    private string startup_dir;

    public static DesktopFileOperator get_default () {
        if (_instance == null) {
            _instance = new DesktopFileOperator ();
        }

        return _instance;
    }
    private static DesktopFileOperator _instance;

    private DesktopFileOperator () {
    }

    public void init () {
        // Get path to user's startup directory (typically ~/.local/share/application)
        var data_dir = Environment.get_user_data_dir ();
        startup_dir = Path.build_filename (data_dir, "application");

        // If startup directory doesn't exist, create it.
        if (!FileUtils.test (startup_dir, FileTest.EXISTS)) {
            var file = File.new_for_path (startup_dir);

            try {
                file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
                return;
            }
        }
    }

    public void write_to_file (DesktopFile desktop_file) {
        var languages = Intl.get_language_names ();
        var preferred_language = languages [0];

        var keyfile = new GLib.KeyFile ();
        keyfile.set_locale_string (
            KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language, desktop_file.app_name
        );
        keyfile.set_locale_string (
            KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language, desktop_file.comment
        );
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC, desktop_file.exec_file);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON, desktop_file.icon_file);
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES, desktop_file.categories);
        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NO_DISPLAY, desktop_file.is_no_display);
        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL, desktop_file.is_cli);

        var path = Path.build_filename (startup_dir, desktop_file.id + ".desktop");

        // Create or update desktop file
        try {
            GLib.FileUtils.set_contents (path, keyfile.to_data ());
        } catch (Error e) {
            warning ("Could not write to file %s: %s", path, e.message);
        }
    }
}
