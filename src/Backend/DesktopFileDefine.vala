/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */
public class DesktopFileDefine {
    /**
     * The prefix of the desktop file.
     */
    public const string DESKTOP_SUFFIX = ".desktop";

    public const Posix.mode_t PERMISSION_BIT = Posix.S_IRWXU | Posix.S_IRWXG | Posix.S_IRWXO;
}
