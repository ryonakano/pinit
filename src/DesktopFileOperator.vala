/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Code borrowed from elementary/switchboard-plug-keyboard#374
 */

public class DesktopFileOperator : GLib.Object {
    public DesktopFile? last_edited { get; private set; default = null; }

    private string preferred_language;
    private string desktop_dir;

    public static DesktopFileOperator get_default () {
        if (_instance == null) {
            _instance = new DesktopFileOperator ();
        }

        return _instance;
    }
    private static DesktopFileOperator _instance;

    private DesktopFileOperator () {
        var languages = Intl.get_language_names ();
        preferred_language = languages[0];

        desktop_dir = Path.build_filename ("/home/%s/.local/share/applications".printf (Environment.get_user_name ()));
        if (!FileUtils.test (desktop_dir, FileTest.EXISTS)) {
            var file = File.new_for_path (desktop_dir);

            try {
                file.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
                return;
            }
        }
    }

    public void write_to_file (DesktopFile desktop_file) {
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
        keyfile.set_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TYPE, "Application");
        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NO_DISPLAY, desktop_file.is_no_display);
        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL, desktop_file.is_cli);

        var path = Path.build_filename (desktop_dir, desktop_file.id + ".desktop");

        // Create or update desktop file
        try {
            GLib.FileUtils.set_contents (path, keyfile.to_data ());
        } catch (Error e) {
            warning ("Could not write to file %s: %s", path, e.message);
        }
    }

    public DesktopFile? load_from_file (string path) {
        DesktopFile desktop_file = null;
        string id = "";
        string app_name = "";
        string comment = "";
        string exec_file = "";
        string icon_file = "";
        string categories = "";
        bool is_no_display = false;
        bool is_cli = false;

        try {
            var keyfile = new GLib.KeyFile ();
            keyfile.load_from_file (path, GLib.KeyFileFlags.KEEP_TRANSLATIONS);
            string[] splited_path = path.split ("/");
            string basename = splited_path[splited_path.length - 1];

            id = basename.slice (0, basename.length - ".desktop".length);
            app_name = keyfile.get_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NAME, preferred_language);
            comment = keyfile.get_locale_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_COMMENT, preferred_language);
            exec_file = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_EXEC);
            icon_file = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_ICON);
            categories = keyfile.get_string (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_CATEGORIES);
            is_no_display = keyfile.get_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_NO_DISPLAY);
            is_cli = keyfile.get_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL);
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        } catch (GLib.FileError e) {
            warning (e.message);
        }

        desktop_file = new DesktopFile (
            id,
            app_name,
            comment,
            exec_file,
            icon_file,
            categories,
            is_no_display,
            is_cli
        );
        last_edited = desktop_file;

        return desktop_file;
    }
}
