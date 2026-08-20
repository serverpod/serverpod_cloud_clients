# Changelog

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
