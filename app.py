from flask import Flask, render_template, send_from_directory, redirect, url_for, safe_join
import webbrowser
import os
import subprocess
import shutil
import mimetypes  # Add this import statement

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/launcher')
def launcher():
    return render_template('launcher.html')

@app.route('/download')
def download():
    repo_url = "https://github.com/SomerCode/DidactConsole.git"
    destination_folder = os.path.join(os.path.dirname(os.getcwd()), 'packages', 'additional_packages')

    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    try:
        subprocess.check_output(['git', 'clone', repo_url, destination_folder], text=True)
        result = "Download from GitHub completed."
    except subprocess.CalledProcessError as e:
        result = f"Error: {e.output}"

    standard_apps, featured_apps = get_apps(destination_folder)

    installed_folder = os.path.join(os.getcwd(), 'installed')

    # Check if the "installed" directory exists, create it if not
    if not os.path.exists(installed_folder):
        os.makedirs(installed_folder)

    # Fix the line causing the TypeError
    installed_apps = os.listdir(installed_folder)

    for app in featured_apps:
        app['installed'] = app['title'] in installed_apps

    return render_template('download.html', result=result, standard_apps=standard_apps, featured_apps=featured_apps)

def get_apps(package_folder):
    standard_apps = []
    featured_apps = []

    additional_packages_folder = os.path.join(package_folder, 'additional_packages')

    for root, dirs, files in os.walk(additional_packages_folder):
        if root == additional_packages_folder:
            for file in files:
                if file.endswith(".placeholder"):
                    app_title = os.path.splitext(file)[0]
                    app_download_link = f"/download/{app_title}"

                    app_info = {'title': app_title, 'download_link': app_download_link}

                    standard_apps.append(app_info)
        else:
            app_title = os.path.basename(root)
            app_download_link = f"/download/{app_title}"

            # Collect information about icons here if needed

            app_info = {'title': app_title, 'download_link': app_download_link}

            featured_apps.append(app_info)

    return standard_apps, featured_apps
@app.route('/download/<app_title>')
def download_app(app_title):
    app_folder = safe_join(os.path.dirname(os.getcwd()), 'packages', 'additional_packages', app_title)
    installed_folder = os.path.join(os.getcwd(), 'installed')

    # Check if the "installed" directory exists, create it if not
    if not os.path.exists(installed_folder):
        os.makedirs(installed_folder)

    # Move the app data to the 'installed' directory
    shutil.move(app_folder, os.path.join(installed_folder, app_title))

    # Construct the correct file path
    file_path = os.path.join(installed_folder, app_title)

    # Determine the MIME type based on the file extension
    mime_type, _ = mimetypes.guess_type(file_path)
    if mime_type is None:
        mime_type = 'application/octet-stream'

    return send_from_directory(installed_folder, app_title, as_attachment=True, mimetype=mime_type)

@app.route('/upload')
def upload():
    return render_template('upload.html')

@app.route('/account')
def account():
    return render_template('account.html')

def open_browser():
    webbrowser.open('http://127.0.0.1:5000/')

if __name__ == "__main__":
    # Run the app
    open_browser()
    app.run(debug=True, port=5000, threaded=True, use_reloader=False)
