#!/bin/bash
# --- GENTOO CHROOT INSTALL ---
source /etc/profile
export PS1="(chroot) $PS1"

LOCAL_DIR="/gentoo-install"

echo ">>> Syncing Portage..."
emerge-webrsync

echo ">>> Selecting Mirrors..."
emerge --oneshot app-portage/mirrorselect
mirrorselect -i -o >> /etc/portage/make.conf

mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf

echo ">>> Configuring CPU Flags..."
emerge --oneshot app-portage/cpuid2cpuflags
CPU_FLAGS_RAW=$(cpuid2cpuflags | cut -d: -f2)
echo "CPU_FLAGS_X86=\"$CPU_FLAGS_RAW\"" >> /etc/portage/make.conf
echo ""

# VIDEO_CARDS table
echo "Machine              Discrete video card                       VIDEO_CARDS"
echo "--------------------------------------------------------------------------"
echo "1) Intel x86          None                                      intel"
echo "2) 86/ARM             Nvidia                                    nvidia"
echo "3) Any                Nvidia except Maxwell, Pascal and Volta   nouveau"
echo "4) Any                AMD since Sea Islands                     amdgpu radeonsi"
echo "5) Any                ATI and older AMD                         radeon"
echo "6) Any                Intel                                     intel"
echo "7) Raspberry Pi       N/A                                       vc4"
echo "8) QEMU/KVM           Any                                       virgl"
echo "--------------------------------------------------------------------------"

read -p "Select number 1-8 or type custom VIDEO_CARDS: " vc_input

case $vc_input in
    1|6) VIDEO_CARD="intel" ;;
    2)   VIDEO_CARD="nvidia" ;;
    3)   VIDEO_CARD="nouveau" ;;
    4)   VIDEO_CARD="amdgpu radeonsi" ;;
    5)   VIDEO_CARD="radeon" ;;
    7)   VIDEO_CARD="vc4" ;;
    8)   VIDEO_CARD="virgl" ;;
    *)   VIDEO_CARD="$vc_input" ;;
esac

echo "*/* VIDEO_CARDS: $VIDEO_CARD" > /etc/portage/package.use/00video_cards
echo "VIDEO_CARDS=\"$VIDEO_CARD\"" >> /etc/portage/make.conf

echo ">>> Generating Locales..."
locale-gen
eselect locale list

# Exact message required
echo -e "you can add others later in /etc/locale.gen\nlocale-gen\neselect locale list\neselect locale set <number>"
read -p "Choose your locale number: " locale_choice
eselect locale set $locale_choice

env-update && source /etc/profile

echo ">>> Installing genfstab..."
emerge --oneshot sys-fs/genfstab

echo ">>> Generating fstab..."
# Using -U for UUIDs to ensure boot stability
genfstab -U / > /etc/fstab

echo ">>> fstab generated at /etc/fstab:"
cat /etc/fstab

echo ">>> Configuring Network..."
read -p "Enter your desired hostname: " hostname_input

# Write to /etc/hostname
echo "$hostname_input" > /etc/hostname

# Update /etc/hosts to prevent 'sudo' or 'ping' delays
cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname_input.localdomain  $hostname_input
EOF

echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
emerge --ask --verbose sys-boot/grub

grub-install --efi-directory=/efi

grub-mkconfig -o /boot/grub/grub.cfg


echo ">>> Rebuilding system... grab a coffee, a lunch, and maybe dinner"
# Using --quiet-build can keep the logs clean if you prefer
emerge -uDN @world

echo ">>> Cleaning up old dependencies..."
emerge --depclean

echo ">>> Adding a new user with zsh..."
read -p "Enter username: " username
# We change -s to /bin/zsh
useradd -m -G wheel,video,audio,users,usb,input,android,seat -s /bin/zsh "$username"
passwd "$username"

usermod -s /bin/zsh root

echo ">>> Setting up user environment and dotfiles..."

USER_HOME="/home/$username"
mkdir -p "$USER_HOME/.config"
mkdir -p "$USER_HOME/.local/share"

# Assuming /gentoo-install is your root-level folder in chroot
if [ -d "/gentoo-install" ]; then
    echo ">>> Copying configuration folders..."
    cp -rp /gentoo-install/dotfiles/* "$USER_HOME/.config/"
    cp -rp /gentoo-install/user/fonts "$USER_HOME/.local/share/"

    echo ">>> Copying shell profiles and startup scripts..."
    cp -p /gentoo-install/user/.startup.sh "$USER_HOME/"
    cp -p /gentoo-install/user/.zprofile "$USER_HOME/"
    cp -p /gentoo-install/user/.zshrc "$USER_HOME/"

    chown -R "$username:$username" "$USER_HOME"
    
    echo ">>> Dotfiles and user environment configured."
else
    echo "!!! Warning: /gentoo-install not found. Skipping dotfiles copy."
fi

# dwl
if [ -d "$USER_HOME/.config/dwl" ]; then
    cd "$USER_HOME/.config/dwl" && make && make install
else
    echo "!!! dwl directory not found"
fi

# slstatus
if [ -d "$USER_HOME/.config/slstatus" ]; then
    cd "$USER_HOME/.config/slstatus" && make && make install
else
    echo "!!! slstatus directory not found"

fiecho ">>> Installation finished! You can now exit, unmount, and reboot."
