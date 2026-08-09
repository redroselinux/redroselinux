#!/bin/sh

printf "\033[1m\033[94m→\033[0m Switching kernel versions\n"
printf "  Enter 'yes' if you want to switch kernels. "
read confirm
if ! [ "$confirm" = "yes" ]; then
  exit 0
fi

printf "  \033[1m\033[94m→\033[0m Available kernels:\n"
ls /boot | grep vmlinuz- | sed 's/^/      /'
printf "  \033[1m\033[94m→\033[0m Pick a kernel version: "
read ver

if ! [ -e "/boot/vmlinuz-$ver" ]; then
  printf "    \033[91;1mx\033[0m /boot/vmlinuz-$ver does not exist\n"
  exec "$0" "$@"
fi
  
printf "  \033[1m\033[94m→\033[0m Press ENTER to use $ver as your kernel. "
read

# Just a reminder this is not a shell injection risk.
# If the user inputs $(reboot) then WHY WOULD ANYONE DO THAT BRO
# but accidentally OH YEAH SURE I ACCIDENTALLY TYPED "$(reboot)"
su -c "ln -sf /boot/vmlinuz-$ver /boot/vmlinuz"
