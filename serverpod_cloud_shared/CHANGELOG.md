# Changelog

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
