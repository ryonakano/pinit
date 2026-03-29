/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * List Keywords of the app.
 *
 * There are {@link Widget.KeywordsRow.KeywordRow} for each keyword.
 */
public class Widget.KeywordsRow : Adw.ExpanderRow {
    /**
     * A signal emitted when keywords are changed.
     */
    public signal void keywords_changed ();

    /**
     * A row that can edit or delete one keyword.
     */
    private class KeywordRow : Adw.EntryRow {
        /**
         * A signal emitted when the delete button is clicked.
         */
        public signal void delete_clicked ();

        /**
         * Create a new {@link Widget.KeywordsRow.KeywordRow} and set its text to ``keyword``.
         *
         * @param keyword   the keyword to set to the text property
         */
        public KeywordRow (string keyword) {
            title = _("Keyword");
            text = keyword;

            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
                tooltip_text = _("Delete keyword"),
                valign = Gtk.Align.CENTER
            };
            delete_button.add_css_class ("flat");
            add_suffix (delete_button);

            delete_button.clicked.connect (() => {
                delete_clicked ();
            });
        }
    }

    /**
     * Stores all keyword rows in ``this``.
     */
    private Gee.ArrayList<KeywordRow> rows;

    public KeywordsRow () {
    }

    construct {
        title = _("Keywords");
        subtitle = _("These words can be used as search terms.");

        rows = new Gee.ArrayList<KeywordRow> ();

        var add_keyword_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Add a new keyword"),
            valign = Gtk.Align.CENTER
        };
        add_keyword_button.add_css_class ("flat");
        add_suffix (add_keyword_button);

        add_keyword_button.clicked.connect (() => {
            expanded = true;
            add_keyword ();
        });
    }

    /**
     * Return keywords in a string array.
     *
     * @return keywords represented in a string array
     */
    public string[] to_strv () {
        string[] _keywords = {};

        rows.foreach ((row) => {
            _keywords += row.text;
            return true;
        });

        return _keywords;
    }

    /**
     * Reflect keywords in a string array to the UI.
     *
     * @param keywords keywords represented in a string array
     */
    public void from_strv (string[] keywords) {
        // Clear all of the currently added entries
        rows.foreach ((row) => {
            remove_row (row);
            return true;
        });

        foreach (unowned string keyword in keywords) {
            add_keyword (keyword);
        }
    }

    /**
     * Add new keyword.
     *
     * @param keyword   the keyword
     */
    public void add_keyword (string keyword = "") {
        var row = new KeywordRow (keyword);
        ((Gtk.Editable) row).changed.connect (() => {
            keywords_changed ();
        });
        row.delete_clicked.connect (() => {
            remove_row (row);
            keywords_changed ();
        });
        rows.add (row);
        add_row (row);
    }

    /**
     * Remove row.
     *
     * @param row   the {@link Widget.KeywordsRow.KeywordRow} to remove
     */
    private void remove_row (KeywordRow row) {
        rows.remove (row);
        remove (row);
    }
}
