import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import 'flutter_platform.dart';

/// Reads the display name of [platform] in the Flutter app [appDirectory].
///
/// Reads the iOS Runner Info.plist or the Android application label,
/// including string resources in res/values/strings.xml. Returns [fallback]
/// when the name is missing, uses build variables, or cannot be read.
String readAppDisplayName(
  Directory appDirectory,
  FlutterPlatform platform, {
  required String fallback,
}) {
  final name = switch (platform) {
    FlutterPlatform.ios => _iosName(appDirectory),
    FlutterPlatform.android => _androidName(appDirectory),
    FlutterPlatform.linux ||
    FlutterPlatform.macos ||
    FlutterPlatform.windows => null,
  };
  return name ?? fallback;
}

String? _iosName(Directory directory) {
  final document = _readXml(directory, 'ios/Runner/Info.plist');
  final elements = document
      ?.findAllElements('dict')
      .firstOrNull
      ?.childElements
      .toList();
  if (elements == null) return null;
  for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
    for (var index = 0; index + 1 < elements.length; index++) {
      final element = elements[index];
      final value = elements[index + 1];
      if (element.name.local == 'key' &&
          element.innerText == key &&
          value.name.local == 'string') {
        final name = _literalName(value.innerText);
        if (name != null) return name;
      }
    }
  }
  return null;
}

String? _androidName(Directory directory) {
  final document = _readXml(
    directory,
    'android/app/src/main/AndroidManifest.xml',
  );
  final label = document
      ?.findAllElements('application')
      .firstOrNull
      ?.getAttribute(
        'label',
        namespace: 'http://schemas.android.com/apk/res/android',
      );
  if (label == null) return null;
  if (label.startsWith('@string/')) {
    final resources = _readXml(
      directory,
      'android/app/src/main/res/values/strings.xml',
    );
    final name = label.substring('@string/'.length);
    final resource = resources
        ?.findAllElements('string')
        .where((element) => element.getAttribute('name') == name)
        .firstOrNull;
    return _literalName(resource?.innerText);
  }
  return _literalName(label);
}

String? _literalName(String? value) {
  final name = value?.trim();
  if (name == null ||
      name.isEmpty ||
      name.startsWith('@') ||
      RegExp(r'\$[({]').hasMatch(name)) {
    return null;
  }
  return name;
}

XmlDocument? _readXml(Directory directory, String relativePath) {
  final file = File(p.join(directory.path, relativePath));
  if (!file.existsSync()) return null;
  try {
    return XmlDocument.parse(file.readAsStringSync());
  } on FileSystemException {
    return null;
  } on FormatException {
    return null;
  } on XmlException {
    return null;
  }
}
