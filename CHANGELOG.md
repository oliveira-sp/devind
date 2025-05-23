# Changelog

This file documents all notable changes to the DevinD project.

## [0.2] - 2025-05-24

### Added

* `configure` command to generate `.devindrc`.
* `help`, `devtargets`, and `profiles` commands.
* Logging with severity levels and colors.
* Dynamic devtarget resolution and Makefile generation.

### Changed

* Improved folder creation and target dispatch logic.
* YAML tool invocation via variables.

### Known Issues

* AWK parser script not embedded.
* No shell autocompletion.
* Minimal input validation.

## [0.1] - 2025-05-03
### Added
- Parsing of `devind.yaml` configuration files.
- Makefile generation based on `devtarget` environments.
- Execution of multiple Make goals via `./devind target_a target_b ...`, each using its respective `devtarget`.
- Default fallback `devtarget` resolution when none is explicitly set for a goal.

### Known Issues
- Missing command-line help and usage documentation.
- No input validation or error diagnostics.
- Shell autocompletion is not yet supported.
- Logging levels and verbosity controls are not configurable.

> This version establishes the baseline functionality for the DevinD tool and lays the foundation for future usability and extensibility improvements.
