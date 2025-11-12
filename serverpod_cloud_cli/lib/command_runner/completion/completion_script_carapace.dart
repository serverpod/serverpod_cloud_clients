/// This file is auto-generated.
library;

import 'package:cli_tools/better_command_runner.dart' show CompletionTool;

const String _completionScript = r'''
# yaml-language-server: $schema=https://carapace.sh/schemas/command.json
name: scloud
persistentFlags:
  -q, --quiet: "Suppress all cli output. Is overridden by  -v, --verbose."
  -v, --verbose: "Prints additional information useful for development. Overrides --q, --quiet."
  -a, --analytics: "Toggles if analytics data is sent."
  --no-analytics: "Toggles if analytics data is sent."
  --version: "Prints the version of the Serverpod Cloud CLI."
  -d, --project-dir=: "The path to the Serverpod Cloud project server directory."
  --project-config-file=: "The path to the Serverpod Cloud project configuration file."
  --project-config-content=: "Override the scloud project configuration with a YAML string."
  --connection-timeout=: "The timeout for the connection to the Serverpod Cloud API."
  --skip-confirmation: "Automatically accept confirmation prompts. For use in non-interactive environments."
exclusiveFlags:
  - [analytics, no-analytics]
completion:
  flag:
    project-dir: ["$directories"]
    project-config-file: ["$files"]

commands:
  - name: completion

    commands:
      - name: generate
        flags:
          -t, --tool=!: "The completion tool to target"
          -e, --exec-name=: "Override the name of the executable"
          -f, --file=: "Write the specification to a file instead of stdout"
        completion:
          flag:
            tool: ["completely", "carapace"]
            file: ["$files"]

      - name: install
        flags:
          -t, --tool=!: "The completion tool to target"
          -e, --exec-name=: "Override the name of the executable"
          -d, --write-dir=: "Override the directory to write the script to"
        completion:
          flag:
            tool: ["completely", "carapace"]
            write-dir: ["$directories"]

  - name: version

  - name: auth

    commands:
      - name: login
        flags:
          -t, --timeout=: "The time to wait for the authentication to complete."
          --persistent: "Store the authentication credentials."
          --no-persistent: "Store the authentication credentials."
          --browser: "Allow CLI to open browser for logging in."
          --no-browser: "Allow CLI to open browser for logging in."
        exclusiveFlags:
          - [persistent, no-persistent]
          - [browser, no-browser]

      - name: logout

  - name: project

    commands:
      - name: create
        flags:
          -p, --project=!: "The ID of the project. Can be passed as the first argument."
          --enable-db: "Flag to enable the database for the project."
          --no-enable-db: "Flag to enable the database for the project."
        exclusiveFlags:
          - [enable-db, no-enable-db]

      - name: delete
        flags:
          -p, --project=!: "The ID of the project. Can be passed as the first argument."

      - name: list
        flags:
          --all: "Include deleted projects."

      - name: link
        flags:
          -p, --project=!: "The ID of the project. Can be passed as the first argument."

      - name: invite
        flags:
          -p, --project=!: "The ID of the project. Can be passed as the first argument.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          -u, --user=!: "The user email address."
          -r, --role=*!: "One or more project roles to assign."
        completion:
          flag:
            role: ["admin"]

      - name: revoke
        flags:
          -p, --project=!: "The ID of the project. Can be passed as the first argument.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          -u, --user=!: "The user email address. Can be passed as the second argument."
          -r, --role=*: "One or more project roles to revoke."
          --all: "Revoke all roles of this project from the user."
        completion:
          flag:
            role: ["admin"]

  - name: deploy
    flags:
      -p, --project=!: "The ID of the project. Can be passed as the first argument.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
      -c, --concurrency=: "Number of concurrent files processed when zipping the project."
      --dry-run: "Do not actually deploy, just print the deployment steps."
      --no-dry-run: "Do not actually deploy, just print the deployment steps."
    exclusiveFlags:
      - [dry-run, no-dry-run]

  - name: variable

    commands:
      - name: list
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."

      - name: create
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The name of the environment variable. Can be passed as the first argument."
          --value=: "The value of the environment variable. Can be passed as the second argument."
          --from-file=: "The name of the file with the environment variable value."
        completion:
          flag:
            from-file: ["$files"]

      - name: update
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The name of the environment variable. Can be passed as the first argument."
          --value=: "The value of the environment variable. Can be passed as the second argument."
          --from-file=: "The name of the file with the environment variable value."
        completion:
          flag:
            from-file: ["$files"]

      - name: delete
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The name of the environment variable. Can be passed as the first argument."

  - name: domain

    commands:
      - name: attach
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The custom domain name. Can be passed as the first argument."
          -t, --target=!: "The Serverpod server target of the custom domain, only one can be specified."
        completion:
          flag:
            target: ["api", "insights", "web"]

      - name: list
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."

      - name: detach
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The custom domain name. Can be passed as the first argument."

      - name: verify
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The custom domain name. Can be passed as the first argument."

  - name: log
    flags:
      -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
      --limit=: "The maximum number of log records to fetch."
      -u, --utc: "Display timestamps in UTC timezone instead of local."
      --no-utc: "Display timestamps in UTC timezone instead of local."
      -r, --recent=: "Fetch records from the recent period length; s (seconds) by default. Can also be specified as the first argument."
      --before=: "Fetch records from before this timestamp."
      --after=: "Fetch records from after this timestamp."
      --tail: "Tail the log and get real time updates."
    exclusiveFlags:
      - [utc, no-utc]

  - name: deployments

    commands:
      - name: show
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          -u, --utc: "Display timestamps in UTC timezone instead of local."
          --no-utc: "Display timestamps in UTC timezone instead of local."
          --deploy=: "View a specific deployment, with uuid or sequence number, 0 for latest. Can be passed as the first argument."
          --output-overall-status: "View a deployment's overall status as a single word, one of: success, failure, awaiting, running, cancelled, unknown."
        exclusiveFlags:
          - [utc, no-utc]

      - name: list
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --limit=: "The maximum number of records to fetch."
          -u, --utc: "Display timestamps in UTC timezone instead of local."
          --no-utc: "Display timestamps in UTC timezone instead of local."
        exclusiveFlags:
          - [utc, no-utc]

      - name: build-log
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          -u, --utc: "Display timestamps in UTC timezone instead of local."
          --no-utc: "Display timestamps in UTC timezone instead of local."
          --deploy=: "View a specific deployment, with uuid or sequence number, 0 for latest. Can be passed as the first argument."
        exclusiveFlags:
          - [utc, no-utc]

  - name: secret

    commands:
      - name: create
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The name of the secret. Can be passed as the first argument."
          --value=: "The value of the secret. Can be passed as the second argument."
          --from-file=: "The name of the file with the secret value."
        completion:
          flag:
            from-file: ["$files"]

      - name: list
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."

      - name: delete
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --name=!: "The name of the secret. Can be passed as the first argument."

  - name: db

    commands:
      - name: connection
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."

      - name: create-superuser
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --username=!: "The username of the DB user to create."

      - name: reset-password
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."
          --username=!: "The username of the DB user to create."

  - name: launch
    flags:
      --project=: "The ID of an existing project to use."
      --new-project=: "The ID of a new project to create."
      --enable-db: "Flag to enable the database for the project."
      --no-enable-db: "Flag to enable the database for the project."
      --deploy: "Flag to immediately deploy the project."
      --no-deploy: "Flag to immediately deploy the project."
    exclusiveFlags:
      - [enable-db, no-enable-db]
      - [deploy, no-deploy]

  - name: user

    commands:
      - name: list
        flags:
          -p, --project=!: "The ID of the project.\nCan be omitted for existing projects that are linked. See `scloud project link --help`."

  - name: settings
    flags:
      --analytics: "Toggles if analytics data is sent."
      --no-analytics: "Toggles if analytics data is sent."
    exclusiveFlags:
      - [analytics, no-analytics]


''';

/// Embedded script for command line completion for `carapace`.
const completionScriptCarapace = (
  tool: CompletionTool.carapace,
  script: _completionScript,
);
