project(
    'com.github.ryonakano.pin-it',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.49.0'
)

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

sources = files(
    'src' / 'Application.vala',
    'src' / 'DesktopFile.vala',
    'src' / 'DesktopFileOperator.vala',
    'src' / 'DimLabel.vala',
    'src' / 'MainWindow.vala'
)

executable(
    meson.project_name(),
    config_file,
    sources,
    dependencies: [
        dependency('granite', version: '>= 6.0.0'),
        dependency('gtk+-3.0')
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson' / 'post_install.py')
