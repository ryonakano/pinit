/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adam Bieńkowski <donadigos159@gmail.com>
 *                         2022-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Modification of:
 * - donadigo/appeditor, src/DesktopApp.vala
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

    public static void open_default_handler (string filename) throws Error {
        // Gtk.show_uri_on_window does not seem to fully work in a Flatpak environment
        // so instead we directly call the freedesktop OpenURI DBus interface instead.
        int fd = Posix.open (filename, Posix.O_RDWR);
        if (fd == -1) {
            throw new FileError.NOENT (_("Cannot open %s: %s").printf (filename, Posix.strerror (Posix.ENOENT)));
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
