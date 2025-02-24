#!/usr/bin/env bash

# Last edit: 24.02.2025

echo ""
echo "----------------------------------------------"
echo "   Opensuse Tumbleweed config after install   "
echo "                                              "
echo "----------------------------------------------"
sleep 2
echo ""
echo "      !!!You should read this script first!!!
"
echo ""
echo "
This script installs:
Fastfetch (Terminal System info)
AMD GPU driver
Codecs for Multimedia
Multimedia Programs like celluloid and strawberry
wine (optional)
Steam (optional)

Important:
Since opensuse tumbleweed use SElinux you must set for wine,steam etc this line in terminal:
sudo setsebool -P selinuxuser_execmod 1
Otherwise some games will not be run
"
echo ""
read -p "Press any key to continue.."

sudo zypper refresh
sudo zypper -n dup

# Needed system packages
sudo zypper -n install dkms bind samba git openssh fakeroot irqbalance quota ccache mono-basic
sudo zypper -n install hdparm sdparm hwdata sof-firmware fwupd gsmartcontrol

sudo zypper -n install gnome-disk-utility mtools xfsdump jfsutils f2fs-tools libf2fs_format9
sudo zypper -n install ntfs-3g libfsntfs1 libluksde1 libftxf1

sudo zypper -n install xdg-utils xdg-desktop-portal xdg-desktop-portal-gtk xdg-user-dirs
sudo zypper -n install fastfetch fastfetch-bash-completion
sudo zypper -n install -t pattern devel_basis
sudo zypper -n install fetchmsttfonts

# Set fastfetch to start with the terminal
echo "fastfetch" | tee -a ~/.bashrc




# Recommend packages: AMD GPU driver
sudo zypper -n install libdrm_amdgpu1 kernel-firmware-amdgpu libvdpau_va_gl1 libva-vdpau-driver
sudo zypper -n install Mesa-libva libOSMesa8
sudo zypper -n install vulkan-validationlayers Mesa-vulkan-overlay libvkd3d1

echo "
CPU_LIMIT=0
CPU_GOVERNOR=performance
GPU_USE_SYNC_OBJECTS=1
PYTHONOPTIMIZE=1
AMD_VULKAN_ICD=RADV
RADV_PERFTEST=aco,sam,nggc
RADV_DEBUG=novrsflatshading
GAMEMODE=1
vblank_mode=1
PROTON_LOG=0
PROTON_USE_WINED3D=0
PROTON_FORCE_LARGE_ADDRESS_AWARE=1
PROTON_USE_FSYNC=1
DXVK_ASYNC=1
WINE_FSR_OVERRIDE=1
WINE_FULLSCREEN_FSR=1
WINE_VK_USE_FSR=1
WINEFSYNC_SPINCOUNT=24
MESA_BACK_BUFFER=ximage
MESA_NO_DITHER=1
MESA_SHADER_CACHE_DISABLE=false
mesa_glthread=true
MESA_DEBUG=0
MESA_VK_ENABLE_SUBMIT_THREAD=1
ANV_ENABLE_PIPELINE_CACHE=1
LIBGL_DEBUG=0
LIBC_FORCE_NOCHECK=1
__GLX_VENDOR_LIBRARY_NAME=mesa
__GL_THREADED_OPTIMIZATIONS=1
" | sudo tee -a /etc/environment


# Recommend packages: Various needed packages
sudo zypper -n install thunderbird discord 

# Recommend packages: Codecs
sudo zypper -n install gstreamer-plugins-good-extra gstreamer-plugin-openh264 gstreamer-plugins-ugly
sudo zypper -n install gstreamer-plugin-pipewire gstreamer-plugin-python gstreamer-plugins-libav gstreamer-plugins-vaapi
sudo zypper -n install lame flac libmad0 ffmpeg-7 rtkit libopenal0 libsoxr-lsr0 opus-tools

# Multimedia
sudo zypper -n install celluloid strawberry soundconverter yt-dlp pavucontrol


# Install wine
sudo zypper install wine wine-mono winetricks protontricks wine-binfmt libgdiplus0 

# Install steam
sudo zypper install steam steam-devices ProtonPlus libFAudio0 gamemode libgamemode0 libgstvulkan-1_0-0-32bit
sudo zypper install plasma-wayland-protocols
sudo zypper install xf86-video-amdgpu


sudo systemctl enable fstrim.timer
sudo fstrim -av

sudo systemctl enable irqbalance

sudo zypper clean

# Enable tmpfs ramdisk
sudo sed -i -e '/^\/\/tmpfs/d' /etc/fstab
echo -e "
tmpfs /var/tmp tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /var/log tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /var/run tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /var/lock tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /var/volatile tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /var/spool tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
tmpfs /dev/shm tmpfs nodiratime,nodev,nosuid,mode=1777 0 0
" | sudo tee -a /etc/fstab
clear

echo ""
echo "Postconfig is complete. Press any key to reboot."
sudo reboot

