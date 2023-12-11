#!/bin/bash

# Function to create a list of filenames in a directory
create_file_list() {
  directory="$1"
  listfile="$directory/listfile.txt"

  # Check if the listfile already exists and delete it
  [ -e "$listfile" ] && rm "$listfile"

  # Add the version information to the listfile
  echo "Version $(date '+%Y-%m-%d %H:%M:%S') Version 1.0" >> "$listfile"

  # Iterate through files in the directory and exclude certain patterns
  find "$directory" -type f ! -path "*/.git/*" ! -path "*/additional_packages/*" -exec basename {} >> "$listfile" \;

  echo "List of files created in $listfile"
}

# Specify the directory to create the file list
directory="$(dirname "$0")"

# Create the list of filenames
create_file_list "$directory"
