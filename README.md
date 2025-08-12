# DevinD - Multi-Environment Build and Development Flow Management

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Clone the Repository](#clone-the-repository)
  - [Build DevinD](#build-devind)
  - [Verify Installation](#verify-installation)
  - [Run the Hello-World Example](#run-the-hello-world-example)
  - [Integrate DevinD into Your Project](#integrate-devind-into-your-project)
    - [Build the DevinD script](#build-the-devind-script)
    - [Copy DevinD to your project](#copy-devind-to-your-project)
    - [Make it executable](#make-it-executable)
    - [(Optional) Configure DevinD](#optional-configure-devind)
    - [Create YAML Configuration](#create-yaml-configuration)
    - [Run DevinD](#run-devind)
- [How It Works](#how-it-works)
  - [Execution Flow](#execution-flow)
- [Testing](#testing)
- [Contribution](#contribution)
- [License](#license)

## Introduction

**DevinD** is a flexible wrapper tool designed to enhance and manage build and development workflows centered around Makefile projects. It acts as a configurable execution layer that transparently runs your Makefile targets across various environments, including but not limited to:

* Local machine execution
* Local containerized environments (e.g., Docker)
* Remote machines accessed via SSH
* Containers running on remote hosts
* Custom environments that can be extended as needed

While DevinD is Makefile-focused, its design allows integration with other build or automation tools, making it a versatile solution for consistent, portable, and environment-agnostic task execution. It requires minimal changes to existing projects and enables teams to scale workflows from simple local builds to complex multi-environment deployments.

## Features

* **Makefile Wrapper**: Seamlessly integrates with existing Makefile projects, wrapping your build scripts without requiring modifications.

* **Multi-Environment Execution**: Run tasks locally, inside local or remote containers, or on remote machines—extensible to custom environments as needed.

* **Configurable Execution Targets**: Define custom environment configurations per goal to control exactly where and how each task runs.

* **Inline Devtarget Overrides**: Override the YAML-defined devtarget on the command line by specifying a devtarget before one or more goals to control their execution environment.

  Example:

  ```sh
  ./devind dev-a build test dev-b lint package
  ```

  * `build` and `test` run with **dev-a**
  * `lint` and `package` run with **dev-b**

* **Unified Workflow**: Manage builds, tests, and executions consistently across all environments through a single interface.

* **Portable & Lightweight**: Requires only standard tools (`make`, `awk`, `bash`), making it easy to use across diverse Unix-like systems without extra dependencies.

* **Minimal Intrusion**: Adds powerful environment abstraction without disrupting existing project workflows.

* **Scalable**: Suitable for both simple local setups and complex distributed development environments.

## Getting Started

### Prerequisites

* Unix-like OS (Linux, macOS, BSD)
* Standard tools installed: `make`, `awk`, `bash`
* Git for source control
* Docker installed and running (required for examples using Docker devtargets)

### Clone the Repository

```sh
git clone https://gitlab.com/oliveira.s/devind.git
cd devind
```

### Build DevinD

Before running DevinD, you must build the distributable script:

```sh
make build
```

The resulting executable will be available at:

```
.build/devind
```

### Verify Installation

Run the built-in help command to confirm DevinD is functional:

```sh
./.build/devind help
```

### Run the Hello-World Example

First, build the required Docker image:

```sh
make docker-build -C examples/hello-world
```

This builds the `hello-devind:latest` Docker image used by the example.

Now run the `hello` goal using the root Makefile:

```sh
make run-example-hello-world GOALS=hello
```

This will execute the `hello` goal inside the `hello-world` example environment, demonstrating DevinD’s execution flow.

> **Note:** To see a list of available examples and their usage, run:
>
> ```sh
> make list-examples
> ```


### Integrate DevinD into Your Project

1. **Build the DevinD script**

   From the DevinD source repository:

   ```sh
   make build
   ```

   This creates the executable `.build/devind`.

2. **Copy DevinD to your project**

   Copy the built script to your project root or a dedicated tools folder:

   ```sh
   cp .build/devind /path/to/your/project/
   ```

3. **Make it executable**

   In your project, ensure the script has execution permissions:

   ```sh
   chmod +x /path/to/your/project/devind
   ```

4. **(Optional) Configure DevinD**

   Run the interactive configuration to create or update `.devindrc` for your project:

   ```sh
   ./devind configure-devind
   ```

5. **Create YAML Configuration**

   Define your project setup in a YAML file (default: `devind.yaml`):

   * Set up `profiles`, `devtargets`, and `goals`

   * Map each goal to a specific execution environment

   * Include variables like `CMD_PREFIX`, `CMD_EXEC`, `CMD_SUFFIX` for goal behavior

   > ✅ Example YAML configurations are available in `examples/`
   > 📖 For the full format, see [`docs/devind-yaml-specification.md`](docs/devind-yaml-specification.md)

6. **Run DevinD**

   Execute goals using:

   ```sh
   ./devind <goal>
   ```

## How It Works

DevinD is a Makefile-based task runner driven by a declarative YAML configuration. It wraps around `make` (or any shell-based tooling) to orchestrate builds and commands in a structured, environment-aware way. The `devind` Makefile contains all parsing, resolution, and execution logic, while the YAML file acts as the single source of truth for environment setup and goal-to-devtarget mappings.

### Execution Flow

1. **Parse Configuration**

   DevinD reads the `devind.yaml` configuration and resolves:

   * The `default_devtarget`
   * Any goal-to-devtarget overrides under `goals`
   * Profile compositions and inherited variables
   * Environment variable definitions (with support for overrides and `VAR+` appends)

2. **Generate Environment Files**

   Based on the resolved environment, DevinD generates Makefile fragments:

   * `global.mk`: shared variables
   * `profile-<name>.mk`: reusable config blocks
   * `dev-<target>.mk`: the resolved devtarget with merged variables

   These files are included at runtime to construct the active environment.

3. **Execute the Goal**

   Once the environment is resolved, DevinD builds the final command using:

   ```make
   $(CMD_PREFIX) $(CMD_EXEC) $(CMD_SUFFIX)
   ```

   These variables are computed from the layered scope resolution:

   * `global` scope (shared defaults)
   * `profiles` (optional mix-ins for environment composition)
   * `devtargets` (specific execution definitions per target)

   Each goal is mapped to a devtarget using the `goals` section. However, **if a goal is not listed**, DevinD will **still execute it using `default_devtarget`** and the inherited environment.

   Example YAML:

   ```yaml
   default_devtarget: dev-local

   global:
      DEVIND_MAKEFILE_ENTRY: Makefile
      DEFAULT_CMD_EXEC: make -f $(DEVIND_MAKEFILE_ENTRY) $(GOAL)

   profiles:
     docker:
       DOCKER_CMD: docker run
     docker-interactive:
       DOCKER_OPT+: -it
     docker-remove:
       DOCKER_OPT+: --rm
     docker-bind-workspace:
       DOCKER_OPT+: -v .:/work
       DOCKER_OPT+: -w /work

   devtargets:
     local:
       var:
         CMD_EXEC: $(DEFAULT_CMD_EXEC)

     docker:
       profiles:
         - docker
         - docker-remove
         - docker-interactive
         - docker-bind-workspace
       var:
         DOCKER_IMAGE: hello-devind:latest
         CMD_PREFIX: $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE)
         CMD_EXEC: $(DEFAULT_CMD_EXEC)

   goals:
     hello: dev-docker
   ```

   Running:

   ```sh
   ./.build/devind hello
   ```

   Resolves the `hello` goal to `dev-docker`, applies the relevant profiles, merges the variables, and executes:

   ```sh
   docker run --rm -it -v .:/work -w /work hello-devind:latest make -f Makefile hello
   ```

   Running an undefined goal like:

   ```sh
   ./.build/devind build
   ```

   Will still work, using the `default_devtarget` (`dev-local` in this example), and executing:

   ```sh
   make -f Makefile build
   ```

> 💡 **Tip:** If `CMD_PREFIX`, `CMD_EXEC`, and `CMD_SUFFIX` are all undefined, DevinD will **skip execution** for that goal — useful for defining goals that only adjust environments or perform non-command steps.

## Contribution

Contributions are welcome! To contribute:

1. **Fork the repository** (if you don’t have write access).

2. **Create a feature branch** following the Gitflow naming convention:

   ```sh
   git checkout -b feature/your-feature-name
   ```

   For bug fixes use `bugfix/`, for hotfixes use `hotfix/`, etc. Follow the Gitflow workflow for branch types.

3. **Commit your changes** following the Conventional Commits specification:

   ```sh
   git commit -m "feat: add your feature description"
   ```

   Other examples:

   ```sh
   git commit -m "feat: implement YAML override support"
   git commit -m "fix: correct devtarget selection in override mode"
   ```

4. **Push your branch** to the origin (your fork if applicable):

   ```sh
   git push -u origin feature/your-feature-name
   ```

5. **Create a Merge Request (MR) in GitLab**:

   * Set the target branch according to Gitflow (e.g., `develop` for features, `main` for hotfixes)
   * Link to any related issues
   * Add labels and milestones if applicable
   * Assign reviewers
   * Ensure your MR includes tests and updated documentation

Please keep changes well-documented, follow coding standards, and ensure all tests pass (`make test`) before requesting a merge.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
