# DevinD (Dev in Docker) - Buildflow Management with Docker and Makefiles

## Introduction

**DevinD (Dev in Docker)** is a flexible tool designed to manage development workflows using Makefiles. It provides a unified way to build, test, and execute development tasks across multiple environments such as local machines, Docker containers, remote machines, and remote Docker containers. DevinD ensures that the build process remains consistent and easy to manage, even when targeting different execution environments.

## Features

- **Unified Makefile Workflow**: Manage build, test, and execution tasks with a consistent interface using Makefiles.
- **Local Execution**: Run goals locally on your machine if the required tools are installed.
- **Dockerized Execution**: Seamlessly execute goals inside a local Docker container.
- **Remote Execution**: Execute goals on a remote machine via SSH for distributed environments.
- **Remote Docker Execution**: Execute goals inside a remote Docker container.
- **Configurable Execution Targets**: Each goal can depend on specific configurations that define how and where it should be executed (locally, in Docker, or remotely).

## Execution Strategy Overview

**DevinD** offers flexibility in managing execution across local, Docker, remote, and remote Docker environments. The selected strategy for execution is the **`devind` Wrapper Script**.

### `devind` Wrapper Script

The **`devind` wrapper script** is designed to seamlessly manage different execution environments while keeping the existing Makefile-based workflow intact. Here's how it works:

- **Local Execution**: For basic local execution, the primary `Makefile` remains the main tool, handling tasks with no special configurations needed.
  
- **Configured Execution**: The `devind` script wraps around the `Makefile`, providing the necessary environment configurations to facilitate running goals in Docker containers or remote machines. This ensures the build process remains consistent across environments and requires minimal modification of existing projects.

- **Scalability**: The `devind` script is scalable and can be adapted to different projects without modifying the existing Makefile. It simply manages execution environments and configuration, keeping the build process intact.

### Benefits of the `devind` Wrapper Script:
- **No Disruption to Existing Projects**: The wrapper script doesn’t require changes to the existing Makefile structure or workflows, ensuring backward compatibility.
- **Environment Abstraction**: The `devind` script abstracts away the complexity of managing different environments, such as Docker or remote execution, from the developer's workflow.
- **Long-Term Flexibility**: It provides the flexibility to easily switch or add new environments, such as Docker containers or remote SSH execution, without altering the project’s core logic.

## Contribution

Contributions are welcome! If you'd like to contribute to **DevinD**, please follow these steps:

1. **Fork the Repository**: Start by forking the repository to your own GitLab account.
2. **Create a Feature Branch**: Create a new branch for your feature or bug fix.
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Commit Your Changes**: Make your changes and commit them with a clear and descriptive commit message.
   ```bash
   git commit -m "Add new feature: your-feature-name"
   ```
4. **Push to Your Fork**: Push your branch to your forked repository on GitLab.
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create a Merge Request**: Open a Merge Request (MR) in the original repository. Be sure to provide a detailed description of your changes and any relevant context.
6. **Review and Merge**: After your MR is reviewed and approved, it will be merged into the main branch.

Please ensure that your contributions are well-documented and include tests where applicable. Following these steps will help streamline the review and integration process.

## License

This project is licensed under the MIT License. You are free to use, modify, and distribute this software under the terms of the MIT License. For more details, please see the [LICENSE](./LICENSE) file included in this repository.
