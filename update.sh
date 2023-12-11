#!/bin/bash

github_username="SomerCode"
repo_name="DidactConsole"
local_path="$(dirname "$0")"

# Function to check for updates
check_for_updates() {
  # Clone the latest version of the repository
  git clone "https://github.com/$github_username/$repo_name.git" "$local_path/$repo_name.tmp" 2>/dev/null

  # Check if the cloning was successful
  if [ $? -eq 0 ]; then
    # Compare the content of the current version with the latest version
    if ! diff -qr "$local_path" "$local_path/$repo_name.tmp" &>/dev/null; then
      echo "Updating to the latest version..."
      
      # Replace the old version with the new one
      rm -rf "$local_path/$repo_name"
      mv "$local_path/$repo_name.tmp" "$local_path/$repo_name"

      echo "Update completed. Starting the program..."
    else
      echo "No updates available. Starting the program..."
      rm -rf "$local_path/$repo_name.tmp"
    fi
  else
    echo "Failed to check for updates. Starting the program..."
  fi
}

# Function to start the main program
start_program() {
  bash "$local_path/$repo_name/installer.sh"
}

# Check for updates
check_for_updates

# Start the program
start_program
