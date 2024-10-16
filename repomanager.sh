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

# Function to modify the baseurl
modify_all_repos() {
    echo
    read -p "Enter the new baseurl value to modify it in all repos: " new_baseurl
    echo
    read -p "Are you sure you want to replace the baseurl in all repos with: $new_baseurl? (y/n): " confirm

    if [[ $confirm =~ ^[Yy]$ ]]; then
        # Create backups of all the repos
        for i in /etc/yum.repos.d/*.repo; do
            cp "$i" "${i}.bak"
        done
        echo
        echo "Created backup copies of all repos in /etc/yum.repos.d/ for security purposes"
        # Replace all lines starting with baseurl=
        sudo sed -i "s|^baseurl=.*|baseurl=${new_baseurl}|g" /etc/yum.repos.d/*.repo

        echo
        echo "Replaced all baseurl lines in repository files with: $new_baseurl"
    elif [[ $confirm =~ ^[Nn]$ ]]; then
        echo
        echo "Baseurl modification canceled."
    else
        echo
        echo "Invalid option provided. Please enter 'y' or 'n'."
        modify_all_repos
    fi
    
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

# Function to create a backups of repo files
backup_all_repos() {
    echo
    read -p "Create a backup of all repos in /etc/yum.repos.d/ (y/n): " backup_repo_files
    if [[ $backup_repo_files =~ ^[Yy]$ ]]; then
        for i in /etc/yum.repos.d/*.repo; do
            cp "$i" "${i}.bak"
        done
        echo
        echo "Created backup copies of repo files in /etc/yum.repos.d/."

    elif [[ $backup_repo_files =~ ^[Nn]$ ]]; then
        echo
        echo "Repos backup operation canceled."

    else
        echo
        read -p "Invalid option provided. Press enter to go back to the prompt: " enter
        echo
        backup_all_repos
    fi
    echo
    read -p "Press Enter to return to the main menu..."
}

#Restore backup repos to .repo files
restore_repo_backups() {
    echo
    read -p "Restore all .bak files to .repo files in /etc/yum.repos.d/ (y/n): " restore_repo_files
    if [[ $restore_repo_files =~ ^[Yy]$ ]]; then
        for i in /etc/yum.repos.d/*.bak; do
            mv "$i" "${i%.bak}"
        done
        echo
        echo "Restored all .bak files to .repo files in /etc/yum.repos.d/."
        
    elif [[ $restore_repo_files =~ ^[Nn]$ ]]; then
        echo
        echo "Repos restore operation canceled."

    else
        echo
        read -p "Invalid option provided. Press enter to go back to the prompt: " enter
        echo
        restore_repo_backups
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
        grep -E "$pattern" centos7_mirrors.log || echo "No matches found for '$pattern'."
    else
        echo
        echo "centos7_mirrors.log does not exist. First run option 16 to create the centos7_mirrors.log file"
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

curl_for_alma() {
	os_version=$(grep "^VERSION_ID" /etc/os-release | cut -d'=' -f2 | tr -d '"')
	echo
	echo "This option will get a mirror url, and test if the base url exists. "
	echo
	echo "It will build the <almalinux_version_id>/BaseOS/x86_64/os/, to check if a valid mirror exists."
	echo
	read -p "Copy and paste a valid almalinux mirror url from option 19, and press enter: " curl_alma_url
	
    cleaned_curl_for_alma="${curl_alma_url%/}"  # Remove trailing slash
	cleaned_os_version="${os_version#/}"        # Remove leading slash

	# Construct the URL with single slashes
	alma_curl_url="$cleaned_curl_for_alma/$cleaned_os_version/BaseOS/x86_64/os/"

	# Print the resulting URL
    echo
	echo "$alma_curl_url"
    echo
    curl -s -v -I $alma_curl_url
    echo "--------------------------------------------------------------------"
	read -p "Press enter to return to main menu: " enter 
}

curl_for_centos7() {
	# Hardcode CentOS version for CentOS 7 as it is fixed
	os_version="7"
	echo
	echo "This option will get a mirror URL, and test if the CentOS 7 base URL exists."
	echo
	echo "It will build the <centos_version>/BaseOS/x86_64/os/, to check if a valid mirror exists."
	echo
	read -p "Copy and paste a valid CentOS 7 mirror URL from option 20, and press enter: " curl_centos_url

	# Clean up the URL and version to avoid double slashes
	cleaned_curl_for_centos="${curl_centos_url%/}"  # Remove trailing slash
	cleaned_os_version="${os_version#/}"            # Remove leading slash (not necessary but keeping consistent)

	# Construct the URL with single slashes
	centos_curl_url="$cleaned_curl_for_centos/$cleaned_os_version/os/x86_64/"

	# Print the resulting URL
	echo
	echo "$centos_curl_url"
	echo

	# Perform the curl command to test the URL
	curl -s -v -I "$centos_curl_url"
	echo
	echo "--------------------------------------------------------------------"
	read -p "Press enter to return to main menu: " enter
}


LOG_FILE="url_subdirectories_and_files.log"
# Clear the log file at the start
> "$LOG_FILE"

# Function to list all subdirectories and files recursively and log the results
list_all_paths() {
    read -p "Enter the base URL (e.g., https://mirror.alma.iad1.serverforge.org/8.10/): " base_url

    echo
    echo "Checking for subdirectories and files inside $base_url..."
    echo

    # Remove trailing slash from the URL if present
    base_url="${base_url%/}"

    # Initialize an array to store directories to search
    directories_to_check=("$base_url")
    
    # Generate the log file name dynamically based on the base_url
    # Replace "/" and ":" in base_url with "_"
    sanitized_base_url=$(echo "$base_url" | sed 's/[\/:]/_/g')
    LOG_FILE="${sanitized_base_url}__repomanager_program_paths.log"

    # Function to get subdirectories and files of a given URL
    get_links() {
        local url=$1
        # Use curl to get the directory listing
        response=$(curl -sL -A "Mozilla/5.0" "$url")

        # Extract all href links from the page (both files and directories)
        echo "$response" | grep -oP '(?<=href=")[^"]+(?=")' | sort -u
    }

    # Log the base URL
    echo "Base URL: $base_url" | tee -a "$LOG_FILE"

    # Loop through each directory in the array
    while [[ ${#directories_to_check[@]} -gt 0 ]]; do
        # Pop the first directory from the array
        current_dir="${directories_to_check[0]}"
        directories_to_check=("${directories_to_check[@]:1}")

        echo
        echo "Checking paths in: $current_dir"
        
        # Get the links (both files and subdirectories) for the current directory
        links=$(get_links "$current_dir")

        # If there are links, process them
        if [[ -n "$links" ]]; then
            echo
            echo "Found paths in $current_dir:"
            echo
            for link in $links; do
                # Construct the full URL
                # Handle relative links by appending to the base URL
                if [[ "$link" == /* ]]; then
                    full_url="$base_url$link"
                else
                    full_url="$current_dir/$link"
                fi
                
                # Check if the link is a directory (ends with "/") or a file
                if [[ "$link" == */ ]]; then
                    echo "Subdirectory: $full_url" | tee -a "$LOG_FILE"
                    # Add the subdirectory to the array to check its contents later
                    directories_to_check+=("$full_url")
                else
                    echo
                    echo "File: $full_url" | tee -a "$LOG_FILE"
                fi
            done
        else
            echo "No files or subdirectories found in: $current_dir"
        fi

        echo
    done

    echo "All validated URLs have been logged to $LOG_FILE"
    echo "--------------------------------------------------------------------"
	read -p "Press enter to return to main menu: " enter
}

