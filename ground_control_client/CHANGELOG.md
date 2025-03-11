# Changelog

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
