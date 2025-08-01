# DevinD YAML Configuration Specification

The **DevinD** project uses a YAML configuration file to define the development environments, targets, and goals for the build system. This configuration provides a flexible way to manage and customize the behavior of different environments (such as local or Docker) and to map those environments to specific Makefile targets.

The YAML structure supports profiles, devtargets, and goals, allowing you to define reusable variables, modify execution commands, and set up multiple development environments in a clean and manageable way.

## Table of Contents

1. [Introduction](#introduction)
2. [Top-Level Structure Overview](#top-level-structure-overview)
3. [Internal Variables](#internal-variables)
4. [Detailed Breakdown](#detailed-breakdown)
   - [default_devtarget](#default_devtarget)
   - [global](#global)
   - [profiles](#profiles)
   - [devtargets](#devtargets)
   - [goals](#goals)
5. [Variable Assignment and Appending](#variable-assignment-and-appending)
6. [Configuration Example](#configuration-example)
7. [Summary](#summary)

---

## Introduction

The **DevinD YAML configuration file** defines the structure for development environments, target execution behaviors, and goal mappings. The configuration consists of several key sections: `global`, `profiles`, `devtargets`, and `goals`. These sections allow users to specify variables, profiles, and devtargets to simplify the management of multiple environments and goal mappings in the project. 

By structuring the configuration with clear profiles and devtarget definitions, the DevinD system ensures that environment-specific settings are reusable and easy to maintain.

---

## Top-Level Structure Overview

Below is a high-level overview of the configuration structure, with explanations for each section:

```yaml
default_devtarget: dev_local   # Default devtarget used if none is explicitly defined for a goal.

global:                        # Optional. Global variables used throughout profiles, devtargets, and goals.
  VAR_NAME: value

profiles:                      # Optional. Define reusable profiles for common configurations.
  profile_name:
    VAR: value                 # Assign a value to a variable.
    VAR+: value                # Append to an existing variable.

devtargets:                    # Required. Define devtargets that map to execution environments.
  devtarget_name:
    profiles:                  # Optional. List of profiles inherited by this devtarget.
      - profile_name
    var:                       # Optional. Additional variables specific to this devtarget.
      VAR: value
      VAR+: value
      CMD_PREFIX: value        # Optional. Command prefix used to execute the target.
      CMD_SUFFIX: value        # Optional. Command suffix added after the Makefile goal.

goals:                         # Required. Map Makefile targets to devtargets or profiles.
  make_target: devtarget profile_name  # Goal mappings specify devtarget and optional profiles.
```

---

## Internal Variables

DevinD uses a set of **internal variables** during goal execution. These are divided into:

- **Execution Variables (`CMD_XXX`)** – Meant to be **customized by users**.
- **Goal Context Variables** – **Reserved** and automatically set by DevinD; **advanced users only** may reference them.


### Command Execution Variables

These variables control how the final command is executed by DevinD when a goal is run.
They **should be configured as needed in YAML** (within profiles, devtargets, or global section).

| Variable     | Description                                                 | Example                            |
| ------------ | ----------------------------------------------------------- | ---------------------------------- |
| `CMD_PREFIX` | Optional. Wrapper or environment initializer.               | `docker run -v $(PWD):/src my-img` |
| `CMD_EXEC`   | Optional. The main command to run.                          | `make -f Makefile`                 |
| `CMD_SUFFIX` | Optional. Arguments or flags passed after the main command. | `all DEBUG=1`                      |

The final command is built as:
```make
$(CMD_PREFIX) $(CMD_EXEC) $(CMD_SUFFIX)
```

#### Notes:

- All parts are optional.
- You are responsible for ensuring the assembled command is valid.
- You may explicitly set CMD_EXEC := to suppress execution.

### Goal Context Variables (Reserved)

These are automatically computed by DevinD based on the goal configuration and **must not be defined or overridden in YAML**.
They are available for **advanced use cases only**, such as in custom Makefile rules or debugging.

| Variable             | Description                                           | Example                      |
| -------------------- | ----------------------------------------------------- | ---------------------------- |
| `GOAL_PROFILES`      | Profiles explicitly assigned to the goal.             | `default cross x86`          |
| `GOAL_DEVTARGET`     | Devtarget assigned to the goal (with `dev-` prefix).  | `dev_local`                  |
| `DEVTARGET`          | Raw devtarget name (`GOAL_DEVTARGET` without `dev-`). | `local`                      |
| `DEVTARGET_PROFILES` | Profiles inherited from the devtarget.                | `docker-env arm64-toolchain` |

#### Advanced Use Only:

These are intended for debugging, diagnostics, or advanced Makefile logic.
They are populated by DevinD and not meant to be modified by the user.
## Detailed Breakdown

### `default_devtarget`
The `default_devtarget` specifies which devtarget is used if no specific devtarget is defined for a Makefile goal. This ensures that there is always a valid devtarget when running a goal.

Example:
```yaml
default_devtarget: dev_local  # Use "dev_local" as the fallback if no devtarget is provided for a goal.
```

### `global`
The `global` section is optional and allows you to define variables that can be accessed by all profiles, devtargets, and goals. These variables are available globally within the configuration.

Example:
```yaml
global:
  DOCKER_IMAGE: example/devind:1.0  # Global variable accessible across all profiles and devtargets.
```

### `profiles`
Profiles are optional and provide reusable configurations for various environments. You can define settings and variables that are commonly shared among devtargets, which can inherit these profiles.

- Variables within a profile are defined with `VAR: value`.
- To append to an existing variable, use `VAR+: value` (explained later in the "Variable Assignment and Appending" section).

Example:
```yaml
profiles:
  docker:
    DOCKER_CMD: docker run
    CMD_PREFIX: $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE) $(CMD_EXEC)  # Inherited by devtargets
  docker_interactive:
    DOCKER_OPT+: -it
  docker_remove:
    DOCKER_OPT+: --rm
  dummy:
    DUMMY_VAR: dummy  # Example profile for dummy variable.
```

### `devtargets`

Devtargets define **execution environments** (e.g., local, Docker, SSH) and are **required**.

Each devtarget can:

* Inherit one or more profiles (which may define or append common variables).
* Define or override its own variables.

Example:

```yaml
devtargets:
  local:
    var:
      CMD_EXEC: make $(GOAL)  # Just runs make

  docker-build:
    profiles:
      - docker-remove           # append options in DOCKER_OPT var
      - docker-interactive      # append options in DOCKER_OPT var
      - docker-bind-workspace   # append options in DOCKER_OPT var
    var:
      DOCKER_IMAGE: example/devind:1.0
      DOCKER_NAME: my-docker-build-container
      DOCKER_OPT+: --name $(DOCKER_NAME)
      CMD_PREFIX: docker run $(DOCKER_OPT) $(DOCKER_IMAGE)
      CMD_EXEC: make $(GOAL)
```

Variables from profiles and devtargets are combined according to inheritance and appending rules.

### `goals`

The `goals` section maps Makefile targets to a list of tokens representing devtargets and profiles.

- Exactly one devtarget token **must** be present per goal, and it **must** be prefixed with `dev-`.
- If multiple devtarget tokens are specified, devind will fail with an error.
- Tokens without the `dev-` prefix are interpreted as profiles.
- **Profiles do not use the `profile-` prefix** in goal definitions.
- Goal-level profiles are applied **after** the devtarget and any profiles inherited by that devtarget.
- Variable definitions in goal-level profiles **override** variables set by devtargets or inherited profiles.

Example:

```yaml
goals:
  a_goal: dev-a profileA profileB
  another_goal: dev-b profileX
  third_goal: dev-c profileY profileZ
```

Explanation:

- For `a_goal`, devtarget `dev-a` is used, with profiles `profileA` and `profileB`.
- For `another_goal`, devtarget `dev-b` is used, with profile `profileX`.
- For `third_goal`, devtarget `dev-c` is used, with profiles `profileY` and `profileZ`.
- Variables defined in goal-level profiles (e.g., `profileA`, `profileB`, `profileX`, etc.) override variables from the devtarget and its inherited profiles.

---


## Variable Assignment and Appending

Variable declarations in the YAML configuration follow Makefile semantics:

- **Immediate assignment** via `VAR: value`, which corresponds to `:=` in Makefile (evaluated at parse time).
- **Appending** via `VAR+: value`, which corresponds to `+=` in Makefile, adding to existing variable content.

This approach enables modular and incremental variable construction across profiles, devtargets, and goals.

### Standard Assignment

Use a colon (`:`) in YAML to assign a value to a variable. This corresponds to `:=` in a Makefile, meaning the value is evaluated when the Makefile is parsed by make.

```yaml
global:
  CMD_EXEC: make -f $(DEVIND_MAKEFILE_ENTRY)
```

This becomes:

```make
CMD_EXEC := make -f $(DEVIND_MAKEFILE_ENTRY)
```

### Appending to Variables

To append to an existing variable (similar to `+=` in Makefiles), use a `+` suffix on the key name in YAML:

```yaml
profiles:
  docker_interactive:
    DOCKER_OPT+: -it
  docker_remove:
    DOCKER_OPT+: --rm
```

This becomes:

```make
DOCKER_OPT += -it
DOCKER_OPT += --rm
```

> This approach allows multiple profiles and devtargets to extend variables cleanly and modularly without overriding previous values.


### Expansion and Override Order

The variable expansion and override order is as follows to ensure correct resolution and layering of settings:

1. **Global variables** (`global:`) are applied first and are visible everywhere.
2. **Profiles** (inherited by devtargets) are applied next, potentially overriding or appending to global variables.
3. **Devtarget variables** are applied after profiles, overriding or appending as needed.
4. **Goal-level profiles** (if any) are applied last, overriding variables from devtargets and profiles.

> Variables are expanded **only at runtime** by `devind`, not during YAML parsing or Makefile generation. Variable references (e.g., `$(VAR)`) remain unresolved in the generated Makefile and are substituted when commands are executed.


This design ensures flexible layering and late binding of variables.


---

## Configuration Example

Here’s a simple example of a complete **DevinD** YAML configuration file:

```yaml
default_devtarget: dev-local

global:
  DOCKER_IMAGE: example/devind:1.0
  CMD_EXEC: make -f $(DEVIND_MAKEFILE_ENTRY)

profiles:
  docker:
    DOCKER_CMD: docker run
  docker-interactive:
    DOCKER_OPT+: -it
  docker-remove:
    DOCKER_OPT+: --rm
  docker-bind-workspace:
	  DOCKER_OPT+: -v .:/home/dev
	  DOCKER_OPT+: -w /home/dev
  dummy:
    DUMMY_VAR: $(FOO)

devtargets:
  local:
    var:
      CMD_PREFIX: $(CMD_EXEC)

  docker-build:
    profiles:
      - docker
      - docker-remove
      - docker-interactive
      - docker-bind-workspace
    var:
      DOCKER_NAME: my-docker-build-container
      DOCKER_OPT+: --name $(DOCKER_NAME)
      CMD_PREFIX: $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE) $(CMD_EXEC)

goals:
  build-*: dev-docker-build
  b: dev-docker-build
```

---

## Summary

This specification defines the core structure of the **DevinD** YAML configuration used to manage build and development environments.

* **Profiles**: Reusable variable sets that define shared configuration. Profiles can be inherited by devtargets and specified in goals for contextual overrides.
* **Devtargets**: Represent execution environments. Devtargets can define `CMD_PREFIX`, `CMD_EXEC`, and/or `CMD_SUFFIX` to control how commands are constructed and executed. These variables are optional, but the assembled command will always follow the form `$(CMD_PREFIX) $(CMD_EXEC) $(CMD_SUFFIX)`. Devtargets may inherit one or more profiles.
* **Goals**: Map Makefile targets to a **goal context** composed of exactly one devtarget token (prefixed with `dev-`) and optional unprefixed profiles. Goal-level profiles are applied last and override all inherited variables.
* **Variable Assignment**: Uses Makefile-style syntax: `VAR:` for assignment, `VAR+:` for appending. Supports layered overrides across global, profile, devtarget, and goal-profile scopes.

At goal execution time, DevinD assembles and runs the following command:

```make
$(CMD_PREFIX) $(CMD_EXEC) $(CMD_SUFFIX)
```

These `CMD_XXX` variables **should be configured in YAML** to define execution behavior. Other internal variables like `GOAL_PROFILES`, `GOAL_DEVTARGET`, `DEVTARGET`, and `DEVTARGET_PROFILES` are reserved and automatically set. These are available to advanced users for conditional logic in Makefiles, but must not be overridden.

This structure ensures predictable behavior and supports future features like hooks, plugin mechanisms, and advanced runtime behavior.
