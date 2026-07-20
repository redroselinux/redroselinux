import os

print("Redirecting from the old script")
os.system("curl -sSSL https://raw.githubusercontent.com/redroselinux/redroselinux/refs/heads/main/src/redrose-launcher/main.sh | bash")
