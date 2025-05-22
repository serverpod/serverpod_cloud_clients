# Changelog

## [0.8.0] - 2025-05-22

### Added

- **User listing** - You can now list users in a Serverpod Cloud project with `scloud user list`.
- **Project invite/revoke subcommands** - Added `scloud project invite` and `scloud project revoke` to manage user access to projects.

## [0.7.0] - 2025-05-19

## [0.6.0] - 2025-05-06

### Added

- **Dart workspace support** - You can now deploy Dart workspace projects to Serverpod Cloud. No new options or configuration is needed.

## [0.5.2] - 2025-04-29

### Fixed

- **Project naming** - The `-server` suffix is now dropped from the suggested project name when creating a new Serverpod project.

## [0.5.1] - 2025-04-14

### Fixed

- **scloud deploy path bug** - Absolute drive paths on Windows no longer cause the zipper to fail.
- **Windows compatibility** - Fixed multiple issues to ensure the scloud CLI and its tests run correctly on Windows.

## 0.5.0 - 2025-04-09

### Added

- **Secrets and environment variables from file** - You can now create secrets and environment variables from a file using the `--from-file` option with the `scloud secret create`, `scloud env create`, and `scloud env update` commands.

### Fixed

- **Updated command docs URL** - Updated the URL to the command reference documentation in the CLI usage footer.

## [0.4.0] - 2025-03-31

### Added

- **Improved status feedback** - The CLI now provides specific guidance when no deployments are found.
- **Project directory validation** - The CLI now validates the server directory at the start of the launch command, providing clearer error messages.
- **Launch command improvements** - The CLI now auto-selects the project directory and ID, simplifying the launch process and displaying default values more clearly.

### Fixed

- **Tenant web server domain** - Fixed an issue where the tenant web server domain erroneously included "web".

## 0.3.1

 - **Better authentication** - Support account selection when user already is authenticated.

## 0.3.0 - 2025-03-11

### Fixed

- **Return friendly error if domain is already used** – The API now returns a clear error message if a domain creation request fails due to a conflict, instead of a generic 500 error.  
- **Ensure deterministic ordering of domains** – Updated the domain listing API to return results in a consistent order.  

### Removed

- **Remove unused user endpoints** – Removed internal user object creation and fetching endpoints to simplify user info handling.

## 0.2.0 - 2025-02-28

### Fixes

- Moved link command to a subcommand of project.
- Files in hidden folders are recursively ignored during upload.
- Listing secrets when there are none available no longer returns an error.

### Added

- Introduce new command auth.
- Moved login command to a subcommand of auth.
- Moved logout command to a subcommand of auth.
- Modify status command to into a subcommand structure.
- Help instructions included in scloud.yaml.
- Help command renders full list of commands even if only flags are missing.

## 0.1.1 - 2025-02-18

### Fixes

- New registration flow

## 0.1.0 - 2025-02-06

### Added

- Authentication support login/logout of the cli.
- Project management, create, delete and link projects.
  - Database setup, create your project with a pre-configured postgresql instance
- View logs, fetch for a specific time period or tail in realtime.
- Deploy command to deploy your Serverpod server complete with a domain and certificates.
- Configure your own custom domains.
- Configure secrets for your deployments, secrets are stored in an encrypted space.
- Configure environment variables for your deployments.
- Manual connection to database, retrieve connection details to connect your own db viewer.

## 0.0.2 - 2025-02-05

- Initial beta version.

## 0.0.1

- The initial version of the client library.
- Supports basic authentication.
