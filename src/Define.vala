/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Define {
    /**
     * The name of the application.
     *
     * Use this to prevent the app name from being translated.
     */
    public const string APP_NAME = "Pin It!";

    /**
     * Defines response IDs used in Adw.MessageDialog.
     */
    namespace DialogResponse {
        public const string CLOSE = "close";
        public const string CANCEL = "cancel";
        public const string OK = "ok";
        public const string DISCARD = "discard";
        public const string SAVE = "save";
    }
}
