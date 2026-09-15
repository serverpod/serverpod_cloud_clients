# Changelog

## [1.0.0-rc.1] - 2026-09-15

### Added

- **Cloud storage management** - Manage project storage buckets and files directly from the CLI, with support for creating buckets, listing contents, and uploading, downloading, or deleting files and folders.
- **Build command suite** - Added top-level `scloud build` commands to view build logs and manage build secrets.
- **Fast redeploy option** - Added the `--redeploy` flag to `scloud deploy` to restart your services with updated variables and secrets without re-uploading your application.
- **Non-interactive mode** - Added the global `--non-interactive` flag to fail immediately on missing authentication or prompts, making CLI automation easier in CI environments.
- **Live status watch mode** - Added `--watch` and `--interval` options to `scloud status live` for continuous status updates.
- **Database user management** - Added `scloud db user list` and `scloud db user delete` commands to manage database credentials.
- **Project show command** - Added `scloud project show` to display an overview of a project's settings, database, and deployment status.
- **Global format support** - Added a global `--format` flag to output command results as text, JSON, or YAML.
- **Plan upgrade hints** - Helpful upgrade recommendations are now displayed when attempting to use features unavailable on the Starter plan.

### Changed

- **Status command hierarchy** - Reorganized deployment monitoring and inspection commands under `scloud status deployment` and `scloud status live`.
- **Settings command overhaul** - Reworked `scloud settings` to use `list`, `set`, and `unset` subcommands.
- **Storage directory uploads** - Uploading a directory now skips `.DS_Store` files and symbolic links by default unless `--follow-symlinks` is provided.
- **Timezone indicators** - Timestamp column headers in tables now explicitly label the display timezone as `(local)` or `(UTC)`.
- **Storage rate limiting** - Added hourly limits for file operations with estimated retry times when thresholds are exceeded.

### Removed

- **Context command** - Removed `scloud context` subcommands in favor of `scloud settings set projectContext`.

### Fixed

- **Deployment stream reconnection** - The CLI now automatically reconnects to status and log streams if the connection drops while a deployment is running.
- **Archived project listings** - Fixed `scloud project list --all` to properly display deleted projects.
- **Log tail validation** - `scloud log --tail` now reports a usage error when combined with `--since` or `--until` instead of ignoring the time range.
- **Build log layout** - Restored clean terminal formatting for build logs to prevent wide output lines from disrupting the table view.
- **Deployment stage durations** - Deployment status progress now reports actual server-side execution elapsed time rather than client watch duration.
- **Duplicate error output** - Resolved an issue where authentication and client error messages were printed to the terminal twice.
- **CLI session labeling** - Browser-based CLI sign-in sessions are now accurately labeled as `cli` rather than PAT tokens in authentication lists.

## [0.38.0] - 2026-08-31

### Added

- **Structured output** - Added `--format` (`json`, `yaml`, `text`) support across multiple list and management commands to simplify automation and scripting.
- **Account information command** - Added `scloud me` to display current user and account details.
- **Token revocation** - Added `scloud auth revoke-token` to revoke active sessions and personal access tokens by ID.
- **Automatic self-updates** - The CLI now automatically installs required updates and seamlessly reruns the command.

### Changed

- **Unified secret and variable management** - Merged `scloud secret` functionality into `scloud variable` using the `--secret` flag.
- **Interactive confirmation prompts** - Added standardized confirmation prompts for destructive actions, requiring `--yes` when using structured formats like JSON or YAML.
- **Terminology updates** - Replaced occurrences of "instance" with "podlet" across CLI output, scaling guidance, and logs.

### Removed

- **Standalone secret commands** - Removed the dedicated `scloud secret` command suite in favor of `scloud variable --secret`.

### Fixed

- **Early Dart SDK validation** - Deployments now validate Dart SDK version compatibility before running pre-deploy scripts to catch issues sooner.
- **Project launch context isolation** - Fixed an issue where globally active project context interfered with creating new projects via `scloud launch`.
- **Domain verification exit status** - Ensured `scloud domain verify` exits with a non-zero status code when DNS verification fails.
- **Password list categorization** - Fixed platform-managed email authentication keys showing up under Custom instead of Auth in `scloud password list`.
- **Database user reset help text** - Corrected the `--username` option description under `scloud db user reset-password`.

## 0.37.0 - 2026-08-20

### Added

- **Live build log streaming** - Interactive deployments now stream Cloud Build logs directly to your terminal and provide clear troubleshooting guidance on failure.
- **Large build secrets support** - Build secrets now use hybrid encryption, removing the previous size limit to support full SSH keys and larger values.

### Changed

- **Dynamic Dart SDK validation** - The CLI now retrieves supported Dart SDK versions directly from the server rather than relying on hardcoded constraints.

### Fixed

- **Windows archive path formatting** - Normalized zip archive entries to use POSIX separators, resolving deployment packaging issues on Windows.
- **Lockfile SDK checks** - Deploy and launch commands now validate Dart SDK constraints in `pubspec.lock` in addition to `pubspec.yaml`.
- **Workspace deploy cleanup** - Deployment preparation no longer generates obsolete `.scloud/scloud_ws_pubspec.yaml` files.
- **CLI update check logging** - Background version-check timeouts are now treated as debug events and no longer clutter command error output.

## 0.1.1

- Improves the package metadata, documentation, and usage example.

## 0.1.0

- Initial version.
- Contains the file uploader classes `GoogleCloudStorageUploader`,
  `FileUploaderClient`, and `MockFileUploader`, moved from
  `ground_control_client`.
