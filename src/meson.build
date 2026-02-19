config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('APP_VERSION', app_version)
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
  input: 'Config.vala.in',
  output: '@BASENAME@',
  configuration: config_data,
)

sources = files(
  'Model/DesktopFile.vala',
  'Model/DesktopFileModel.vala',
  'Util/KeyFileUtil.vala',
  'Util/DesktopFileUtil.vala',
  'View/EditView.vala',
  'View/FilesView.vala',
  'Widget/CategoriesRow.vala',
  'Widget/KeywordsRow.vala',
  'Application.vala',
  'Define.vala',
  'MainWindow.vala',
  'Util.vala',
)

executable(
  app_id,
  asresources,
  config_file,
  sources,
  dependencies: dependencies,
  install: true,
)
