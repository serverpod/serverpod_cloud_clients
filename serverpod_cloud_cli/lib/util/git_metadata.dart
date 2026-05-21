import 'dart:io';

import 'package:serverpod_cloud_cli/command_logger/command_logger.dart';

/// Runs a `git` subcommand with the given [arguments] in [workingDirectory].
///
/// Injectable to allow tests to stub git invocations. Defaults to
/// [_runGitCommand], which invokes the `git` executable.
typedef GitCommandRunner =
    Future<ProcessResult> Function(
      List<String> arguments,
      String workingDirectory,
    );

/// Git repository information collected for a project at deploy time.
class GitMetadata {
  /// The short commit hash of `HEAD` (e.g. `8f3c1ab`), or `null` if the
  /// repository has no commits.
  final String? commitHash;

  /// The subject line (first line) of the `HEAD` commit message, or `null` if
  /// the repository has no commits.
  final String? commitMessage;

  /// The name of the currently checked out branch, or `null` when the
  /// repository is in a detached `HEAD` state.
  final String? branch;

  /// Whether the working tree has uncommitted changes, including staged,
  /// unstaged, and untracked files.
  final bool hasUncommittedChanges;

  const GitMetadata({
    required this.commitHash,
    required this.commitMessage,
    required this.branch,
    required this.hasUncommittedChanges,
  });
}

/// Reads [GitMetadata] for the git repository containing [projectDirectory].
///
/// Returns `null` when [projectDirectory] is not inside a git repository, or
/// when the `git` executable is not available. Individual fields are `null`
/// when the corresponding information cannot be determined (for example, in a
/// repository without any commits).
///
/// When a [logger] is provided, the reason for skipping git metadata is
/// recorded as a debug message.
Future<GitMetadata?> readGitMetadata(
  final String projectDirectory, {
  final GitCommandRunner runGitCommand = _runGitCommand,
  final CommandLogger? logger,
}) async {
  final ProcessResult isInsideWorkTreeResult;
  try {
    isInsideWorkTreeResult = await runGitCommand(const [
      'rev-parse',
      '--is-inside-work-tree',
    ], projectDirectory);
  } on ProcessException {
    logger?.debug(
      'Skipping git commit metadata: the `git` executable was not found.',
    );
    return null;
  }

  if (isInsideWorkTreeResult.exitCode != 0 ||
      _stdoutString(isInsideWorkTreeResult)?.trim() != 'true') {
    logger?.debug(
      'Skipping git commit metadata: the project directory is not inside a '
      'git repository.',
    );
    return null;
  }

  final commitHash = await _gitOutput(runGitCommand, const [
    'rev-parse',
    '--short',
    'HEAD',
  ], projectDirectory);
  final commitMessage = await _gitOutput(runGitCommand, const [
    'log',
    '-1',
    '--pretty=%s',
  ], projectDirectory);
  final branch = await _gitOutput(runGitCommand, const [
    'branch',
    '--show-current',
  ], projectDirectory);
  final status = await _gitOutput(runGitCommand, const [
    'status',
    '--porcelain',
  ], projectDirectory);

  return GitMetadata(
    commitHash: _nullIfEmpty(commitHash),
    commitMessage: _nullIfEmpty(commitMessage),
    branch: _nullIfEmpty(branch),
    hasUncommittedChanges: status != null && status.isNotEmpty,
  );
}

/// Runs a git command and returns its trimmed stdout, or `null` when the
/// command fails (non-zero exit code or the `git` executable is missing).
Future<String?> _gitOutput(
  final GitCommandRunner runGitCommand,
  final List<String> arguments,
  final String workingDirectory,
) async {
  final ProcessResult result;
  try {
    result = await runGitCommand(arguments, workingDirectory);
  } on ProcessException {
    return null;
  }
  if (result.exitCode != 0) {
    return null;
  }
  return _stdoutString(result)?.trim();
}

/// Extracts stdout from [result] as a string, or `null` when stdout was not
/// captured as text.
String? _stdoutString(final ProcessResult result) {
  final stdout = result.stdout;
  return stdout is String ? stdout : null;
}

Future<ProcessResult> _runGitCommand(
  final List<String> arguments,
  final String workingDirectory,
) {
  return Process.run('git', arguments, workingDirectory: workingDirectory);
}

String? _nullIfEmpty(final String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}
