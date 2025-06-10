# Software Requirements Specification (SRS) for DevinD

## 1. Introduction

### 1.1 Purpose
DevinD (Dev in Docker) is a flexible buildflow management tool designed to execute development tasks across multiple environments. It integrates with existing Makefile-based projects and ensures consistent execution locally, in Docker containers, on remote machines, and within remote Docker containers. The system abstracts environment complexities and provides a seamless experience through `make` and a wrapper script (`devind`).

### 1.2 Scope
DevinD aims to:
- Enable **local execution** directly with Makefiles.
- Allow execution inside **Docker containers** (local and remote).
- Support **remote execution via SSH** with or without Docker.
- Act as a **wrapper for existing Makefile projects**, preserving the existing build process while allowing additional configurations through separate files.
- Provide a unified interface (`devind`) to manage execution across environments.

### 1.3 Definitions, Acronyms, and Abbreviations
- **Makefile**: A file defining automation tasks executed with `make`.
- **Docker**: A containerization platform for running applications in isolated environments.
- **Remote Execution**: Running commands on a remote machine via SSH.
- **Devind**: A wrapper script to manage execution environments.

### 1.4 References
- [GNU Make Documentation](https://www.gnu.org/software/make/manual/make.html)
- [Docker Documentation](https://docs.docker.com/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)


## 2. Overall Description

### 2.1 Product Perspective
DevinD extends traditional Makefile-based workflows by providing execution flexibility. It can be integrated into any Makefile project without requiring structural changes.

### 2.2 Product Functions
- **Unified Execution**: Users can run `make target` locally or use `devind` to execute in different environments.
- **Automated Environment Selection**: Based on configurations, `devind` determines whether to execute locally, in Docker, or remotely.
- **Configurable Execution Modes**:
  - Local execution (directly using Makefiles)
  - Dockerized execution (local/remote)
  - Remote execution via SSH
  - Remote execution within Docker

### 2.3 User Characteristics
- **Developers**: Require a consistent execution environment across machines.
- **CI/CD Pipelines**: Need automated build, test, and deployment processes.
- **System Administrators**: Manage execution on different machines remotely.

### 2.4 Constraints
- **GNU Make is required** in all execution environments where Makefiles are used, but some execution modes may not require it depending on the target configuration.
- **Docker must be installed** for containerized execution.
- **SSH access is needed** for remote execution.


## 3. Specific Requirements

### 3.1 Functional Requirements

#### **1. Local Execution (Default)**
- Running `make target` executes the task locally **if GNU Make is installed**.
- The **execution target must have GNU Make installed** to run any command.
- Example:
  ```bash
  make target
  ```
- **Local execution is always done directly using Makefiles**.
- If `devind` is used with no configurations, it defaults to **local execution**.

#### **2. Execution via `devind` Wrapper Script**
- `devind` serves as an execution manager:
  - **Dockerized Execution**: Runs `make` inside a Docker container.
  - **Remote Execution (via SSH)**: Runs `make` on a remote machine.
  - **Remote Docker Execution**: Runs `make` inside a remote Docker container.
  - **Remote Execution via SSH (Direct Command Execution)**: Executes commands directly on a remote machine as specified in the Makefile target, without using Docker.
- `devind` does **not replace `make`**, but **calls `make`** with the correct configurations.

#### **3. Target Execution Configuration**
- Targets can be executed:
  - **Locally** (default: `make target`, directly using Makefiles)
  - **In a local Docker container**
  - **On a remote machine via SSH**
  - **Inside a remote Docker container**
- Users specify execution mode via **Makefile configurations or environment variables**.

### 3.2 Non-Functional Requirements
- **Performance**: Minimal overhead when switching execution environments.
- **Portability**: Works on Linux/macOS; Windows via WSL2.
- **Security**: SSH authentication required for remote execution.
- **Scalability**: Supports multiple execution targets across different environments.


## 4. System Requirements

### 4.1 Hardware Requirements
- **Local Execution**: Any modern development machine.
- **Remote Execution**: SSH-enabled server with sufficient resources.

### 4.2 Software Requirements
- **GNU Make** (required for all execution modes)
- **Docker** (required for containerized execution)
- **OpenSSH** (required for remote execution)


## 5. Appendices
- Configuration examples and usage guidelines will be provided in project documentation.

---

This document defines the functional and non-functional requirements for DevinD, ensuring a flexible and robust execution framework for Makefile-based projects.

---