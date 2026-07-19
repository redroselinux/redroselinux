import os
import subprocess
"""
Redrose Linux VM Launcher
Start with: 
	curl -s https://redroselinux.org/vm_launcher.sh | sh
or  curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.py | python3
"""

import threading
import gi
import sys

try:
    import requests
except ImportError:
    print("Requests not available! Install it using your distro's package manager.")
    print("The script will attempt to use some common package managers...")
    os.system('sudo pacman -S --noconfirm python-requests')
    os.system('sudo apt-get update && sudo apt-get install -y python3-requests')
    os.system('sudo dnf install -y python3-requests')
    os.system('sudo yum install -y python3-requests')
    os.system('sudo zypper install -y python3-requests')
    os.system('sudo apk add py3-requests')
    os.system('sudo emerge dev-python/requests')
    os.system('pip install requests --break-system-packages')
    os.system('pip3 install requests --break-system-packages')
    print('Restart the script if requests was successfully installed.')
    sys.exit(1)

gi.require_version('Gtk', '4.0')
gi.require_version('Rsvg', '2.0')
from gi.repository import GLib, Gtk

ISO_DIR = f"{os.environ.get('HOME')}/.cache"
VERSIONS = {
    "alpha-0.6": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.6/redrose_linux.iso",
	"alpha-0.5.1": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.5.1/redrose_linux.iso",
    "alpha-0.5": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.5/redrose_linux.iso",
    "alpha-0.4.2": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.4.2/redrose_linux.iso",
    "alpha-0.4.1": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.4.1/redrose_linux.iso",
    "alpha-0.4": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.4/redrose_linux.iso",
    "alpha-0.3": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.3/redrose_linux.iso",
    "alpha-0.2": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.2/redrose_linux.iso",
    "alpha-0.1": "https://github.com/redroselinux/redroselinux/releases/download/alpha0.1/redrose_linux.iso",
}


def download_file(url, path, progress_callback):
    with requests.get(url, stream=True) as response:
        response.raise_for_status()
        total_size = int(response.headers.get('content-length', 0))
        downloaded_size = 0

        with open(path, 'wb') as file:
            for chunk in response.iter_content(chunk_size=8192):
                if chunk:
                    file.write(chunk)
                    downloaded_size += len(chunk)
                    progress = downloaded_size / total_size if total_size else 0
                    GLib.idle_add(progress_callback, progress)


def download_and_launch(url, iso_path, progress_bar):
    disk_image_path = os.path.join(ISO_DIR, 'redrose_disk.qcow2')

    if not os.path.exists(iso_path):
        download_file(url, iso_path, lambda fraction: progress_bar.set_fraction(fraction))

    if not os.path.exists(disk_image_path):
        subprocess.run(['qemu-img', 'create', '-f', 'qcow2', disk_image_path, '2G'])

    qemu_command = [
        'qemu-system-x86_64',
        '-enable-kvm',
        '-m', '2048',
        '-hda', disk_image_path,
        '-cdrom', iso_path,
        '-boot', 'd'
    ]
    subprocess.run(qemu_command)


class LauncherWindow(Gtk.ApplicationWindow):
    def __init__(self, app):
        super().__init__(application=app)
        self.set_title('Redrose Linux Launcher')
        self.set_default_size(640, 480)

        main_box = Gtk.Box(
            orientation=Gtk.Orientation.VERTICAL,
            spacing=20,
            margin_top=20,
            margin_bottom=20,
            margin_start=20,
            margin_end=20
        )
        main_box.set_valign(Gtk.Align.CENTER)
        main_box.set_halign(Gtk.Align.CENTER)

        title_label = Gtk.Label()
        title_label.set_markup('<big><b>Redrose Linux Launcher</b></big>')
        title_label.set_valign(Gtk.Align.CENTER)
        title_label.set_halign(Gtk.Align.CENTER)
        main_box.append(title_label)

        self.progress_bar = Gtk.ProgressBar()
        main_box.append(self.progress_bar)

        self.version_combo = Gtk.ComboBoxText()
        for version in VERSIONS.keys():
            self.version_combo.append_text(version)
        self.version_combo.set_active(0)
        main_box.append(self.version_combo)

        launch_button = Gtk.Button(label='Run Selected Version')
        launch_button.set_valign(Gtk.Align.CENTER)
        launch_button.set_halign(Gtk.Align.CENTER)
        launch_button.connect('clicked', self.on_launch_clicked)
        main_box.append(launch_button)

        self.set_child(main_box)

    def on_launch_clicked(self, button):
        selected_version = self.version_combo.get_active_text()
        iso_filename = f"redrose_{selected_version}.iso"
        iso_path = os.path.join(ISO_DIR, iso_filename)
        download_url = VERSIONS[selected_version]

        thread = threading.Thread(
            target=download_and_launch,
            args=(download_url, iso_path, self.progress_bar),
            daemon=True
        )
        thread.start()


class LauncherApp(Gtk.Application):
    def __init__(self):
        super().__init__(application_id='io.redrose.launcher')

    def do_activate(self):
        window = LauncherWindow(self)
        window.present()

def main():
    app = LauncherApp()
    app.run(None)


if __name__ == '__main__':
    main()
