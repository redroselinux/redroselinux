# Redrose Linux Makefile

FS_DIR = filesystem
INITRAMFS_DIR = initramfs
OUTPUT_DIR = .

INITRAMFS_CPIO = $(OUTPUT_DIR)/initramfs.cpio
INITRAMFS_GZ = $(OUTPUT_DIR)/initramfs.cpio.gz
ISO = $(OUTPUT_DIR)/redrose_linux.iso

all: clean initramfs iso vm

initramfs:
	@echo "[*] Building initramfs..."
	mkdir -p $(INITRAMFS_DIR)/{bin,dev,etc,lib,lib64,mnt,proc,root,run,sbin,sys,tmp,usr,var}
	chmod +x $(INITRAMFS_DIR)/init
	cd $(INITRAMFS_DIR) && find . | cpio -H newc -o > ../$(INITRAMFS_CPIO)
	gzip $(INITRAMFS_CPIO)

iso:
	@echo "[*] Building ISO..."
	mkdir -p $(FS_DIR)/boot/grub
	cp linuxImage $(FS_DIR)/boot/
	cp $(INITRAMFS_GZ) $(FS_DIR)/boot/
	echo 'set default=0' > $(FS_DIR)/boot/grub/grub.cfg
	echo 'set timeout=5' >> $(FS_DIR)/boot/grub/grub.cfg
	echo 'menuentry "Boot Redrose Linux" {' >> $(FS_DIR)/boot/grub/grub.cfg
	echo '    linux /boot/linuxImage' >> $(FS_DIR)/boot/grub/grub.cfg
	echo '    initrd /boot/initramfs.cpio.gz' >> $(FS_DIR)/boot/grub/grub.cfg
	echo '}' >> $(FS_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) $(FS_DIR)

clean:
	@echo "[*] Cleaning..."
	rm -f $(INITRAMFS_CPIO) $(INITRAMFS_GZ) $(ISO)

vm:
	@echo "[*] Running in VM..."
	qemu-system-x86_64 -cdrom $(ISO)

.PHONY: all initramfs iso clean vm
