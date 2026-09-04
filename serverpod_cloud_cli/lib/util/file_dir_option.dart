import 'dart:io';

import 'package:config/config.dart';

class FileSystemEntityParser extends ValueParser<FileSystemEntity> {
  const FileSystemEntityParser();

  @override
  FileSystemEntity parse(final String value) {
    return FileSystemEntity.isDirectorySync(value)
        ? Directory(value)
        : File(value);
  }

  @override
  String format(final FileSystemEntity value) => value.path;
}

/// A file-or-directory path configuration option.
///
/// Parses to a [File] or a [Directory], whichever [value] is on disk.
/// If the input is not valid according to [mode],
/// the validation throws a [UsageException].
class FileDirOption extends ConfigOptionBase<FileSystemEntity> {
  final PathExistMode mode;

  const FileDirOption({
    super.argName,
    super.argAliases,
    super.argAbbrev,
    super.argPos,
    super.envName,
    super.configKey,
    super.configKeys,
    super.fromCustom,
    super.fromDefault,
    super.defaultsTo,
    super.helpText,
    super.valueHelp,
    super.group,
    super.customValidator,
    super.mandatory,
    super.hide,
    this.mode = PathExistMode.mayExist,
  }) : super(valueParser: const FileSystemEntityParser());

  @override
  void validateValue(final FileSystemEntity value) {
    super.validateValue(value);

    final type = FileSystemEntity.typeSync(value.path);
    switch (mode) {
      case PathExistMode.mayExist:
        break;
      case PathExistMode.mustExist:
        if (type == FileSystemEntityType.notFound) {
          throw UsageException(
            'File or directory "${value.path}" does not exist',
            '',
          );
        }
        break;
      case PathExistMode.mustNotExist:
        if (type != FileSystemEntityType.notFound) {
          throw UsageException('Path "${value.path}" already exists', '');
        }
        break;
    }
  }
}