# Function to search for a regular expression in a log file
search_in_logfile() {
    # Prompt user for the logfile path and the regular expression to search for
    
    read -p "Enter the path to the log file: " logfile
    
    # Check if the log file exists
    if [[ ! -f "$logfile" ]]; then
        echo
        echo "Error: Log file '$logfile' not found."
        echo
		echo "--------------------------------------------------------------------"
		read -p "Press enter to return to main menu: " enter
		main_menu
    fi
    
    echo
    read -p "Enter the regular expression to search for: " regex

    echo
    echo "Searching for pattern '$regex' in $logfile..."
    echo

    # Use grep to search for the regular expression in the log file
    matches=$(grep -E "$regex" "$logfile")

    # Check if there are any matches
    if [[ -n "$matches" ]]; then
        echo
        echo "Matches found:"
        echo
        echo "$matches"
        echo "--------------------------------------------------------------------"

    else
        echo
        echo "No matches found for pattern '$regex' in $logfile."
        
    fi

    echo
    echo "--------------------------------------------------------------------"
	read -p "Press enter to return to main menu: " enter
	main_menu
}

repomanager_generated_logfiles() {
	echo
	read -p "Press enter to view all .log files generated by this program: " enter
	echo
	ls -lha | grep 'repomanager_program_paths.log'
	echo
    echo "--------------------------------------------------------------------"
	read -p "Press enter to return to main menu: " enter
	
}	

