sources = files(
    'Model' / 'DesktopFile.vala',
    'Model' / 'DesktopFileModel.vala',
    'Util' / 'DesktopFileUtil.vala',
    'View' / 'EditView.vala',
    'View' / 'FilesView.vala',
    'Widget' / 'CategoriesRow.vala',
    'Widget' / 'KeywordsRow.vala',
    'Application.vala',
    'Define.vala',
    'MainWindow.vala'
)

if get_option('doc')
    valadoc = find_program('valadoc')
    
    valadoc_output_dir = 'valadoc'
    valadoc_target = custom_target(
        'valadoc',
        command: [
            valadoc,
            '--pkg=gee-0.8',
            '--pkg=gio-2.0',
            '--pkg=gio-unix-2.0',
            '--pkg=glib-2.0',
            '--pkg=gtk4',
            '--pkg=libadwaita-1',
            '--pkg=pango',
            '--pkg=posix',
            sources,
            config_file,
            '--package-name=' + meson.project_name(),
            '--package-version=' + meson.project_version(),
            '--verbose',
            '--force',
            '--use-svg-images',
            '-o', valadoc_output_dir,
        ],
    
        build_by_default: true,
        output: valadoc_output_dir
    )
endif
