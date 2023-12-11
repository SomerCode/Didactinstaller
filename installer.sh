get_vscode() {
  echo "Downloading Visual Studio Code..."
  echo "Download Path: $dpath"  # Debug
  curl "https://az764295.vo.msecnd.net/stable/1a5daa3a0231a0fbba4f14db7ec463cf99d7768e/code_1.84.2-1699528352_amd64.deb" \
    -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:105.0) Gecko/20100101 Firefox/105.0' \
    -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
    -H 'Accept-Language: de,en-US;q=0.7,en;q=0.3' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'Referer: https://code.visualstudio.com/' \
    -H 'Connection: keep-alive' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-Site: cross-site' \
    --output "$dpath/vscode.deb"

  echo "Extracting Visual Studio Code..."
  dpkg -x "$dpath/vscode.deb" "$HOME"

  echo "Visual Studio Code installation completed."
  ls -l "$HOME"  # Debug
}

get_pip() {
  echo "Downloading pip..."
  curl "https://bootstrap.pypa.io/get-pip.py" --output "$dpath/get-pip.py"
  cd "$dpath"
  echo "Running python on pip"
  python3 get-pip.py
  python3 -m pip install --upgrade pip
  echo "pip installed"
  PATH="$PATH:/home/users/$(logname)/.local/bin"
}

get_additional() {

  # Replace <YOUR_GITHUB_REPO_URL> with the actual repository URL
  repo_url="https://github.com/SomerCode/DidactConsole.git"

  echo "Cloning files from GitHub repository..."
  git clone "$repo_url" "$(dirname "$0")/files"

  # Check if the repository was cloned successfully
  if [ -d "$(dirname "$0")/files" ]; then
    echo "Download from GitHub completed."
  else
    echo "Error: Cloning repository failed."
    return 1
  fi
}

upload_to_github() {
  github_username="SomerCode"
  repo_name="DidactConsole"

  # Prompt the user for the file or directory to upload
  read -rp "Enter the path of the file or directory you want to upload: " source_path

  # Check if the source path exists
  if [ ! -e "$source_path" ]; then
    echo "Error: File or directory not found."
  else
    # Ensure logname is set
    logname=$(logname)

    # Extract the base name from the source path
    base_name=$(basename "$source_path")

    # If it's a directory, tar and gzip it
    if [ -d "$source_path" ]; then
      tar_filename="${base_name}.tar.gz"
      tar -czf "$tar_filename" -C "$(dirname "$source_path")" "$base_name"
      source_path="$tar_filename"
    fi

    # Specify the new filename with "bySomerCode"
    new_filename="${base_name%.*}(by${logname}).${source_path##*.}"

    # Specify the GitHub API endpoint for uploading a file to the repository in the "additional_packages" folder
    api_url="https://api.github.com/repos/$github_username/$repo_name/contents/additional_packages/$new_filename"

    # Base64 encode the file content for inclusion in the API request
    file_content_base64=$(base64 -w 0 "$source_path")

    # GitHub access token (replace with your actual token)
    github_token="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"

    # Create a JSON payload for the API request
    json_payload="{\"message\": \"Upload file\", \"content\": \"$file_content_base64\"}"

    # Make the API request using curl
    curl -X PUT "$api_url" \
      -H "Authorization: token $github_token" \
      -H "Accept: application/vnd.github.v3+json" \
      -d "$json_payload"

    # If a temporary tarball was created for a directory, remove it
    if [ -n "$tar_filename" ]; then
      rm "$tar_filename"
    fi

    echo "File uploaded successfully to 'additional_packages' folder with the name '$new_filename'."
  fi
}


# Main Loop
dpath="/home/users/$(logname)/snap/firefox/common/Downloads/"
read -p "Please type in your download path(standard is: $dpath) -->" dpathoption

if [ "$dpathoption" = "" ]; then
  echo "Path set to default"
  sleep 2
else
  echo "Path set to $dpathoption"
  dpath="$dpathoption"
  sleep 2
fi

if [ -d "$(dirname "$0")/files" ]; then
rmdir "$(dirname "$0")/files"
  get_additional
else
  echo "additional files not found..."
fi

loopset=true
while [ "$loopset" = true ]; do
  clear
  read -rp 'DidactPack Console -> ' option
  if [ "$option" = "exit" ]; then
    loopset=false
  elif [ "$option" = "-list" ]; then
    cat listfile.txt
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  elif [ "$option" = "all" ]; then
    get_vscode
    get_pip
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  elif [ "$option" = "vscode" ]; then
    get_vscode
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  elif [ "$option" = "pip" ]; then
    get_pip
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  elif [ "$option" = "additional" ]; then
    get_additional
    bash listcontrol.sh
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  elif [ "$option" = "upload" ]; then
    upload_to_github
    echo $"\n"
    read -p 'Press enter to continue...' dummy
  fi
done
