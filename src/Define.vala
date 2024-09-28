/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * Defines constants used in the project widely.
 */
namespace Define {
    /**
     * The name of the application.
     *
     * Use this constant to prevent the app name from being translated.
     */
    public const string APP_NAME = "Pin It!";

    /**
     * Response IDs used in Adw.MessageDialog.
     */
    namespace DialogResponse {
        /** Use this constant instead of the literal string ``close``. */
        public const string CLOSE = "close";
        /** Use this constant instead of the literal string ``cancel``. */
        public const string CANCEL = "cancel";
        /** Use this constant instead of the literal string ``ok``. */
        public const string OK = "ok";
        /** Use this constant instead of the literal string ``discard``. */
        public const string DISCARD = "discard";
        /** Use this constant instead of the literal string ``save``. */
        public const string SAVE = "save";
    }

    /**
     * String representation of Adw.ColorScheme.
     *
     * Note: Only defines necessary strings for the app.
     */
    namespace ColorScheme {
        /** Inherit the parent color-scheme. */
        public const string DEFAULT = "default";
        /** Always use light appearance. */
        public const string FORCE_LIGHT = "force-light";
        /** Always use dark appearance. */
        public const string FORCE_DARK = "force-dark";
    }
}
