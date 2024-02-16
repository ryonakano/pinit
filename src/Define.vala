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
     * A key under g_key_file_desktop_group, whose value is a list of strings giving the keywords which may be used in
     * addition to other metadata to describe this entry.
     *
     * Using KeyFileDesktop.KEY_KEYWORDS will cause the cc failing with "‘G_KEY_FILE_DESKTOP_KEY_KEYWORDS’ undeclared"
     * error. This constant does not seem to be defined in the original glib and defined in the following patch.
     * (and maybe valac uses glibc with this patch and thus it does not complain any error.)
     *
     * [[https://sources.debian.org/patches/glib2.0/2.78.3-2/01_gettext-desktopfiles.patch/]]
     *
     * I just keep to borrow the definition of KEY_KEYWORDS here instead of applying the patch,
     * since it might have side effect.
     */
    public const string KEY_KEYWORDS = "Keywords";

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

    /**
     * Constants for the "style" enum in the gschema.
     */
    namespace Style {
        /** Inherit the system style. */
        public const string DEFAULT = "default";
        /** Always use light appearance. */
        public const string LIGHT = "light";
        /** Always use dark appearance. */
        public const string DARK = "dark";
    }
}
