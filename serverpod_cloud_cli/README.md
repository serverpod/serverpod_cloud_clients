[![Serverpod banner](https://github.com/serverpod/serverpod/raw/main/misc/images/github-header.webp)](https://github.com/serverpod/serverpod)

# Serverpod Cloud CLI

The Serverpod Cloud CLI provides all you need to create, manage, and deploy your
Serverpod projects in Serverpod Cloud.

> If you're new to developing with Serverpod, check out the [create a Serverpod project guide](https://docs.serverpod.dev/get-started) in the Serverpod framework docs!


## Getting Started

Run the following to install the CLI:

```sh
dart pub global activate serverpod_cloud_cli
```

Log in to your Serverpod Cloud account using the CLI:
<br/>(If you don't have a Serverpod Cloud account yet, visit [Serverpod Cloud](https://serverpod.cloud/).)

```sh
scloud auth login
```

Go to your Serverpod server directory (e.g. `./myproject/myproject_server`)
and run the [`launch` command](https://docs.serverpod.cloud/references/cli/commands/launch)
to get an interactive, guided set up of a new Serverpod Cloud project:

```sh
scloud launch
```

If the project requires any environment variables or secrets, they can be added with the [`env`](https://docs.serverpod.cloud/references/cli/commands/env) and [`secret`](https://docs.serverpod.cloud/references/cli/commands/secret) commands. Once the project is ready to be deployed, run the following command:

```sh
scloud deploy
```

To follow the progress of the deployment, use the [`status deploy` command](https://docs.serverpod.cloud/references/cli/commands/status):

```sh
scloud status deploy
```

That's it, you have now deployed your Serverpod app! 🚀

For more information on the different commands, see the commands section in the side menu. For instance, to view the service's domains or to add your own custom domains, see the [`domain` command](https://docs.serverpod.cloud/references/cli/commands/domain).


## Online documentation

The Serverpod Cloud CLI documentation:

https://docs.serverpod.cloud/references/cli/introduction


Guide to getting started with Serverpod Cloud:

https://docs.serverpod.cloud/getting-started
