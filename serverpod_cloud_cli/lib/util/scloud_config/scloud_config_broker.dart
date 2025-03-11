import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/util/config/config.dart';

/// The prefix for the scloud configuration domain.
/// Used in qualified keys, e.g: `scloud:/project/projectId`
const scloudConfigDomainPrefix = 'scloud';

/// Creates a [ConfigurationBroker] for the scloud cli.
///
/// This includes the scloud project configuration,
/// referenced via the `scloud:` configuration domain prefix
/// and a JSON value pointer. E.g: `scloud:/project/projectId`
ConfigurationBroker<T> scloudCliConfigBroker<T extends OptionDefinition>({
  required final GlobalConfiguration globalConfig,
  final CommandLogger? logger,
}) {
  return MultiDomainConfigBroker<T>.prefix(
    {
      scloudConfigDomainPrefix: _ScloudProjectConfigProvider<T>(
        globalConfig: globalConfig,
        logger: logger,
      ),
    },
  );
}

/// A [ConfigSourceProvider] for the scloud project configuration.
///
/// The configuration data used depends on the projectConfig... global options.
class _ScloudProjectConfigProvider<T extends OptionDefinition>
    extends ConfigSourceProvider<T> {
  final GlobalConfiguration globalConfig;
  final CommandLogger? logger;

  ConfigurationSource? _configSource;

  _ScloudProjectConfigProvider({
    required this.globalConfig,
    this.logger,
  });

  @override
  ConfigurationSource getConfigSource(final Configuration<T> cfg) {
    return _configSource ??= _makeConfigSource(cfg);
  }

  ConfigurationSource _makeConfigSource(final Configuration<T> cfg) {
    final configContent = globalConfig.projectConfigContent;
    if (configContent != null) {
      logger?.info('Using scloud project configuration from '
          '`${GlobalOption.projectConfigContent}`');
      return ConfigurationParser.fromString(
        configContent,
        format: ConfigEncoding.yaml,
      );
    }

    final configFile = globalConfig.projectConfigFile;
    if (configFile == null) {
      logger?.info('No scloud project configuration file found.');
    } else {
      logger?.info('Using scloud project configuration file $configFile');
      return ConfigurationParser.fromFile(configFile);
    }

    return MapConfigSource({}); // empty configuration content
  }
}
