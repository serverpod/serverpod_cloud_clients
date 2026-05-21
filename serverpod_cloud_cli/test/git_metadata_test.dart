import 'dart:io';

import 'package:serverpod_cloud_cli/util/git_metadata.dart';
import 'package:test/test.dart';

void main() {
  /// Builds a [GitCommandRunner] that answers from [responses], keyed by the
  /// git arguments joined with spaces. Unstubbed commands throw a
  /// [ProcessException], mimicking a missing `git` executable.
  GitCommandRunner fakeRunner(final Map<String, ProcessResult> responses) {
    return (final arguments, final workingDirectory) async {
      final result = responses[arguments.join(' ')];
      if (result == null) {
        throw ProcessException('git', arguments, 'unstubbed git command');
      }
      return result;
    };
  }

  ProcessResult success(final String stdout) => ProcessResult(0, 0, stdout, '');
  ProcessResult failure() => ProcessResult(0, 128, '', 'fatal: error');

  group('Given a directory that is not inside a git repository', () {
    test('when reading git metadata then returns null', () async {
      final metadata = await readGitMetadata(
        '/project',
        runGitCommand: fakeRunner({
          'rev-parse --is-inside-work-tree': failure(),
        }),
      );

      expect(metadata, isNull);
    });
  });

  group('Given the git executable is not available', () {
    test('when reading git metadata then returns null', () async {
      final metadata = await readGitMetadata(
        '/project',
        runGitCommand: fakeRunner({}),
      );

      expect(metadata, isNull);
    });
  });

  group('Given a clean git repository', () {
    late GitMetadata? metadata;

    setUp(() async {
      metadata = await readGitMetadata(
        '/project',
        runGitCommand: fakeRunner({
          'rev-parse --is-inside-work-tree': success('true\n'),
          'rev-parse --short HEAD': success('8f3c1ab\n'),
          'log -1 --pretty=%s': success('feat: add upload metadata\n'),
          'branch --show-current': success('main\n'),
          'status --porcelain': success(''),
        }),
      );
    });

    test('when reading git metadata then metadata is not null', () {
      expect(metadata, isNotNull);
    });

    test('when reading git metadata then commit hash is the trimmed '
        'short hash', () {
      expect(metadata?.commitHash, '8f3c1ab');
    });

    test('when reading git metadata then commit message is the trimmed '
        'subject line', () {
      expect(metadata?.commitMessage, 'feat: add upload metadata');
    });

    test('when reading git metadata then branch is the trimmed branch '
        'name', () {
      expect(metadata?.branch, 'main');
    });

    test('when reading git metadata then hasUncommittedChanges is false', () {
      expect(metadata?.hasUncommittedChanges, isFalse);
    });
  });

  group('Given a git repository with uncommitted changes', () {
    test(
      'when reading git metadata then hasUncommittedChanges is true',
      () async {
        final metadata = await readGitMetadata(
          '/project',
          runGitCommand: fakeRunner({
            'rev-parse --is-inside-work-tree': success('true\n'),
            'rev-parse --short HEAD': success('8f3c1ab\n'),
            'log -1 --pretty=%s': success('feat: add upload metadata\n'),
            'branch --show-current': success('main\n'),
            'status --porcelain': success(' M lib/main.dart\n?? new.dart\n'),
          }),
        );

        expect(metadata?.hasUncommittedChanges, isTrue);
      },
    );
  });

  group('Given a git repository without any commits', () {
    late GitMetadata? metadata;

    setUp(() async {
      metadata = await readGitMetadata(
        '/project',
        runGitCommand: fakeRunner({
          'rev-parse --is-inside-work-tree': success('true\n'),
          'rev-parse --short HEAD': failure(),
          'log -1 --pretty=%s': failure(),
          'branch --show-current': success('main\n'),
          'status --porcelain': success('?? README.md\n'),
        }),
      );
    });

    test('when reading git metadata then commit hash is null', () {
      expect(metadata?.commitHash, isNull);
    });

    test('when reading git metadata then commit message is null', () {
      expect(metadata?.commitMessage, isNull);
    });

    test('when reading git metadata then branch is still resolved', () {
      expect(metadata?.branch, 'main');
    });
  });

  group('Given a git repository in a detached HEAD state', () {
    test('when reading git metadata then branch is null', () async {
      final metadata = await readGitMetadata(
        '/project',
        runGitCommand: fakeRunner({
          'rev-parse --is-inside-work-tree': success('true\n'),
          'rev-parse --short HEAD': success('8f3c1ab\n'),
          'log -1 --pretty=%s': success('feat: add upload metadata\n'),
          'branch --show-current': success('\n'),
          'status --porcelain': success(''),
        }),
      );

      expect(metadata?.branch, isNull);
      expect(metadata?.commitHash, '8f3c1ab');
    });
  });
}
