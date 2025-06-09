# DevinD - Multi-Environment Build and Development Flow Management

## Introduction

**DevinD** is a flexible wrapper tool designed to enhance and manage build and development workflows centered around Makefile projects. It acts as a configurable execution layer that transparently runs your Makefile targets across various environments, including but not limited to:

- Local machine execution
- Local containerized environments (e.g., Docker)
- Remote machines accessed via SSH
- Containers running on remote hosts
- Custom environments that can be extended as needed

While DevinD is Makefile-focused, its design allows integration with other build or automation tools, making it a versatile solution for consistent, portable, and environment-agnostic task execution. It requires minimal changes to existing projects and enables teams to scale workflows from simple local builds to complex multi-environment deployments.

## Features

- **Makefile Wrapper**: Seamlessly integrates with existing Makefile projects, wrapping your build scripts without requiring modifications.

- **Multi-Environment Execution**: Run tasks locally, inside local or remote containers, or on remote machines—extensible to custom environments as needed.

- **Configurable Execution Targets**: Define custom environment configurations per goal to control exactly where and how each task runs.

- **Unified Workflow**: Manage builds, tests, and executions consistently across all environments through a single interface.

- **Portable & Lightweight**: Requires only standard tools (`make`, `awk`, `bash`), making it easy to use across diverse Unix-like systems without extra dependencies.

- **Minimal Intrusion**: Adds powerful environment abstraction without disrupting existing project workflows.

- **Scalable**: Suitable for both simple local setups and complex distributed development environments.


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

### Verify Installation

Run the built-in help command to confirm DevinD is functional:

```sh
cd src
./devind help
```

### Run the Hello-World Example

Before running the example, build the required Docker image:

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

## Integrate DevinD in Your Project

### 1. Add DevinD Scripts

Copy the following files into your project root or a dedicated tools folder:

- `devind` (main wrapper script)
- `devind_yaml_parser.awk` (required YAML parser)

> ⚠️ Ensure the `devind` script has execution permissions:
>
> ```sh
> chmod +x devind
> ```

### 2. Configure DevinD (Optional)

Run the interactive configuration to create a `.devindrc` file with default variables:

- `DEVIND_MAKEFILE_ENTRY`
- `DEVIND_FOLDER`
- `DEVIND_YAML_FILE`

```sh
./devind configure-devind
```

This step is optional, but recommended to explicitly define where configuration and generated files will reside.

### 3. Create YAML Configuration

Define your project setup in a YAML file (default: `devind.yaml`):

* Set up `profiles`, `devtargets`, and `goals`
* Map each goal to a specific execution environment
* Include variables like `CMD_PREFIX`, `CMD_EXEC`, `CMD_SUFFIX` for goal behavior

> ✅ Example YAML configurations are available in `examples/`
> 📖 For the full format, see [`docs/devind-yaml-specification.md`](docs/devind-yaml-specification.md)

### 4. Example Usage

Use DevinD to execute a configured goal:

```sh
./devind <goal>
```

This runs the specified goal in the resolved environment using the configuration from your YAML file.


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
   ./devind hello
   ```

   Resolves the `hello` goal to `dev-docker`, applies the relevant profiles, merges the variables, and executes:

   ```sh
   docker run --rm -it -v .:/work -w /work hello-devind:latest make -f <your-makefile> hello
   ```

   Running an undefined goal like:

   ```sh
   ./devind build
   ```

   Will still work, using the `default_devtarget` (`dev-local` in this example), and executing:

   ```sh
   make -f <your-makefile> build
   ```

> 💡 **Tip:** If `CMD_EXEC` is not defined (either directly or via `DEFAULT_CMD_EXEC`), DevinD will **skip execution** for that goal — making it easy to define goals that only manipulate environments or perform non-command steps.

## Contribution

Contributions are welcome! To contribute:

1. **Fork the Repository**
2. **Create a Feature Branch**

   ```sh
   git checkout -b feature/your-feature-name
   ```
3. **Commit Changes**

   ```sh
   git commit -m "Add feature: your-feature-name"
   ```
4. **Push and Create MR**

   ```sh
   git push origin feature/your-feature-name
   ```

Submit a Merge Request (MR) with a detailed description. Please keep changes well-documented and tested.

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
