# DevinD (Dev in Docker) - Buildflow Management with Docker Compose and Makefiles

## Introduction

**DevinD (Dev in Docker)** is a project designed to manage development workflows efficiently using Makefiles in conjunction with Docker Compose. The primary goal is to provide a flexible system where you can build, test, and execute tools in various environments, including local, local Docker containers, and remote Docker containers/machines via SSH. This flexibility allows developers to work in environments that suit their needs while ensuring consistency across different execution contexts.

## Features

- **Unified Makefile Workflow**: Manage build, test, and execution tasks with a consistent interface using Makefiles.
- **Local Execution**: Run goals locally on your machine if the required tools are installed.
- **Dockerized Execution**: Seamlessly execute goals in a local Docker container using Docker Compose.
- **Remote Execution**: Execute goals on a remote Docker container or machine via SSH for distributed environments.
- **Configurable Execution Targets**: Each goal can depend on specific configurations that define how and where it should be executed (locally, in Docker, or remotely). 

## Execution Strategy Overview

**DevinD** integrates a unified approach to goal execution, managing local, Docker, and remote (SSH) environments. This approach combines two main propositions for implementing execution configurations and environments:

### Proposition 1: Unified `Makefile` with Execution Configurations

- **Local Execution**: The primary `Makefile` handles standard local executions. It assumes all necessary tools are installed on the local machine and runs the specified goals directly.

- **Configured Execution**: For scenarios where goals require specific configurations, the same `Makefile` can be used with additional parameters or configuration files. Execution details such as environment variables or configuration files can be specified to adjust how the goal is executed, whether locally, in Docker, or on a remote machine.

  - **Implementation**: Execution details are managed through environment variables or configuration options within the `Makefile`. For instance, setting `VAR_XY=something` or referencing a configuration file can influence the execution behavior.

### Proposition 2: `devind` Wrapper Script

- **Local Execution**: For basic local execution, the primary `Makefile` remains the main tool, handling tasks with no special configurations needed.

- **Configured Execution**: The `devind` script acts as a wrapper around the `Makefile`, providing an additional layer of handling for goals requiring specific configurations. It reads configuration files or environment variables to apply the appropriate settings and manage more complex scenarios, including Docker and remote executions.

  - **Implementation**: The `devind` script wraps around the `Makefile`, invoking it with the necessary configuration settings. It facilitates execution in Docker containers or on remote machines by managing the appropriate configurations and ensuring that goals are executed as specified.

### Evaluation and Next Steps

The effectiveness of these propositions will be evaluated to determine the most suitable approach for **DevinD**. Testing and refinement will guide the final implementation, aiming to ensure that the strategy provides the desired flexibility and efficiency in goal execution.

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
