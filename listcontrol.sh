#!/bin/bash

directory_path="/path/to/your/directory"  # Change this to the path of your directory
output_file="file_list.txt"

# Check if the directory exists
if [ -d "$directory_path" ]; then
  # Create the header for the text file
  echo "Version $(date '+%Y-%m-%d %H:%M:%S') Version 1.0" > "$output_file"

  # List the files in the directory and append to the text file
  find "$directory_path" -type f -exec basename {} \; >> "$output_file"

  echo "File list created successfully."
else
  echo "Error: Directory not found."
fi
