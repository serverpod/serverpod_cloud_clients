import 'package:ground_control_client/ground_control_client.dart';
import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';
import 'package:serverpod_cloud_cli/command_runner/commands/password/password_ops.dart';
import 'package:serverpod_cloud_cli/shared/exceptions/exit_exceptions.dart';

enum _VariableStore { unmasked, secret }

abstract class VariableCommands {
  static const _nameMaxLength = 255;
  static final _namePattern = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');
  static const _maskedValue = '••••••••';

  static Future<void> setVariable(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
    required final String projectId,
    required final String name,
    required final String value,
    final bool? secret,
  }) async {
    _validateName(baseCommand, name);

    final listed = await _fetch(cloudApiClient, projectId);
    final existingStore = _storeOf(
      name,
      unmasked: listed.unmasked,
      secrets: listed.secrets,
    );

    if (existingStore == _VariableStore.unmasked && secret == true) {
      throw FailureException(
        error:
            '"$name" already exists as an unmasked variable. '
            'To recreate it as a secret:',
        hint:
            '$baseCommand variable unset $name\n'
            '  $baseCommand variable set --secret $name <value>',
      );
    }
    if (existingStore == _VariableStore.secret && secret == false) {
      throw FailureException(
        error:
            '"$name" already exists as a secret. '
            'To recreate it as an unmasked variable:',
        hint:
            '$baseCommand variable unset $name\n'
            '  $baseCommand variable set --no-secret $name <value>',
      );
    }

    final store =
        existingStore ??
        (secret == true ? _VariableStore.secret : _VariableStore.unmasked);

    try {
      switch (store) {
        case _VariableStore.unmasked:
          if (existingStore == null) {
            await cloudApiClient.environmentVariables.create(
              name,
              value,
              projectId,
            );
          } else {
            await cloudApiClient.environmentVariables.update(
              name: name,
              value: value,
              cloudCapsuleId: projectId,
            );
          }
        case _VariableStore.secret:
          if (existingStore == null) {
            await cloudApiClient.secrets.create(
              secrets: {name: value},
              cloudCapsuleId: projectId,
            );
          } else {
            await cloudApiClient.secrets.upsert(
              secrets: {name: value},
              cloudCapsuleId: projectId,
            );
          }
      }
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to set the environment variable',
      );
    }

    logger.success(
      store == _VariableStore.secret
          ? 'Successfully set secret: $name.'
          : 'Successfully set environment variable: $name.',
    );
  }

  static Future<void> unsetVariable(
    final Client cloudApiClient, {
    required final CommandLogger logger,
    required final String baseCommand,
    required final String projectId,
    required final String name,
  }) async {
    _validateName(baseCommand, name);

    final listed = await _fetch(cloudApiClient, projectId);
    final existingStore = _storeOf(
      name,
      unmasked: listed.unmasked,
      secrets: listed.secrets,
    );

    if (existingStore == null) {
      throw FailureException(
        error: 'The environment variable "$name" was not found.',
      );
    }

    final shouldUnset = await logger.confirm(
      'Are you sure you want to remove the environment variable "$name"?',
      defaultValue: false,
    );

    if (!shouldUnset) {
      throw UserAbortException();
    }

    try {
      switch (existingStore) {
        case _VariableStore.unmasked:
          await cloudApiClient.environmentVariables.delete(
            name: name,
            cloudCapsuleId: projectId,
          );
        case _VariableStore.secret:
          await cloudApiClient.secrets.delete(
            key: name,
            cloudCapsuleId: projectId,
          );
      }
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to remove the environment variable',
      );
    }

    logger.success(
      existingStore == _VariableStore.secret
          ? 'Successfully removed secret: $name.'
          : 'Successfully removed environment variable: $name.',
    );
  }

  static Future<List<Map<String, Object?>>> listVariablesOperation(
    final Client cloudApiClient, {
    required final String projectId,
  }) async {
    final listed = await _fetch(cloudApiClient, projectId);

    return [
      for (final variable in listed.unmasked)
        {'name': variable.name, 'value': variable.value},
      for (final secretName in listed.secrets)
        if (PasswordDefinitions.stripPrefix(secretName) == null)
          {'name': secretName, 'value': _maskedValue},
    ];
  }

  static void _validateName(final String baseCommand, final String name) {
    if (name.startsWith(PasswordDefinitions.prefix)) {
      throw FailureException(
        error: "Names can't start with '${PasswordDefinitions.prefix}'.",
        hint: 'Use `$baseCommand password set` to manage passwords.',
      );
    }

    if (name.isEmpty ||
        name.length > _nameMaxLength ||
        !_namePattern.hasMatch(name)) {
      throw FailureException(
        error:
            'Use letters, digits and underscores, starting with a letter or '
            'an underscore.',
      );
    }
  }

  static Future<({List<EnvironmentVariable> unmasked, List<String> secrets})>
  _fetch(final Client client, final String projectId) async {
    try {
      final unmasked = await client.environmentVariables.list(projectId);
      final secrets = await client.secrets.list(projectId);
      return (unmasked: unmasked, secrets: secrets);
    } on Exception catch (e, s) {
      throw FailureException.nested(
        e,
        s,
        'Failed to list environment variables',
      );
    }
  }

  static _VariableStore? _storeOf(
    final String name, {
    required final List<EnvironmentVariable> unmasked,
    required final List<String> secrets,
  }) {
    if (secrets.contains(name)) {
      return _VariableStore.secret;
    }
    if (unmasked.any((final variable) => variable.name == name)) {
      return _VariableStore.unmasked;
    }
    return null;
  }
}