# Packages Menu Function
packages_menu() {
    while true; do
		echo ""
		echo "*** Packages Menu ***"
		echo
		echo "===== PACKAGE LISTING OPTIONS ====="
		echo
		echo "1) List all installed packages"
		echo "2) List installed packages from a repository"
		echo "3) List all available packages from a specific repo"
		echo "4) List all updates from a specific repo"
		echo "5) Get package info"
		echo "6) Get package info from a specific repo"
		echo
		echo "===== PACKAGE INSTALLATION & REMOVAL ====="
		echo
		echo "7) Install a package from a specific repo"
		echo "8) Update a package from a specific repo"
		echo "9) Remove a package from a specific repo"
		echo "10) Search for a package"
		echo "11) Install a package"
		echo "12) Remove a package"
		echo "13) Update a package"
		echo
		echo "===== PACKAGE GROUP OPERATIONS ====="
		echo
		echo "14) List available package groups"
		echo "15) Install a package group"
		echo "16) Remove a package group"
		echo "----------------------------------------------------------"
		echo
		echo "17) Go back to the Main Menu"
		echo
		read -p "Enter your choice: " pkg_choice

        case $pkg_choice in
            1) list_installed_packages ;;
            2) list_installed_packages_in_repo ;;
            3) list_packages_in_specific_repo ;;
            4) list_updates_from_specific_repo ;;
            5) get_package_info ;;
            6) get_package_info_from_repo ;;
            7) install_package_from_repo ;;
            8) update_package_from_repo ;;
            9) remove_package_from_repo ;;
            10) search_package ;;
            11) install_package ;;
            12) remove_package ;;
            13) update_package ;;
            14) list_package_groups ;;
            15) install_package_group ;;
            16) remove_package_group ;;
            17) 
                return # Go back to the main menu
                ;;
            *) 
                echo
                echo "Invalid choice. Please provide a valid choice number from the Packages Menu."
                echo
                read -p "Press Enter to return to the Packages Menu..." 
                ;;
        esac
    done
}

# Function Definitions

list_installed_packages() {
    echo ""
    echo "Listing all installed packages..."
    if yum list installed &>/dev/null; then
        yum list installed
        echo -e "\nTotal installed packages: $(yum list installed | wc -l)"
        echo -e "\nInstalled packages listed successfully."
    else
        echo -e "\nFailed to list installed packages or no packages found."
    fi
    echo
}

list_installed_packages_in_repo() {
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Listing installed packages in the $repo_name repository..."
    if yum list installed | grep @$repo_name &>/dev/null; then
        yum list installed | grep @$repo_name
        echo -e "\nTotal installed packages in $repo_name: $(yum list installed | grep @$repo_name | wc -l)"
        echo -e "\nInstalled packages in $repo_name listed successfully."
    else
        echo -e "\nFailed to list installed packages in $repo_name or no packages found."
    fi
    echo
}

list_packages_in_specific_repo() {
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Listing all available packages in the $repo_name repository..."
    if yum list available | grep @$repo_name &>/dev/null; then
        yum list available | grep @$repo_name
        echo -e "\nTotal available packages in $repo_name: $(yum list available | grep @$repo_name | wc -l)"
        echo -e "\nPackages in $repo_name listed successfully."
    else
        echo -e "\nFailed to list packages in $repo_name or no packages found."
    fi
    echo
}

