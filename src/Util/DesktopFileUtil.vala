/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util.DesktopFileUtil {
    /**
     * The mask bit to get permission info from mode_t (stat.st_mode).
     */
    public const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;

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

        Posix.mode_t cur_perm = sbuf.st_mode & PERMISSION_BIT;

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
