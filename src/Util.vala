/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util {
    /**
     * Whether the app is running on Pantheon desktop environment.
     */
    public static bool is_on_pantheon () {
        return Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
    }
}