list_updates_from_specific_repo() {
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Listing all updates from the $repo_name repository..."
    if yum list updates | grep @$repo_name &>/dev/null; then
        yum list updates | grep @$repo_name
        echo -e "\nTotal updates from $repo_name: $(yum list updates | grep @$repo_name | wc -l)"
        echo -e "\nUpdates from $repo_name listed successfully."
    else
        echo -e "\nFailed to list updates from $repo_name or no updates found."
    fi
    echo
}

get_package_info_from_repo() {
	echo
    read -p "Enter the package name you are searching for: " package_name
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Getting info for package $package_name from the $repo_name repository..."
    if yum --disablerepo='*' --enablerepo="$repo_name" info "$package_name" &>/dev/null; then
        echo
        yum --disablerepo='*' --enablerepo="$repo_name" info "$package_name"
        echo -e "\nPackage info for $package_name retrieved successfully."
    else
        echo -e "\nFailed to retrieve package info for $package_name or package does not exist."
    fi
    echo
}

get_package_info() {
	echo
    read -p "Enter the package name you are searching for: " package_name
    echo
    echo ""
    echo "Getting info for package $package..."
    if yum info "$package_name" &>/dev/null; then
        echo
        yum info "$package_name"
        echo
        echo -e "\nPackage info for $package_name retrieved successfully."
    else
        echo -e "\nFailed to retrieve package info for $package_name or package does not exist."
    fi
    echo
}


install_package_from_repo() {
	echo
    read -p "Enter the package name: " package_name
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Installing package $package_name from the $repo_name repository..."
    if yum --disablerepo='*' --enablerepo="$repo_name" install -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name installed successfully."
    else
        echo -e "\nFailed to install package $package_name or package does not exist."
    fi
    echo
}

update_package_from_repo() {
    read -p "Enter the package name: " package_name
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Updating package $package_name from the $repo_name repository..."
    if yum --disablerepo='*' --enablerepo="$repo_name" update -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name updated successfully."
    else
        echo -e "\nFailed to update package $package_name or package does not exist."
    fi
    echo
}

remove_package_from_repo() {
	echo
    read -p "Enter the package name: " package_name
    echo
    read -p "Enter the repository name: " repo_name
    echo ""
    echo "Removing package $package_name from the $repo_name repository..."
    if yum --disablerepo='*' --enablerepo="$repo_name" remove -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name removed successfully."
    else
        echo -e "\nFailed to remove package $package_name or package does not exist."
    fi
    echo
}

search_package() {
	echo
    read -p "Enter the package name or keyword to search: " package_name
    echo ""
    echo "Searching for package $package_name..."
    if yum search "$package_name" &>/dev/null; then
        yum search "$package_name"
        echo -e "\nSearch completed successfully."
    else
        echo -e "\nFailed to search for package $package_name."
    fi
    echo
}

install_package() {
	echo
    read -p "Enter the package name: " package_name
    echo ""
    echo "Installing package $package_name..."
    if yum install -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name installed successfully."
    else
        echo -e "\nFailed to install package $package_name or package does not exist."
    fi
    echo
}

remove_package() {
	echo
    read -p "Enter the package name: " package_name
    echo ""
    echo "Removing package $package_name..."
    if yum remove -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name removed successfully."
    else
        echo -e "\nFailed to remove package $package_name or package does not exist."
    fi
    echo
}

update_package() {
	echo
    read -p "Enter the package name: " package_name
    echo ""
    echo "Updating package $package_name..."
    if yum update -y "$package_name" &>/dev/null; then
        echo -e "\nPackage $package_name updated successfully."
    else
        echo -e "\nFailed to update package $package_name or package does not exist."
    fi
    echo
}

list_package_groups() {
    echo ""
    echo "Listing available package groups..."
    if yum group list &>/dev/null; then
        yum group list
        echo -e "\nAvailable package groups listed successfully."
    else
        echo -e "\nFailed to list package groups."
    fi
    echo
}

install_package_group() {
	echo
    read -p "Enter the package group name: " group_name
    echo ""
    echo "Installing package group $group_name..."
    if yum group install -y "$group_name" &>/dev/null; then
        echo -e "\nPackage group $group_name installed successfully."
    else
        echo -e "\nFailed to install package group $group_name or group does not exist."
    fi
    echo
}

