/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util.DesktopFileUtil {
    /**
     * The mask bit to get permission info (``st_mode``) from ``mode_t``.
     *
     * Refer to ``man stat.3`` for more info.
     */
    public const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;

    /**
     * Add execute permission to the given path.
     *
     * If the current user already has execute permission to the given path,
     * this method doesn't change its permission and returns true.
     *
     * @param path the path to add execute permission for the current user
     * @return true when succeed, false otherwise
     */
    public bool add_exec_permission (string path) {
        int ret;
        Posix.Stat sbuf;

        ret = Posix.stat (path, out sbuf);
        if (ret != 0) {
            warning ("add_exec_permission: Failed to get the current mode of \"%s\": %s",
                     path, Posix.strerror (Posix.errno));
            return false;
        }

        Posix.mode_t current_permission = sbuf.st_mode & PERMISSION_BIT;

        // Do nothing if the current user already has execute permission
        if ((current_permission & Posix.S_IXUSR) == Posix.S_IXUSR) {
            return true;
        }

        ret = Posix.chmod (path, current_permission | Posix.S_IXUSR);
        if (ret != 0) {
            warning ("add_exec_permission: Failed to give exec permission to \"%s\": %s",
                     path, Posix.strerror (Posix.errno));
            return false;
        }

        return true;
    }
}
