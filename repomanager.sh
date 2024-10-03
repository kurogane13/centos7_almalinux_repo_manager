#!/bin/bash

# Title of the console
echo "=============================="
echo "    Repo Management Console    "
echo "=============================="

# Function to list all repo files
list_repos() {
    echo
    echo "Listing all repo files in /etc/yum.repos.d/:"
    echo
    ls /etc/yum.repos.d/*.repo || echo "No repo files found."
    echo

    echo "Listing all backup repo files in /etc/yum.repos.d/:"
    echo
    if ls /etc/yum.repos.d/*.repo.bak 1> /dev/null 2>&1; then
        ls /etc/yum.repos.d/*.repo.bak
    else
        echo "No backup repo files found."
    fi
    echo

    read -p "Press Enter to return to the main menu..."
}

# Function to list enabled repos
list_enabled_repos() {
    echo
    echo "Listing enabled repos:"
    echo
    yum repolist enabled
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to list disabled repos
list_disabled_repos() {
    echo
    echo "Listing disabled repos:"
    echo
    yum repolist disabled
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to enable a repo
enable_repo() {
    echo
    read -p "Enter the name of the repo to enable (e.g., repo-name): " repo_name
    if yum repolist all | grep -q "$repo_name"; then
        sudo yum-config-manager --set-enabled "$repo_name" || sudo sed -i "/\[$repo_name\]/,/^enabled=/{s/enabled=0/enabled=1/}" /etc/yum.repos.d/*.repo
        echo
        echo "Enabled $repo_name."
    else
        echo
        echo "Repo does not exist. Please try again."
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to disable a repo
disable_repo() {
    echo
    read -p "Enter the name of the repo to disable (e.g., repo-name): " repo_name
    if yum repolist all | grep -q "$repo_name"; then
        sudo yum-config-manager --set-disabled "$repo_name" || sudo sed -i "/\[$repo_name\]/,/^enabled=/{s/enabled=1/enabled=0/}" /etc/yum.repos.d/*.repo
        echo
        echo "Disabled $repo_name."
    else
        echo
        echo "Repo does not exist. Please try again."
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to read the content of a repo file
read_repo() {
    echo
    read -p "Enter the path to the repo file to read: " repo_file
    if [[ ! -f "$repo_file" ]]; then
        echo
        echo "File does not exist. Please try again."
        echo
        read -p "Press Enter to return to the main menu..."
        return
    fi

    echo
    echo "Content of $repo_file:"
    echo
    cat "$repo_file"
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to search for regex patterns in a repo file
search_regex() {
    echo
    read -p "Enter the path to the repo file to search: " repo_file
    if [[ ! -f "$repo_file" ]]; then
        echo
        echo "File does not exist. Please try again."
        echo
        read -p "Press Enter to return to the main menu..."
        return
    fi

    echo
    read -p "Enter the regex patterns to search for (separate multiple patterns with spaces): " -a regex_patterns

    echo
    for pattern in "${regex_patterns[@]}"; do
        echo "Searching for '$pattern' in $repo_file:"
        
        # Read the file line by line and print matches
        while IFS= read -r line; do
            if [[ $line =~ $pattern ]]; then
                echo "$line"
            fi
        done < "$repo_file"
        
        echo
        echo "Finished searching for '$pattern'."
        echo
    done
    read -p "Press Enter to return to the main menu..."
}

# Function to modify the baseurl
modify_repo() {
    echo
    read -p "Enter the path to the repo file to modify: " repo_file
    if [[ ! -f "$repo_file" ]]; then
        echo
        echo "File does not exist. Please try again."
        echo
        read -p "Press Enter to return to the main menu..."
        return
    fi

    read -p "Enter the new baseurl value: " new_baseurl

    # Create a backup of the original file
    cp "$repo_file" "${repo_file}.bak"

    # Replace all lines starting with baseurl=
    sudo sed -i "s|^baseurl=.*|baseurl=${new_baseurl}|g" "$repo_file"
    
    echo
    echo "Replaced all baseurl lines in $repo_file with: $new_baseurl"
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to rollback the last change
rollback_repo() {
    echo
    read -p "Enter the path to the repo file to rollback from .bak to repo: " repo_file
    if [[ -f "${repo_file}.bak" ]]; then
        # Restore the backup
        cp "${repo_file}.bak" "$repo_file"
        echo
        echo "Rolled back changes for $repo_file."
        # Remove the backup after restoration
        rm "${repo_file}.bak"
    else
        echo
        echo "No backup found for $repo_file. Cannot rollback."
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to remove a repo
remove_repo() {
    echo
    read -p "Enter the path to the repo file to remove: " repo_file
    if [[ -f "$repo_file" ]]; then
        echo
        read -p "Are you sure you want to remove $repo_file? (y/n): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            sudo rm -rf "$repo_file"
            echo
            echo "Removed $repo_file."
        else
            echo
            echo "Operation canceled."
        fi
    else
        echo
        echo "File does not exist. Please try again."
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to create a backup of a repo
backup_repo() {
    echo
    read -p "Enter the path to the repo file to backup: " repo_file
    if [[ -f "$repo_file" ]]; then
        cp "$repo_file" "${repo_file}.bak"
        echo
        echo "Backup created for $repo_file as ${repo_file}.bak."
    else
        echo
        echo "File does not exist. Please try again."
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to list AlmaLinux mirrors with URLs and log to a file
list_almalinux_mirrors() {
    echo
    echo "Listing AlmaLinux Mirrors with URLs:"
    echo
    echo "Fetching from: https://mirrors.almalinux.org/"
    echo

    # Combined command to fetch and parse AlmaLinux mirrors with separators and log to file
    curl -s https://mirrors.almalinux.org/ | grep -oP '(<td.*?>.*?</td>)|(<a href="https?://[^"]+".*?>.*?</a>)' | sed -e 's/<td>//g; s/<\/td>//g; s/<a href="\([^"]*\)">\(.*\)<\/a>/\2: \1/g' | sort -u > almalinux_mirrors.log || echo "Unable to fetch AlmaLinux mirrors."

    echo "AlmaLinux mirrors logged to almalinux_mirrors.log"
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to list CentOS 7 mirrors with URLs and log to a file
list_centos7_mirrors() {
    echo
    echo "Listing CentOS 7 Mirrors with URLs:"
    echo
    echo "Fetching from: https://mirrormanager.fedoraproject.org/mirrors/CentOS"
    echo

    # Combined command to fetch and parse CentOS mirrors with separators and log to file
    curl -s https://mirrormanager.fedoraproject.org/mirrors/CentOS | grep -oP '(<td.*?>.*?</td>)|(<a href="https?://[^"]+".*?>.*?</a>)' | sed -e 's/<td>//g; s/<\/td>//g; s/<a href="\([^"]*\)">\(.*\)<\/a>/\2: \1/g' | sort -u > centos7_mirrors.log || echo "Unable to fetch CentOS 7 mirrors."

    echo "CentOS 7 mirrors logged to centos7_mirrors.log"
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to search for a regex in the AlmaLinux mirrors log file
search_in_almalinux_log() {
    if [[ -f almalinux_mirrors.log ]]; then
        read -p "Enter the regex pattern to search in almalinux_mirrors.log: " pattern
        echo "Searching for '$pattern' in almalinux_mirrors.log..."
        grep -E "$pattern" almalinux_mirrors.log || echo "No matches found for '$pattern'."
    else
        echo
        echo "almalinux_mirrors.log does not exist. First run option 12 to create the almalinux_mirrors.log file"
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to search for a regex in the CentOS 7 mirrors log file
search_in_centos7_log() {
    if [[ -f centos7_mirrors.log ]]; then
        read -p "Enter the regex pattern to search in centos7.log: " pattern
        echo "Searching for '$pattern' in centos7.log..."
        grep -E "$pattern" centos7.log || echo "No matches found for '$pattern'."
    else
        echo
        echo "centos7_mirrors.log does not exist. First run option 13 to create the centos7_mirrors.log file"
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to read the contents of the CentOS 7 mirrors log file
read_centos7_log() {
    echo
    echo "Reading CentOS 7 Mirrors Log:"
    echo

    # Check if the log file exists
    if [ -f centos7_mirrors.log ]; then
        cat centos7_mirrors.log
    else
        echo
        echo "centos7_mirrors.log does not exist. Please generate it first."
    fi

    echo
    read -p "Press Enter to return to the main menu..."
}

# Function to read the contents of the AlmaLinux mirrors log file
read_almalinux_log() {
    echo
    echo "Reading AlmaLinux Mirrors Log:"
    echo

    # Check if the log file exists
    if [ -f almalinux_mirrors.log ]; then
        cat almalinux_mirrors.log
    else
        echo
        echo "almalinux_mirrors.log does not exist. Please generate it first."
    fi

    echo
    read -p "Press Enter to return to the main menu..."
}

# Interactive menu
while true; do
    echo ""
    echo "Select an option:"
    echo
    echo "1) List all repos"
    echo "2) List enabled repos"
    echo "3) List disabled repos"
    echo "4) Enable a repo"
    echo "5) Disable a repo"
    echo "6) Read the content of a repo"
    echo "7) Search for regex patterns in a repo"
    echo "8) Modify repo baseurl"
    echo "9) Rollback repo from .bak"
    echo "10) Remove a repo"
    echo "11) Backup a repo"
    echo "12) Log almalinux mirrors to logfile | will fetch almalinux mirrors and dump content to log file"
    echo "13) Log centos7 mirrors to logfile | will fetch centos 7 mirrors and dump content to log file"
    echo "14) Read Centos7 log file"
    echo "15) Read Almalinux log file"
    echo "16) Look for a regular expression in almalinux mirrors log file"
    echo "17) Look for a regular expression in centos7 mirrors log file"
    echo "18) Exit"
    echo
    read -p "Enter your choice: " choice

    case $choice in
        1) list_repos ;;
        2) list_enabled_repos ;;
        3) list_disabled_repos ;;
        4) enable_repo ;;
        5) disable_repo ;;
        6) read_repo ;;
        7) search_regex ;;
        8) modify_repo ;;
        9) rollback_repo ;;
        10) remove_repo ;;
        11) backup_repo ;;
        12) list_almalinux_mirrors ;;
        13) list_centos7_mirrors ;;
        14) read_centos7_log ;;
        15) read_almalinux_log ;;
        16) search_in_almalinux_log ;;
        17) search_in_centos7_log ;;
        18) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid choice. Please provide a valid choice number from the menu."; echo; read -p "Press Enter to return to the main menu..." ;;
    esac
done
