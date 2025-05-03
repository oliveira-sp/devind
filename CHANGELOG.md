# Changelog

## [0.1] - 2025-05-03
### Added
- Initial support for parsing `devind.yaml` configuration.
- Makefile generation based on defined `devtarget` environments.
- Execution of multiple Make goals via `./devind target_a target_b ...`, each using its respective `devtarget`.
- Default fallback `devtarget` resolution if none is set for a goal.

### Known Limitations
- No command-line help or usage documentation.
- No input validation or error diagnostics.
- No support for shell autocompletion.
- No configurable logging levels or verbosity controls.

---

This version establishes the baseline functionality for the DevinD tool and serves as the foundation for future usability and extensibility improvements.
