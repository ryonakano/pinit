/*
 * Copyright 2021 Ryo Nakano
 * SPDX-License-Identifier: GPL-3.0-or-later
 * Code borrowed from elementary/switchboard-plug-keyboard#374
 */

public class DesktopFileOperator : GLib.Object {
    public struct FileObject {
        public string basename;
        public string path;
    }

    public DesktopFile? last_edited { get; private set; default = null; }
    private Gee.ArrayList<FileObject?> file_list = new Gee.ArrayList<FileObject?> ();

    private string preferred_language;
    private File desktop_dir;

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

        string location = Path.build_filename ("/home/%s/.local/share/applications".printf (Environment.get_user_name ()));
        desktop_dir = File.new_for_path (location);

        if (!FileUtils.test (location, FileTest.EXISTS)) {
            try {
                desktop_dir.make_directory_with_parents ();
            } catch (Error e) {
                warning (e.message);
                return;
            }
        }
    }

    public Gee.ArrayList<FileObject?> get_file_list () {
        file_list.clear ();

        try {
            var emumerator = desktop_dir.enumerate_children (FileAttribute.STANDARD_NAME, GLib.FileQueryInfoFlags.NONE);
            FileInfo file_info = null;
            while ((file_info = emumerator.next_file ()) != null) {
                string name = file_info.get_name ();
                if (!name.has_suffix (".desktop")) {
                    continue;
                }

                var file = FileObject () {
                    basename = name,
                    path = "%s/%s".printf (desktop_dir.get_path (), name)
                };
                file_list.add (file);
            }
        } catch (Error e) {
            warning (e.message);
        }

        return file_list;
    }

    public DesktopFile create_new () {
        last_edited = null;
        return new DesktopFile ();
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
        keyfile.set_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL, desktop_file.is_cli);

        var path = Path.build_filename (desktop_dir.get_path (), desktop_file.id + ".desktop");

        // Create or update desktop file
        try {
            GLib.FileUtils.set_contents (path, keyfile.to_data ());
        } catch (Error e) {
            warning ("Could not write to file %s: %s", path, e.message);
        }

        last_edited = desktop_file;
    }

    public DesktopFile load_from_file (string path) {
        string id = "";
        string app_name = "";
        string comment = "";
        string exec_file = "";
        string icon_file = "";
        string categories = "";
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
            is_cli = keyfile.get_boolean (KeyFileDesktop.GROUP, KeyFileDesktop.KEY_TERMINAL);
        } catch (GLib.KeyFileError e) {
            warning (e.message);
        } catch (GLib.FileError e) {
            warning (e.message);
        }

        var desktop_file = new DesktopFile (
            id,
            app_name,
            comment,
            exec_file,
            icon_file,
            categories,
            is_cli
        );
        last_edited = desktop_file;

        return desktop_file;
    }
}
