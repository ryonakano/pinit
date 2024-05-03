config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('PROJECT_VERSION', meson.project_version())
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

dependencies =  [
    dependency('gee-0.8'),
    dependency('gio-unix-2.0'),
    dependency('glib-2.0', version: '>= 2.74'),
    dependency('gtk4', version: '>= 4.10'),
    dependency('libadwaita-1', version: '>= 1.5.0'),
    dependency('pango'),
    meson.get_compiler('vala').find_library('posix'),
]

sources = files(
    'Model/DesktopFile.vala',
    'Model/DesktopFileModel.vala',
    'Util/DesktopFileUtil.vala',
    'View/EditView.vala',
    'View/FilesView.vala',
    'Widget/CategoriesRow.vala',
    'Widget/KeywordsRow.vala',
    'Application.vala',
    'Define.vala',
    'MainWindow.vala'
)

executable(
    app_id,
    asresources,
    config_file,
    sources,
    dependencies: dependencies,
    install: true
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