remove_package_group() {
	echo
    read -p "Enter the package group name: " group_name
    echo ""
    echo "Removing package group $group_name..."
    if yum group remove -y "$group_name" &>/dev/null; then
        echo -e "\nPackage group $group_name removed successfully."
    else
        echo -e "\nFailed to remove package group $group_name or group does not exist."
    fi
    echo
}

# Interactive menu

while true; do
    echo ""
    echo "*** Repo Operations Main Menu ***"
    echo
    echo "===== REPO LISTING OPTIONS ====="
    echo "1) List all repo files"
    echo "2) List enabled repos"
    echo "3) List disabled repos"
    echo
    echo "===== REPO MANAGEMENT OPTIONS ====="
    echo
    echo "4) Enable a repo"
    echo "5) Disable a repo"
    echo "6) Read the content of a repo"
    echo "7) Search for regex patterns in a repo"
    echo "8) Modify a repo's baseurl"
    echo "9) Rollback repo from .bak"
    echo "10) Remove a repo"
    echo "11) Backup a repo"
    echo
    echo "===== GLOBAL REPO OPERATIONS ====="
    echo
    echo "12) Modify all repos base URL"
    echo "13) Create .bak copies of all repos in /etc/yum.repos.d/"
    echo "14) Restore all .bak repos in /etc/yum.repos.d/ to .repo"
    echo
    echo "===== MIRROR LOGGING OPTIONS ====="
    echo
    echo "15) Log Almalinux mirrors to logfile | Fetch Almalinux mirrors and dump content to log file"
    echo "16) Log CentOS7 mirrors to logfile | Fetch CentOS7 mirrors and dump content to log file"
    echo "17) Read CentOS7 log file"
    echo "18) Read Almalinux log file"
    echo
    echo "===== REGULAR EXPRESSION SEARCH ====="
    echo
    echo "19) Look for a regular expression in Almalinux mirrors log file"
    echo "20) Look for a regular expression in CentOS7 mirrors log file"
    echo
    echo "===== CURL REPO VALIDATION ====="
    echo
    echo "21) Run curl to test if an Almalinux repo is a valid BASE OS repo"
    echo "22) Run curl to test if a CentOS7 repo is a valid BASE OS repo"
    echo
    echo "===== SEARCH FOR MIRRORS, URLS, AND FILES ====="
    echo
    echo "23) Provide a baseurl, searches all child ulrs, and files in it."
    echo "24) Search for a regexp, in log file"
    echo
    echo "===== LOG FILES ====="
    echo
    echo "25) View all .log files generated with this program"
    echo
    echo "===== REPO CLEANUP OPTIONS ====="
    echo
    echo "26) Run 'yum clean all'"
    echo "27) Run 'yum makecache'"
    echo "28) Clean repos metadata"
    echo
    echo "----------------------------------------------------------"
    echo
    echo "29) Access Packages Menu"
    echo
    echo "30) Exit"
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
        12) modify_all_repos ;;
        13) backup_all_repos ;;
        14) restore_repo_backups ;;
        15) list_almalinux_mirrors ;;
        16) list_centos7_mirrors ;;
        17) read_centos7_log ;;
        18) read_almalinux_log ;;
        19) search_in_almalinux_log ;;
        20) search_in_centos7_log ;;
        21) curl_for_alma ;;
        22) curl_for_centos7 ;;
        23) list_all_paths ;;
        24) search_in_logfile ;;
        25) repomanager_generated_logfiles ;;
        26) 
            sudo yum clean all
            echo
            read -p "Press enter to return to main menu: " enter
            ;;
        27) 
            sudo yum makecache
            echo
            read -p "Press enter to return to main menu: " enter
            ;;
        28) 
            sudo yum clean metadata
            echo
            read -p "Press enter to return to main menu: " enter
            ;;
        29) packages_menu
            ;;
				
        30) echo "Exiting the program."
            exit 0 
            ;;
        *)  
            echo
            echo "Invalid choice. Please provide a valid choice number from the menu."; echo; read -p "Press Enter to return to the main menu..." ;;
    esac
done



