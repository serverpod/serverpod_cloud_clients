import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cloud_cli/command_runner/helpers/cli_custom_build.dart';
import 'package:test/test.dart';

void main() {
  group('Given a main branch build version', () {
    test('when resolving the channel then returns preview-main', () {
      expect(
        customBuildChannelOf(Version.parse('1.3.1-preview-main.4')),
        'preview-main',
      );
    });
  });

  group('Given a pull request preview version', () {
    test('when resolving the channel then returns the preview channel', () {
      expect(
        customBuildChannelOf(Version.parse('1.3.1-preview-123.4')),
        'preview-123',
      );
    });
  });

  group('Given a released version', () {
    test('when resolving the channel then returns null', () {
      expect(customBuildChannelOf(Version(1, 3, 1)), isNull);
    });
  });

  group('Given a release candidate version', () {
    test('when resolving the channel then returns null', () {
      expect(customBuildChannelOf(Version.parse('1.0.0-rc.1')), isNull);
    });
  });

  group('Given a version listing with builds on several channels', () {
    final listing = {
      'versions': [
        {'version': '1.3.0'},
        {'version': '1.3.1-preview-main.4'},
        {'version': '1.4.0-preview-main.5'},
        {'version': '1.3.1-preview-main.3'},
        {'version': '1.5.0-preview-123.9'},
        {'version': '2.0.0'},
      ],
    };

    test('when resolving the latest build on a channel then returns the '
        'highest version on that channel', () {
      expect(
        latestCustomBuildVersion(listing, channel: 'preview-main'),
        Version.parse('1.4.0-preview-main.5'),
      );
    });

    test('when resolving the latest build on a channel without builds then '
        'returns null', () {
      expect(latestCustomBuildVersion(listing, channel: 'preview-77'), isNull);
    });
  });

  group('Given a version listing with invalid entries', () {
    test('when resolving the latest build then skips them', () {
      expect(
        latestCustomBuildVersion({
          'versions': [
            {'version': 'not a version'},
            {'other': 'field'},
            'unexpected',
            {'version': '1.3.1-preview-main.2'},
          ],
        }, channel: 'preview-main'),
        Version.parse('1.3.1-preview-main.2'),
      );
    });
  });

  group('Given a response without a versions list', () {
    test('when resolving the latest build then throws FormatException', () {
      expect(
        () => latestCustomBuildVersion({}, channel: 'preview-main'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
