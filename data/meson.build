i18n.merge_file(
    input: 'pinit.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'pinit.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)
