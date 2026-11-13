import 'dart:io';

import 'package:serverpod_cloud_cli/util/flutter_app_name.dart';
import 'package:serverpod_cloud_cli/util/flutter_platform.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../test_utils/project_factory.dart';

void main() {
  for (final (displayName, bundleName, expected) in [
    ('Cloud &amp; Books', 'internal_name', 'Cloud & Books'),
    (null, 'Cloud Books', 'Cloud Books'),
    (r'$(PRODUCT_NAME)', 'Cloud Books', 'Cloud Books'),
    (' ', r'$(PRODUCT_NAME)', 'cloud_books'),
  ]) {
    test('Given iOS names $displayName and $bundleName '
        'when reading the display name then it is $expected', () async {
      await d.dir('app', [
        ProjectFactory.flutterIosDir(
          withInfoPlist: true,
          displayName: displayName,
          bundleName: bundleName,
        ),
      ]).create();

      expect(
        readAppDisplayName(
          Directory('${d.sandbox}/app'),
          FlutterPlatform.ios,
          fallback: 'cloud_books',
        ),
        expected,
      );
    });
  }

  for (final (label, resources, expected) in [
    ('Cloud &amp; Books', <String, String>{}, 'Cloud & Books'),
    (r'Books $5', <String, String>{}, r'Books $5'),
    ('@string/app_name', {'app_name': 'Cloud &amp; Books'}, 'Cloud & Books'),
    ('@string/missing', {'app_name': 'Cloud Books'}, 'cloud_books'),
    (r'${appName}', <String, String>{}, 'cloud_books'),
  ]) {
    test('Given Android label $label when reading the display name '
        'then it is $expected', () async {
      await d.dir('app', [
        ProjectFactory.flutterAndroidDir(
          displayName: label,
          stringResources: resources,
        ),
      ]).create();

      expect(
        readAppDisplayName(
          Directory('${d.sandbox}/app'),
          FlutterPlatform.android,
          fallback: 'cloud_books',
        ),
        expected,
      );
    });
  }

  for (final platform in [FlutterPlatform.ios, FlutterPlatform.android]) {
    test('Given missing $platform name files when reading the display name '
        'then the package name is used', () {
      expect(
        readAppDisplayName(
          Directory(d.sandbox),
          platform,
          fallback: 'cloud_books',
        ),
        'cloud_books',
      );
    });
  }

  test('Given a malformed Info.plist when reading the display name '
      'then the package name is used', () async {
    await d.dir('ios', [
      d.dir('Runner', [d.file('Info.plist', '<plist><dict>')]),
    ]).create();

    expect(
      readAppDisplayName(
        Directory(d.sandbox),
        FlutterPlatform.ios,
        fallback: 'cloud_books',
      ),
      'cloud_books',
    );
  });

  test('Given a non-text Info.plist when reading the display name '
      'then the package name is used', () async {
    await d.dir('ios', [
      d.dir('Runner', [
        d.file('Info.plist', [0xff, 0xfe]),
      ]),
    ]).create();

    expect(
      readAppDisplayName(
        Directory(d.sandbox),
        FlutterPlatform.ios,
        fallback: 'cloud_books',
      ),
      'cloud_books',
    );
  });
}
