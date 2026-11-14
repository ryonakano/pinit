/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

/**
 * A row that can expand/fold multiple text entries.
 */
public class Widget.MultiEntryExpanderRow : Adw.ExpanderRow {
    /**
     * A signal emitted when some text entry is changed.
     */
    public signal void entry_changed ();

    /**
     * Title for each text entry
     */
    public string entry_title { get; construct; }

    /**
     * A row that can edit or delete a text.
     */
    private class EntryRow : Adw.EntryRow {
        /**
         * A signal emitted when the delete button is clicked.
         */
        public signal void delete_clicked ();

        /**
         * Create a new {@link Widget.MultiEntryExpanderRow.EntryRow}.
         *
         * @param title     the title for each text entry
         * @param text      the text to set to the text property
         */
        public EntryRow (string title, string text) {
            Object (
                title: title,
                text: text
            );
        }

        construct {
            var delete_button = new Gtk.Button.from_icon_name ("edit-delete-symbolic") {
                tooltip_text = _("Delete"),
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
     * Stores all text entry rows in ``this``.
     */
    private Gee.ArrayList<EntryRow> rows;

    /**
     * Create a new {@link Widget.MultiEntryExpanderRow}.
     *
     * @param title         the title for this row.
     * @param subtitle      the subtitle for this row
     * @param entry_title   the title for each text entry
     */
    public MultiEntryExpanderRow (string title, string subtitle, string entry_title) {
        Object (
            title: title,
            subtitle: subtitle,
            entry_title: entry_title
        );
    }

    construct {
        rows = new Gee.ArrayList<EntryRow> ();

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic") {
            tooltip_text = _("Add"),
            valign = Gtk.Align.CENTER
        };
        add_button.add_css_class ("flat");
        add_suffix (add_button);

        add_button.clicked.connect (() => {
            expanded = true;
            add_entry ();
        });
    }

    /**
     * Return texts in all text entries in a string array.
     *
     * @return texts in all text entries represented in a string array
     */
    public string[] to_strv () {
        string[] _texts = {};

        rows.foreach ((row) => {
            _texts += row.text;
            return true;
        });

        return _texts;
    }

    /**
     * Reflect texts in a string array to the UI.
     *
     * @param texts     texts that should be loaded to text entries represented in a string array
     */
    public void from_strv (string[] texts) {
        // Clear all of the currently added entries
        rows.foreach ((row) => {
            remove_row (row);
            return true;
        });

        foreach (unowned string text in texts) {
            add_entry (text);
        }
    }

    /**
     * Add new entry.
     *
     * @param text      the text
     */
    public void add_entry (string text = "") {
        var row = new EntryRow (entry_title, text);
        ((Gtk.Editable) row).changed.connect (() => {
            entry_changed ();
        });
        row.delete_clicked.connect (() => {
            remove_row (row);
            entry_changed ();
        });
        rows.add (row);
        add_row (row);
    }

    /**
     * Remove row.
     *
     * @param row       the {@link Widget.MultiEntryExpanderRow.EntryRow} to remove
     */
    private void remove_row (EntryRow row) {
        rows.remove (row);
        remove (row);
    }
}
