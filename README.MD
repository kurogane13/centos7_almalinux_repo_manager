# Repo Management Console

## AUTHOR: GUSTAVO WYDLER AZUAGA
## VERSION: 1
## RELEASE DATE: 10-03-2024

## Overview

The **Repo Management Console** is a Bash script designed to facilitate the management of YUM repository files on AlmaLinux and CentOS systems. This console allows users to list, enable, disable, modify, backup, and remove repository files, as well as log and search for AlmaLinux and CentOS mirrors.

## Features

- List all repository files and backup files
- Enable or disable specific repositories
- Modify the base URL of repositories
- Backup and rollback repository configurations
- Fetch and log AlmaLinux and CentOS mirrors
- Search for specific patterns in repository files and logs

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
