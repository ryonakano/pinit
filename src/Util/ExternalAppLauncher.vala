/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Adam Bieńkowski <donadigos159@gmail.com>
 *                         2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 *
 * Modification of:
 * https://github.com/donadigo/appeditor/blob/master/src/DesktopApp.vala
 */

namespace Util {
    [DBus (name = "org.freedesktop.portal.OpenURI")]
    public interface FDODesktopPortal : Object {
        public abstract string open_file (string parent_window, UnixInputStream fd, HashTable<string, Variant> options) throws Error;
    }

    public class ExternalAppLauncher : Object {
        private static FDODesktopPortal desktop_portal;

        private static FDODesktopPortal? get_desktop_portal () {
            if (desktop_portal == null) {
                try {
                    desktop_portal = Bus.get_proxy_sync (
                        BusType.SESSION,
                        "org.freedesktop.portal.Desktop",
                        "/org/freedesktop/portal/desktop"
                        );
                } catch (IOError e) {
                    warning ("Failed to get bus proxy: %s", e.message);
                }
            }

            return desktop_portal;
        }

        public static bool open_default_handler (string path) {
            // Gtk.show_uri_on_window does not seem to fully work in a Flatpak environment
            // so instead we directly call the freedesktop OpenURI DBus interface instead.
            int fd = Posix.open (path, Posix.O_RDONLY);
            if (fd == -1) {
                warning ("Failed to Posix.open. path=%s: %s", path, Posix.strerror (Posix.errno));
                return false;
            }

            var portal = get_desktop_portal ();
            if (portal == null) {
                Posix.close (fd);
                return false;
            }

            var stream = new UnixInputStream (fd, true);

            try {
                portal.open_file ("", stream, new HashTable<string, Variant> (null, null));
            } catch (Error e) {
                warning ("Failed to open_file: %s", e.message);
                Posix.close (fd);
                return false;
            }

            // We don't call Posix.close here since we set UnixInputStream.close_fd to true.
            return true;
        }
    }
}
