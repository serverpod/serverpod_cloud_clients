
# Changelog

## [0.8.1] - 2025-06-02

### Fixed

- **`project user list` command** - Fixed data serialization error
- **Always print stacktrace in "yikes" message** - The "yikes" last resort error message will now always print the stack trace, enabling users to create an issue with full error information.

## [0.8.0] - 2025-05-22

### Added

- **User listing** - You can now list users in a Serverpod Cloud project with `scloud user list`.
- **Project invite/revoke subcommands** - Added `scloud project invite` and `scloud project revoke` to manage user access to projects.

## [0.7.0] - 2025-05-19

### Changed

- **Configurable GC API timeout** - The connection timeout for the Ground Control API is now configurable via the `scloud` command and the `SERVERPOD_CLOUD_CONNECTION_TIMEOUT` environment variable, with a default of 60 seconds.
- **Improved exception handling** - Introduced `FailureException` for consistent exception handling across `scloud`, simplifying error message output and exception translations.
- **Updated command output** - The output of `project`, `deploy`, and `launch` commands has been revised to more closely resemble the style of the `serverpod` command.
- **Updated cli_tools dependency** - Updated the `cli_tools` dependency to version 0.5.0, replacing the local config library with the new config library in `cli_tools`.

### Fixed

- **Password string matching in E2E tests** - Fixed an issue where long lines in password creation/change output were not correctly matched in E2E tests due to line wrapping.
- **Global options not applied to logger** - Fixed a bug where global options such as `--skip-confirmation` flag had no effect on the logger.

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

## 0.3.1 - 2025-03-20

### Added

 - **New scloud launch command** - CLI wizard to create and deploy a project interactively.
 - **Deployed service URLs**: The deploy command prints the URLs of the deployed services.
 - **Subcommand categories** - `scloud` command usage shows subcommands by category.

### Fixed

 - **Option handling** - `--project-config-file` option correctly handles a project directory that is inaccessible.
 - **scloud help text footer** - Corrected docs URLs in `scloud` command help footer.

## 0.3.0 - 2025-03-11

### Added

- **Run scloud commands outside of server dir** – Will find the scloud.yaml file even when the scloud command is run from outside of the server dir.
- **Deploy command support for dry-run** – Introduced a `--dry-run` flag to the `deploy` command, allowing users to simulate a deployment without actually uploading files. Works well with `--verbose` for detailed logs.  
- **Create `.scloudignore` during link and project create commands** – Automatically generates a `.scloudignore` file with helpful comments and commonly ignored files.  
- **Support for `--version` option** – Added `--version` as an alternative to the `version` subcommand. Also includes CLI doc links in the usage footer.  

### Changed

- **Print file tree for deploy command in verbose mode** – Added a file tree printer that shows the structure of uploaded files when running the deploy command with `--verbose`.  
- **Rename `domain refresh-record` to `domain verify`** – Shortened and clarified the `domain refresh-record` command to `domain verify`. Improved help descriptions and allowed `--target` as a positional argument.  
- **Restructure domain add output with clearer instructions** – Improved the instructions for the `domain add` command to make them clearer and more concise.  
- **Rename `--project-id` to `--project`** – Updated the `--project-id` option to `--project` for consistency and ease of use.  

### Fixed

- **Return friendly error if domain is already used** – Catch unique violation constraints for domain creation and provide a clear client error message instead of a generic 500 error.  
- **Deterministic ordering of domains** – Ensured that domain lists are always presented in a consistent order.  

## 0.2.0 - 2025-02-28

### Fixed

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

### Fixed

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

Initial beta version.

## 0.0.1 - 2024-05-09

Initial version.
