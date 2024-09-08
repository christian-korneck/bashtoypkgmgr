#!/bin/bash

# Declare associative array for dependencies
declare -A dependencies

# Function to add dependencies to the associative array
add_dependencies() {
    local file="$1"
    local dep_file

    # Initialize the array entry for the file if not already initialized
    [[ -z "${dependencies[$file]}" ]] && dependencies["$file"]=""

    # Extract dependencies from the file
    while IFS= read -r line; do
        # Extract the dependency file name
        dep_file=$(echo "$line" | sed -E 's/# depends-on\s+//')
        if [[ -n "$dep_file" ]]; then
            # Add the .pkg suffix to the dependency
            dep_file="$dep_file.pkg"
            # Append dependency to the associative array
            dependencies["$file"]+="$dep_file "
        fi
    done < <(grep '^# depends-on' "$file")
}

# Function to process dependencies for each file
process_dependencies() {
    local file="$1"

    # Add dependencies for the current file
    add_dependencies "$file"
    
    # Process dependencies of each file
    for dep in ${dependencies["$file"]}; do
        if [[ -n "$dep" ]]; then
            # Add dependencies for each dependency
            process_dependencies "$dep"
        fi
    done
}

# Function to print all dependencies
print_dependencies() {
    local file
    local dep

    for file in "${!dependencies[@]}"; do
        if [[ -n "${dependencies[$file]}" ]]; then
            # Print file and its dependencies
            for dep in ${dependencies[$file]}; do
                echo "${file%.pkg} ${dep%.pkg}"
            done
        else
            # Print file with 'none' if no dependencies
            echo "${file%.pkg} none"
        fi
    done
}

# Check if a file argument is provided
if [[ $# -eq 1 ]]; then
    initial_file="$1"

    # Ensure the initial file has a .pkg suffix
    initial_file="$initial_file.pkg"

    # Initialize processing
    process_dependencies "$initial_file"

    # Print dependencies
    print_dependencies
else
    echo "Usage: $0 <file>"
fi

