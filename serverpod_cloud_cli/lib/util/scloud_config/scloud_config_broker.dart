import 'package:config/config.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/cloud_cli_command_runner.dart';
import 'package:serverpod_cloud_cli/persistent_storage/resource_manager.dart';

/// The prefix for the scloud configuration domain.
/// Used in qualified keys, e.g: `scloud:/project/projectId`
const scloudConfigDomainPrefix = 'scloud';

/// The value key for the project id in the scloud configuration domain.
const projectIdConfigValueKey = '/project/projectId';

/// Creates a [ConfigurationBroker] for the scloud cli.
///
/// This includes the scloud project configuration,
/// referenced via the `scloud:` configuration domain prefix
/// and a JSON value pointer. E.g: `scloud:/project/projectId`
ConfigurationBroker<T> scloudCliConfigBroker<T extends OptionDefinition>({
  required final GlobalConfiguration globalConfig,
  final CommandLogger? logger,
}) {
  return MultiDomainConfigBroker<T>.prefix({
    scloudConfigDomainPrefix: _ScloudProjectConfigProvider<T>(
      globalConfig: globalConfig,
      logger: logger,
    ),
  });
}

/// A [ConfigSourceProvider] for the scloud project configuration.
///
/// The configuration data used depends on the projectConfig... global options.
///
/// If the project configuration does not specify the project id,
/// it falls back to the globally set project context, if any.
/// See `scloud context set --help`.
class _ScloudProjectConfigProvider<T extends OptionDefinition>
    extends ConfigSourceProvider<T> {
  final GlobalConfiguration globalConfig;
  final CommandLogger? logger;

  ConfigurationSource? _configSource;

  _ScloudProjectConfigProvider({required this.globalConfig, this.logger});

  @override
  ConfigurationSource getConfigSource(final Configuration<T> cfg) {
    return _configSource ??= _ProjectContextFallbackSource(
      primary: _makeConfigSource(cfg),
      globalConfig: globalConfig,
      logger: logger,
    );
  }

  ConfigurationSource _makeConfigSource(final Configuration<T> cfg) {
    final configContent = globalConfig.projectConfigContent;
    if (configContent != null) {
      logger?.debug(
        'Using scloud project configuration from '
        '`${GlobalOption.projectConfigContent.qualifiedString()}`',
      );
      return ConfigurationParser.fromString(
        configContent,
        format: ConfigEncoding.yaml,
      );
    }

    final configFile = globalConfig.projectConfigFile;
    if (configFile == null) {
      logger?.debug('No scloud project configuration file found.');
    } else {
      logger?.debug(
        'Using scloud project configuration file '
        '${configFile.path}',
      );
      return ConfigurationParser.fromFile(configFile.path);
    }

    return MapConfigSource({}); // empty configuration content
  }
}

/// A [ConfigurationSource] that falls back to the globally set
/// project context for the project id value key, if the primary source
/// does not provide a value for it.
class _ProjectContextFallbackSource implements ConfigurationSource {
  final ConfigurationSource primary;
  final GlobalConfiguration globalConfig;
  final CommandLogger? logger;

  _ProjectContextFallbackSource({
    required this.primary,
    required this.globalConfig,
    this.logger,
  });

  @override
  Object? valueOrNull(final String key) {
    final value = primary.valueOrNull(key);
    if (value != null) {
      return value;
    }

    if (key != projectIdConfigValueKey) {
      return null;
    }

    final projectContext = ResourceManager.tryLoadSettingsSync(
      localStoragePath: globalConfig.scloudDir.path,
    )?.projectContext;

    if (projectContext != null) {
      logger?.debug('Using the globally set project context: $projectContext');
    }

    return projectContext;
  }
}
