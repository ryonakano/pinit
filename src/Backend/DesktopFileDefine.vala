/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */
namespace DesktopFileDefine {
    /**
     * The prefix of the desktop file.
     */
    public const string DESKTOP_SUFFIX = ".desktop";

    /**
     * The mask bit to get permission info from mode_t (stat.st_mode).
     */
    public const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;
}
