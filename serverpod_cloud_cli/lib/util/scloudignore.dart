import 'dart:io';

import 'package:path/path.dart';

abstract final class ScloudIgnore {
  static const String fileName = '.scloudignore';
  static const String scloudDirName = '.scloud';

  static const String template = '''
# .scloudignore
#
# This file specifies which files and directories should be ignored when 
# uploading to Serverpod Cloud. It functions similarly to a .gitignore file, 
# preventing listed files from being included in deployments.
#
# Serverpod Cloud also respects .gitignore, meaning any files ignored by Git 
# will not be uploaded unless explicitly opted back in. 
# For example, generated files that are gitignored must be included if they 
# need to be uploaded.
#
# Note: All hidden files and folders (those starting with a dot ".") are 
# ignored by default unless explicitly included.
#

# Ignoring all passwords, service passwords such as for the database are 
# automatically managed by Serverpod Cloud.
# If you need to configure custom api keys or other passwords, you can do so by
# using the `scloud secret create --name <name> --value <value>` command.
#
# Run `scloud secret --help` for more information.
config/passwords.yaml
config/google_client_secret.json
config/firebase_service_account_key.json

# Ignoring all config files, these are automatically managed by Serverpod Cloud.
config/production.yaml
config/staging.yaml
config/development.yaml
config/test.yaml

# Opting out of ignoring generated files.
!lib/src/generated/**

# Opting out of ignoring web files.
!web/**

# Opting out of ignoring the $scloudDirName directory.
!$scloudDirName/**
''';

  static bool fileExists({
    final String rootFolder = '.',
  }) {
    final file = File(join(rootFolder, fileName));
    return file.existsSync();
  }

  static void writeTemplate({
    final String rootFolder = '.',
  }) {
    final file = File(join(rootFolder, fileName));
    file.writeAsStringSync(template);
  }

  static void writeTemplateIfNotExists({
    final String rootFolder = '.',
  }) {
    if (!ScloudIgnore.fileExists(rootFolder: rootFolder)) {
      ScloudIgnore.writeTemplate(rootFolder: rootFolder);
    }
  }
}
