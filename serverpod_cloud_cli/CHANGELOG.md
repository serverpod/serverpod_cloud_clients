
# Changelog

## [0.16.0] - 2025-11-13

### Added

- **Auth flow trigger** - Automatically trigger the authentication flow when a user tries to use a command that requires authentication but isn't logged in.
- **`--show-files` flag** - Introduce a new `--show-files` flag to the `scloud deploy` command to print the file tree that will be uploaded.

### Changed

- **`--before` and `--after` flags** - Rename the `--before` flag to `--until` and the `--after` flag to `--since` for the `scloud log` command.
- **`--connection-timeout` flag** - Rename the global `--connection-timeout` flag to `--timeout`. The auth flag `--timeout` is renamed to `--time-limit`.
- **`--skip-confirmation` flag** - Rename the global `--skip-confirmation` flag to `--yes`.
- **`deployment` command** - Move the `scloud status deploy` command to a new `scloud deployment show` command.
- **`--scloud-dir` flag** - Rename the global `--scloud-dir` flag to `--config-dir`.
- **`domain` subcommands** - Rename the `add` subcommand to `attach` and the `remove` subcommand to `detach` for the `scloud domain` command.
- **`env` command** - Rename the `scloud env` command to `scloud variable`.
- **`db user` commands** - Move the `create user` and `reset-password` commands under the `user` subcommand of `db`, like `scloud db user create`
- **Project link documentation** - Clarify the purpose of the `link` command in the help text.

### Fixed

- **Global token flag** - Make the `--token` flag visible for end users.

## [0.15.0] - 2025-11-10

### Added

- **Global options reference** - Added a global options reference page under the scloud reference section to document the usage of global options.
- **Project deployment status** - Project listings now include the last deployment timestamp. The `launch` command now only suggests existing projects that have never been deployed.

### Changed

- **Launch command location** - Moved the `launch` command into the "Getting started" command group to improve discoverability for new users.

## [0.14.0] - 2025-10-29

### Added

- **Cost confirmation prompt** - Added a prompt to confirm the cost impact when creating new projects with `scloud project create` and `scloud launch`.
- **Analytics via MixPanel** - Implemented analytics collection using MixPanel, with user consent and opt-out options. Analytics are suppressed for non-production environments or non-pub.dev installations, but can be forced via command line flags or environment variables.

### Changed

- **`launch` command project options** - Renamed the `--project` option to `--new-project` in the `launch` command for clarity, and re-added `--project` to specify an existing project.
- **Skip confirmation option** - Unhidden the `--skip-confirmation` option, allowing users to bypass the cost confirmation prompt in scripts and CI environments.

## 0.13.0 - 2025-10-27

### Added

- **Improved scloud UX** -  Improved error messaging when billing information is missing.

### Fixed

- **Improved plan procurement** - Improved error feedback on failed plan procurement and fixed issues related to active subscriptions.

## [0.12.0] - 2025-10-21

### Added

- **CLI completion** - The CLI now supports command line completion in most shells, making it easier to use `scloud` and `xcloud` commands.
- **Launch command proposes existing projects** - The `scloud launch` command now lists available projects and prompts users to select one for deployment, instead of creating a new one.

## [0.11.1] - 2025-10-03

- **Auto-procure subscriptions** - Automatically register subscriptions on relevant conditions

## [0.11.0] - 2025-10-03

### Added

- **Expanded project list details** - The admin project list in the CLI now includes the project owner and a full list of users with their roles in the project.

### Removed

- **Obsolete max-projects quota handling** - Removed obsolete handling of max-projects quota from `scloud`.

## [0.10.1] - 2025-09-01

### Fixed

- **Rename Owners role to Admin** - To avoid confusion, the "Owners" role has been renamed to "Admin".

## [0.10.0] - 2025-08-13

### Added

- **New auth module** - Migrated Ground Control, the `scloud` command, and the console app to use the new auth module.

## [0.9.0] - 2025-08-08

### Added

- **Billing screen form** - Added a fully functional billing form to the console, allowing users to input billing data and be redirected to the billing dashboard.

### Fixed

- **Scloud verification of tenant SDK version** - Updated version checks to align with Dart 3.8 and refactored tests for robustness.
- **Timeout error handling** - Improved error handling for timeouts by refactoring `gcs_file_uploader` to use `dio`, adding retries, and including test cases.
- **Invalid stages in deployment status** - Removed stages with an unknown status from the deployment status, returning null if the stage list is empty.
- **User onboarding bugs** - Corrected URL encoding in GC emails and fixed the project ID option in the project link command.
- **Project ID option for invite and revoke commands** - Configured the project ID option for invite and revoke subcommands to read values from `scloud.yaml` and updated help text.

### Changed

- **Public scloud README** - Fixed broken links, updated the command reference, and touched up the text.

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
