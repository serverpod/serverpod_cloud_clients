import 'dart:io';

/// Whether the `git` executable can be invoked on this machine. Used to skip
/// the git-dependent integration tests in environments without git installed.
bool isGitExecutableAvailable() {
  try {
    return Process.runSync('git', const ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Creates a git repository in [directory] on the branch `main`.
Future<void> initGitRepo(String directory) async {
  await _runGit(['init'], directory);
  await _runGit(['checkout', '-b', 'main'], directory);
}

/// Stages every file in [directory] and commits them with [message].
Future<void> gitCommitAll(String directory, String message) async {
  await _runGit(['add', '.'], directory);
  await _runGit([
    '-c',
    'user.name=Test User',
    '-c',
    'user.email=test@example.com',
    '-c',
    'commit.gpgsign=false',
    'commit',
    '-m',
    message,
  ], directory);
}

Future<void> _runGit(List<String> arguments, String workingDirectory) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: workingDirectory,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'git ${arguments.join(' ')} failed (exit ${result.exitCode}): '
      '${result.stderr}',
    );
  }
}
