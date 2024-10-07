# Repo Management Console

## AUTHOR: GUSTAVO WYDLER AZUAGA
## VERSION: 1
## RELEASE DATE: 10-03-2024

## Overview

The **Repo Management Console** is a Bash script designed to facilitate the management of YUM repository files on AlmaLinux and CentOS systems. This console allows users to list, enable, disable, modify, backup, and remove repository files, as well as log and search for AlmaLinux and CentOS mirrors.

## Main Repo Features

- List all repository files and backup files
- Enable or disable specific repositories
- Modify the base URL of repositories
- Backup and rollback repository configurations
- Fetch and log AlmaLinux and CentOS mirrors
- Search for specific patterns in repository files and logs
- Search for all child urls in a mirror, or any given url
- Search for files in child urls
- Generate log files of mirrors, parent urls, child urls
- Search for regular expressions in saved log files
- Validate a url or mirror with curl

## Packages sub menu features

1. **List all installed packages**
   - Displays a list of all packages currently installed on the system.

2. **List installed packages from a repository**
   - Allows the user to specify a repository name and lists all installed packages from that repository.

3. **List all available packages from a specific repo**
   - Lists all packages available for installation from a specified repository.

4. **List all updates from a specific repo**
   - Shows all available updates for packages from a specified repository.

5. **Get Package info**
   - Provides detailed information about a specified package, including version, architecture, and repository.

6. **Get package info from a specific repo**
   - Retrieves detailed information about a package from a specified repository.

7. **Install a package from a specific repo**
   - Installs a specified package from a specified repository.

8. **Update a package from a specific repo**
   - Updates a specified package from a specified repository.

9. **Remove a package from a specific repo**
   - Removes a specified package from the system.

10. **Search for a package**
    - Searches for a package by name and displays the results.

11. **Install a package**
    - Installs a specified package from the enabled repositories.

12. **Remove a package**
    - Removes a specified package from the system.

13. **Update a package**
    - Updates a specified package from the enabled repositories.

14. **List available package groups**
    - Displays all available package groups for installation.

15. **Install a package group**
    - Installs all packages included in a specified package group.

16. **Remove a package group**
    - Removes all packages included in a specified package group.

## Prerequisites

- A compatible Linux distribution (AlmaLinux or CentOS)
- Bash shell
- `curl` and `yum` utilities

## Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/kurogane13/centos7_almalinux_repo_manager.git
   
2. **Run the program**

   ```bash
   cd centos7_almalinux_repo_manager
   sudo chmod +rx repomanager.sh
   sudo bash repomanager.sh
