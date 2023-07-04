# Usage: 

The output of the `docker run -it godoo --help` command shows the available commands and flags for the `godoo` tool. 

The `godoo` tool is used to prepare the environment for the Odoo Golang API wrapper. It provides several commands to manage Odoo models, install languages, install and upgrade modules, and get the version of the Odoo server.

Here's a brief description of the available commands:

- `add`: Adds the given Odoo model.
- `completion`: Generates the autocompletion script for the specified shell.
- `help`: Provides help about any command.
- `install-language`: Installs specified languages.
- `module-install`: Installs specified modules.
- `module-upgrade`: Upgrades specified modules.
- `server-version`: Returns the version for the specified server.
- `update`: Updates the given Odoo model.

The `-h` or `--help` flag can be used with any command to get more information about that command.

# Best practices for writing Odoo models

##### How to use the `godoo` tool to manage Odoo models

To use the `godoo` tool to manage Odoo models, you can use the `add` and `update` commands.

First, you may need to check the Odoo version of the server. You can use the `server-version` command to get the version of the Odoo server. Here's an example usage:

```bash
godoo server-version --uri=<odoo_url>
```

The `add` command is used to add a new Odoo model to the environment. Here's an example usage:

```bash
godoo add all --package=<model_name> --uri=<odoo_url> -d=<database_name> -u=<username> -p=<password>
```

This command adds a new Odoo model with the specified name to the environment. You need to provide the URL of the Odoo server, the name of the database, and the credentials of a user with sufficient permissions to access the model.

The `update` command is used to update an existing Odoo model in the environment. Here's an example usage:

```bash
godoo update all --package=<model_name> --uri=<odoo_url> -d=<database_name> -u=<username> -p=<password>
```

This command updates the existing Odoo model with the specified name in the environment. You need to provide the URL of the Odoo server, the name of the database, and the credentials of a user with sufficient permissions to access the model.

Both the `add` and `update` commands require the `--model`, `--url`, `--db`, `--username`, and `--password` flags to be specified. You can use the `--help` flag with either command to get more information about the available options.

##### What is the purpose of the `install-language`command in the `godoo` tool?

The `install-language` command in the `godoo` tool is used to install language packs for Odoo. 

Here's an example usage:

```bash
godoo install-language fr_FR --uri=<odoo_url> --database=<database_name> --username=<username> --password=<password>
```

This command installs the language pack for the specified language code in the Odoo instance. You need to provide the URL of the Odoo server, the name of the database, and the credentials of a user with sufficient permissions to install language packs.

The `<language_code>` argument specifies the code of the language pack to install. For example, to install the French language pack, you would use `fr_FR` as the language code.

The `install-language` command requires the `--uri`, `--database`, `--username`, and `--password` flags to be specified. You can use the `--help` flag with the command to get more information about the available options.