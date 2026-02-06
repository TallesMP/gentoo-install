#!/bin/bash
# --- GENTOO HOST SETUP ---
STAGE3_URL="https://distfiles.gentoo.org/releases/amd64/autobuilds/20260201T164555Z/stage3-amd64-openrc-20260201T164555Z.tar.xz"
GENTOO_PATH="/mnt/gentoo"
LOCAL_DIR="$(pwd)"

echo ">>> Syncing time and downloading Stage3..."
cd $GENTOO_PATH
chronyd -q
wget "$STAGE3_URL"

echo ">>> Extracting Stage3..."
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C $GENTOO_PATH

echo ">>> Applying custom portage configuration..."
# Removes existing portage dir and replaces with your local copy
rm -rf $GENTOO_PATH/etc/portage
cp -R "$LOCAL_DIR/portage" $GENTOO_PATH/etc/

echo ">>> Preparing filesystem mounts..."
cp --dereference /etc/resolv.conf $GENTOO_PATH/etc/
mount --types proc /proc $GENTOO_PATH/proc
mount --rbind /sys $GENTOO_PATH/sys
mount --make-rslave $GENTOO_PATH/sys
mount --rbind /dev $GENTOO_PATH/dev
mount --make-rslave $GENTOO_PATH/dev
mount --bind /run $GENTOO_PATH/run
mount --make-slave $GENTOO_PATH/run

lsblk
read -p "Enter the boot partition path (including /dev): " boot_partition
mkdir -p $GENTOO_PATH/efi
mount "$boot_partition" $GENTOO_PATH/efi

# Copy necessary files for the second phase
cp "$LOCAL_DIR/locale.gen" $GENTOO_PATH/etc/locale.gen
cp "$LOCAL_DIR/@world" $GENTOO_PATH/var/lib/portage/world
cp "$LOCAL_DIR/install.sh" $GENTOO_PATH/install.sh
chmod +x $GENTOO_PATH/install.sh

echo ">>> Entering Chroot..."
chroot $GENTOO_PATH /bin/bash /install.sh

# Cleanup after return
echo ">>> Setup script finished."
