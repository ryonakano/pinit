project(
    'com.github.ryonakano.pinit',
    'vala', 'c',
    version: '1.0.0',
    meson_version: '>=0.49.0'
)

gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

asresources = gnome.compile_resources(
    'as-resources',
    'data' / 'pinit.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

sources = files(
    'src' / 'Backend' / 'DesktopFile.vala',
    'src' / 'Backend' / 'DesktopFileOperator.vala',
    'src' / 'Views' / 'EditView.vala',
    'src' / 'Views' / 'FilesView.vala',
    'src' / 'Views' / 'WelcomeView.vala',
    'src' / 'Application.vala',
    'src' / 'CategoryChooser.vala',
    'src' / 'DimLabel.vala',
    'src' / 'MainWindow.vala'
)

executable(
    meson.project_name(),
    asresources,
    config_file,
    sources,
    dependencies: [
        dependency('granite', version: '>= 6.0.0'),
        dependency('gtk+-3.0'),
        dependency('libhandy-1'),
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson' / 'post_install.py')
