import os,subprocess,threading,gi
try:import requests
except ImportError:print("Requests not available! Install it using your distro's package manager. The script will attempt to use some common package managers.");os.system('sudo pacman -S --noconfirm python-requests');os.system('sudo apt-get update && sudo apt-get install -y python3-requests');os.system('sudo dnf install -y python3-requests');os.system('sudo yum install -y python3-requests');os.system('sudo zypper install -y python3-requests');os.system('sudo apk add py3-requests');os.system('sudo emerge dev-python/requests');os.system('pip install requests --break-system-packages');os.system('pip3 install requests --break-system-packages');print('restart the script if requests was successfully installed')
gi.require_version('Gtk','4.0')
gi.require_version('Rsvg','2.0')
from gi.repository import GLib,Gtk
ISO_DIR=f"{os.environ.get("HOME")}/.cache"
VERSIONS={'alpha-0.4.1':'https://github.com/redroselinux/redroselinux/releases/download/alpha0.4.1/redrose_linux.iso','alpha-0.4':'https://github.com/redroselinux/redroselinux/releases/download/alpha0.4/redrose_linux.iso','alpha-0.3':'https://github.com/redroselinux/redroselinux/releases/download/alpha0.3/redrose_linux.iso','alpha-0.2':'https://github.com/redroselinux/redroselinux/releases/download/alpha0.2/redrose_linux.iso','alpha-0.1':'https://github.com/redroselinux/redroselinux/releases/download/alpha0.1/redrose_linux.iso'}
def download_file(url,path,progress_callback):
	with requests.get(url,stream=True)as A:
		A.raise_for_status();C=int(A.headers.get('content-length',0));D=0
		with open(path,'wb')as E:
			for B in A.iter_content(chunk_size=8192):
				if B:E.write(B);D+=len(B);F=D/C if C else 0;GLib.idle_add(progress_callback,F)
def download_and_launch(url,iso_path,progress_bar):
	A=iso_path;B=os.path.join(ISO_DIR,'redrose_disk.qcow2')
	if not os.path.exists(A):download_file(url,A,lambda f:progress_bar.set_fraction(f))
	if not os.path.exists(B):subprocess.run(['qemu-img','create','-f','qcow2',B,'2G'])
	C=['qemu-system-x86_64','-enable-kvm','-m','2048','-hda',B,'-cdrom',A,'-boot','d'];subprocess.run(C)
class LauncherWindow(Gtk.ApplicationWindow):
	def __init__(A,app):
		super().__init__(application=app);A.set_title('Redrose Linux Launcher');A.set_default_size(640,480);B=Gtk.Box(orientation=Gtk.Orientation.VERTICAL,spacing=20,margin_top=20,margin_bottom=20,margin_start=20,margin_end=20);B.set_valign(Gtk.Align.CENTER);B.set_halign(Gtk.Align.CENTER);C=Gtk.Label();C.set_markup('<big><b>Redrose Linux Launcher</b></big>');C.set_valign(Gtk.Align.CENTER);C.set_halign(Gtk.Align.CENTER);B.append(C);A.progress_bar=Gtk.ProgressBar();B.append(A.progress_bar);A.version_combo=Gtk.ComboBoxText()
		for E in VERSIONS.keys():A.version_combo.append_text(E)
		A.version_combo.set_active(0);B.append(A.version_combo);D=Gtk.Button(label='Run Selected Version');D.set_valign(Gtk.Align.CENTER);D.set_halign(Gtk.Align.CENTER);D.connect('clicked',A.on_launch_clicked);B.append(D);A.set_child(B)
	def on_launch_clicked(A,button):B=A.version_combo.get_active_text();C=os.path.join(ISO_DIR,f"redrose_{B}.iso");D=VERSIONS[B];threading.Thread(target=download_and_launch,args=(D,C,A.progress_bar),daemon=True).start()
class LauncherApp(Gtk.Application):
	def __init__(A):super().__init__(application_id='io.redrose.launcher')
	def do_activate(A):B=LauncherWindow(A);B.present()
def main():A=LauncherApp();A.run(None)
if __name__=='__main__':main()