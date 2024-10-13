/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * List Categories of the app.
 *
 * There are ``Adw.SwitchRow`` for each category and ``Adw.SwitchRow.active`` represents
 * whether the corresponding category is listed in the desktop file.
 */
public class Widget.CategoriesRow : Adw.ExpanderRow {
    /**
     * A signal emitted when categories are changed (specifically, when a ``Adw.SwitchRow`` in ``this``
     * is turned on / off).
     */
    public signal void categories_changed ();

    /**
     * Preserve the category name and its corresponding switch row.
     */
    private class RowItem : Object {
        public string category { get; construct; }
        public string label { get; construct; }

        public Adw.SwitchRow row { get; construct; }

        public RowItem (string category, string label) {
            Object (
                category: category,
                label: label
            );
        }

        construct {
            row = new Adw.SwitchRow () {
                title = _(label)
            };
        }
    }

    /**
     * Stores all switch rows in ``this``.
     */
    private Gee.ArrayList<RowItem> row_items;

    /**
     * Represent one category.
     */
    private struct Categories {
        /** Name of the category. */
        string name;
        /** Translatable name of the category. */
        string translatable_name;
    }

    /**
     * Array of known categories.
     *
     * Note: See https://specifications.freedesktop.org/menu-spec/menu-spec-1.0.html#category-registry
     */
    private const Categories[] CATEGORIES_TABLE = {
        { "AudioVideo", N_("Sound &amp; Video") },
        { "Audio", N_("Audio") },
        { "Video", N_("Video") },
        { "Development", N_("Programming") },
        { "Education", N_("Education") },
        { "Game", N_("Games") },
        { "Graphics", N_("Graphics") },
        { "Network", N_("Internet") },
        { "Office", N_("Office") },
        { "Science", N_("Science") },
        { "Settings", N_("Settings") },
        { "System", N_("System Tools") },
        { "Utility", N_("Accessories") },
    };

    public CategoriesRow () {
    }

    construct {
        title = _("Categories");
        subtitle = _("Categories applicable to the app. (You can select more than one.)");

        row_items = new Gee.ArrayList<RowItem> ();

        // Create and append a switch row for each category
        foreach (var category in CATEGORIES_TABLE) {
            var item = new RowItem (category.name, category.translatable_name);
            item.row.notify["active"].connect (() => {
                categories_changed ();
            });
            row_items.add (item);
            add_row (item.row);
        }
    }

    /**
     * Return categories in a string array.
     *
     * @return categories represented in a string array
     */
    public string[] to_strv () {
        string[] _categories = {};

        /*
         * Each category has a switch row.
         * If the switch row is activated, that means that category is selected,
         * so we add the name of that category in the Categories section
         * in the desktop file.
         */
        row_items.foreach ((item) => {
            if (item.row.active) {
                _categories += item.category;
            }

            return true;
        });

        return _categories;
    }

    /**
     * Reflect categories in a string array to the UI.
     *
     * @param categories    categories represented in a string array
     */
    public void from_strv (string[] categories) {
        row_items.foreach ((item) => {
            // Clear the current selection
            item.row.active = false;

            foreach (unowned string category in categories) {
                // The category is in the desktop file
                if (item.category == category) {
                    item.row.active = true;
                    // We find the category matching, so no longer need the rest of the loop.
                    continue;
                }
            }

            return true;
        });
    }
}
