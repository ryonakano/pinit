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
     * A key under ``g_key_file_desktop_group``, whose value is a list of strings giving the keywords which may be used in
     * addition to other metadata to describe this entry.
     *
     * Note: Using ``KeyFileDesktop.KEY_KEYWORDS`` will cause the cc failing with ``‘G_KEY_FILE_DESKTOP_KEY_KEYWORDS’ undeclared``
     * error.<<BR>>
     * This constant does not seem to be defined in the original glib and defined in the following patch.<<BR>>
     * (and maybe valac uses glibc with this patch and thus it does not complain any error.)<<BR>>
     * <<BR>>
     * [[https://sources.debian.org/patches/glib2.0/2.78.3-2/01_gettext-desktopfiles.patch/]]<<BR>>
     * <<BR>>
     * We just keep to borrow the definition of KEY_KEYWORDS here instead of applying the patch,
     * since it might have side effect.
     */
    public const string KEY_KEYWORDS = "Keywords";

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
