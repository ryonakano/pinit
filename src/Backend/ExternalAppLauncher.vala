/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adam Bieńkowski <donadigos159@gmail.com>
 *                         2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Modification of:
 * https://github.com/donadigo/appeditor/blob/master/src/DesktopApp.vala
 */

[DBus (name = "org.freedesktop.portal.OpenURI")]
public interface FDODesktopPortal : Object {
    public abstract string open_file (string parent_window, UnixInputStream fd, HashTable<string, Variant> options) throws GLib.Error;
}

public class ExternalAppLauncher : Object {
    private static FDODesktopPortal desktop_portal;

    private static FDODesktopPortal? get_desktop_portal () throws Error {
        if (desktop_portal == null) {
            try {
                desktop_portal = Bus.get_proxy_sync (
                    BusType.SESSION,
                    "org.freedesktop.portal.Desktop",
                    "/org/freedesktop/portal/desktop"
                );
            } catch (Error e) {
                throw e;
            }
        }

        return desktop_portal;
    }

    public static void open_default_handler (string path) throws Error {
        // Gtk.show_uri_on_window does not seem to fully work in a Flatpak environment
        // so instead we directly call the freedesktop OpenURI DBus interface instead.
        int fd = Posix.open (path, Posix.O_RDONLY);
        if (fd == -1) {
            ///TRANSLATORS: The first "%s" represents path to the file that just tried to open.
            ///The second "%s" represents the detailed error message.
            throw new FileError.NOENT (_("Cannot open %s: %s").printf (path, Posix.strerror (Posix.ENOENT)));
        }

        try {
            var portal = get_desktop_portal ();
            if (portal != null) {
                portal.open_file ("", new UnixInputStream (fd, true), new GLib.HashTable<string, GLib.Variant> (null, null));
            }
        } catch (Error e) {
            throw e;
        }
    }
}
