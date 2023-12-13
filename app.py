from flask import Flask, render_template, send_from_directory
import webbrowser
import os
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/launcher')
def launcher():
    return render_template('launcher.html')

@app.route('/download')
def download():
    # Replace <YOUR_GITHUB_REPO_URL> with the actual repository URL
    repo_url = "https://github.com/SomerCode/DidactConsole.git"
    destination_folder = os.path.join(os.getcwd(), 'packages')

    # Check if the destination folder exists, create if not
    if not os.path.exists(destination_folder):
        os.makedirs(destination_folder)

    # Clone files from GitHub repository to the 'packages' subdirectory
    try:
        subprocess.check_output(['git', 'clone', repo_url, destination_folder], text=True)
        result = "Download from GitHub completed."
    except subprocess.CalledProcessError as e:
        result = f"Error: {e.output}"

    standard_apps, featured_apps = get_apps(destination_folder)

    return render_template('download.html', result=result, standard_apps=standard_apps, featured_apps=featured_apps)

def get_apps(package_folder):
    standard_apps = []
    featured_apps = []

    for subdir, _, files in os.walk(package_folder):
        if 'icon.png' in files:
            app_title = os.path.basename(subdir)
            app_download_link = f"/download/{app_title}"

            app_info = {'title': app_title, 'download_link': app_download_link}

            if '.placeholder' in files:
                standard_apps.append(app_info)
            else:
                featured_apps.append(app_info)

    return standard_apps, featured_apps

@app.route('/download/<app_title>')
def download_app(app_title):
    # Assume the app_title matches the directory name
    app_folder = os.path.join(os.getcwd(), 'packages', app_title)
    return send_from_directory(app_folder, 'your_app_file.ext', as_attachment=True)

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
