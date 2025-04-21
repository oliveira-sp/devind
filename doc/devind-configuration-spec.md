# DevinD YAML Configuration Specification

The **DevinD** project uses a YAML configuration file to define the development environments, targets, and goals for the build system. This configuration provides a flexible way to manage and customize the behavior of different environments (such as local or Docker) and to map those environments to specific Makefile targets.

The YAML structure supports profiles, devtargets, and goals, allowing you to define reusable variables, modify execution commands, and set up multiple development environments in a clean and manageable way.

## Table of Contents

1. [Introduction](#introduction)
2. [Top-Level Structure Overview](#top-level-structure-overview)
3. [Detailed Breakdown](#detailed-breakdown)
   - [default_devtarget](#default_devtarget)
   - [global](#global)
   - [profiles](#profiles)
   - [devtargets](#devtargets)
   - [goals](#goals)
4. [Variable Assignment and Appending](#variable-assignment-and-appending)
5. [Configuration Example](#configuration-example)
6. [Summary](#summary)

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
    CMD_PREFIX: value          # Required. Command prefix used to execute the target.
    CMD_SUFFIX: value          # Optional. Command suffix added after the Makefile goal.

goals:                         # Required. Map Makefile targets to devtargets or profiles.
  make_target: devtarget profile ...   # Goal mappings to devtargets or profiles.
```

---

## Detailed Breakdown

### **default_devtarget**
The `default_devtarget` specifies which devtarget is used if no specific devtarget is defined for a Makefile goal. This ensures that there is always a valid devtarget when running a goal.

Example:
```yaml
default_devtarget: dev_local  # Use "dev_local" as the fallback if no devtarget is provided for a goal.
```

### **global**
The `global` section is optional and allows you to define variables that can be accessed by all profiles, devtargets, and goals. These variables are available globally within the configuration.

Example:
```yaml
global:
  DOCKER_IMAGE: example/devind:1.0  # Global variable accessible across all profiles and devtargets.
```

### **profiles**
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

### **devtargets**
Devtargets are **required** and define specific execution environments like local, Docker, or SSH. A devtarget can:
- Inherit one or more profiles.
- Define its own variables.
- Specify `CMD_PREFIX` (mandatory) and `CMD_SUFFIX` (optional) for how the target will be executed.

**Important Note**: `CMD_PREFIX` is required for every devtarget. However, if it is already defined in an inherited profile (e.g., `docker`), it **does not need to be redefined** in the devtarget. Only if `CMD_PREFIX` is not defined in the inherited profile(s), it should be specified within the devtarget.

Example:
```yaml
devtargets:
  local:
    CMD_PREFIX: $(CMD_EXEC)  # Defined here because CMD_PREFIX is not set in profiles for 'local'

  docker-build:
    profiles:
      - docker  # Inherits CMD_PREFIX from the docker profile
      - docker_remove
      - docker_interactive
    var:
      DOCKER_NAME: my-docker-build-container
      DOCKER_OPT+: --name $(DOCKER_NAME)
    CMD_SUFFIX: -f Dockerfile  # Optional; defined here if needed, otherwise inherited from profiles.
```

### **goals**
The `goals` section maps Makefile targets to devtargets or profiles. This mapping determines which devtarget or profile is executed when a Makefile goal is triggered.

Example:
```yaml
goals:
  build-*: dev-docker-build  # All build-* targets map to dev-docker-build
  b: dev-docker-build profile-dummy  # Goal "b" uses the "dev-docker-build" devtarget with "profile-dummy".
```

---


## Variable Assignment and Appending

Variable declarations in the YAML configuration are **based directly on Makefile syntax and semantics**, with conventions to support both immediate assignment (`:=`) and appending (`+=`). These variable definitions are translated directly into valid Makefile logic.

### Standard Assignment

Use a colon (`:`) in YAML to assign a value to a variable. This corresponds to `:=` in a Makefile, meaning the value is **evaluated immediately** when the Makefile is generated.

```yaml
global:
  CMD_EXEC: make -f $(DEVIND_MAKEFILE_ENTRY)
```

This becomes:

```make
CMD_EXEC := make -f $(DEVIND_MAKEFILE_ENTRY)
```

> Make sure any variables used in the right-hand side (like `$(DEVIND_MAKEFILE_ENTRY)`) are already defined earlier in the configuration, or their value will be empty when expanded.


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


### Expansion Order

Although `:=` is used internally (immediate expansion), the order in which values are declared and applied is critical for correct resolution of variable references:

1. **Global variables** (`global:`) are evaluated first and are visible to all profiles and devtargets.
2. **Profiles** are processed next and may override or append to global variables.
3. **Devtarget variables** (`devtargets[*].var:`) are applied after profiles and can rely on globals and profiles.
4. **`CMD_PREFIX` and `CMD_SUFFIX`** are expanded **last**, allowing them to reference all other variables safely—even those defined in profiles or devtargets.

---

## Configuration Example

Here’s a simple example of a complete **DevinD** YAML configuration file:

```yaml
default_devtarget: dev_local

global:
  DOCKER_IMAGE: example/devind:1.0
  CMD_EXEC: make -f $(DEVIND_MAKEFILE_ENTRY)

profiles:
  docker:
    DOCKER_CMD: docker run
  docker_interactive:
    DOCKER_OPT+: -it
  docker_remove:
    DOCKER_OPT+: --rm
  docker-bind-workspace:
	  DOCKER_OPT+: -v .:/home/dev
	  DOCKER_OPT+: -w /home/dev
  dummy:
    DUMMY_VAR: $(FOO)

devtargets:
  local:
    CMD_PREFIX: $(CMD_EXEC)

  docker-build:
    profiles:
      - docker
      - docker_remove
      - docker_interactive
      - docker-bind-workspace
    var:
      DOCKER_NAME: my-docker-build-container
      DOCKER_OPT+: --name $(DOCKER_NAME)
    CMD_PREFIX: $(DOCKER_CMD) $(DOCKER_OPT) $(DOCKER_IMAGE) $(CMD_EXEC)

goals:
  build-*: dev-docker-build
  b: dev-docker-build profile-dummy
```

---

## Summary

This specification outlines the structure and usage of the YAML configuration file used in **DevinD**. It covers the following key components:

- **Profiles**: Reusable setups that can be inherited by devtargets.
- **Devtargets**: Specific execution environments that map to Makefile targets.
- **Goals**: Mappings of Makefile targets to devtargets or profiles.
- **Variable Assignment**: Supports Makefile-like variable assignments and appending using the `+` syntax.

By following this structure, you can efficiently manage and customize your development environments, ensuring that different execution contexts can be easily defined and reused.
