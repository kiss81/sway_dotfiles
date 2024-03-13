#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

#MACHINE="T14SG3"
MACHINE="WERKBAK"

#mainline kernel & amdgpu
sudo add-apt-repository ppa:cappelikan/ppa
#sudo add-apt-repository ppa:oibaf/graphics-drivers breaks now

sudo apt update; sudo apt dist-upgrade -y

if [ $MACHINE == "T14SG3" ]
then
	sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet text\"/g" /etc/default/grub
	sudo sed -i "s/#GRUB_GFXMODE=.*/GRUB_GFXMODE=800x600/g" /etc/default/grub
        sudo apt -y install powertop
        cp powertop.sh ~/
        chmod +x powertop.sh
        mkdir ~/.config/mpv
        cp mpv.conf ~/.config/mpv/mpv.conf
        sudo cp T14Sd6500b22.icc /usr/share/color/icc/colord/
        echo "@reboot sleep 5 && /home/sander/powertop.sh" >> crontab_new
        echo "@reboot sleep 10 && /usr/bin/pkill swayidle" >> crontab_new
        sudo crontab crontab_new
        rm crontab_new
        sudo apt install tlp-rdw
        sudo systemctl enable tlp
        sudo systemctl start tlp
        sudo sed -i "s/#START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=75/g" /etc/tlp.conf
        sudo sed -i "s/#STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=85/g" /etc/tlp.conf
elif [ $MACHINE == "WERKBAK" ]
then
	sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet text\"/g" /etc/default/grub
	sudo sed -i "s/#GRUB_GFXMODE=.*/GRUB_GFXMODE=800x600/g" /etc/default/grub
        mkdir ~/.config/mpv
        cp mpv.conf ~/.config/mpv/mpv.conf
        sudo cp HDR4K_LG_LCD.icc /usr/share/color/icc/colord/
        echo "@reboot sleep 10 && /usr/bin/pkill swayidle" >> crontab_new
        sudo crontab crontab_new
        rm crontab_new
else
        echo "No machine selected";
        exit 1;
fi
sudo update-grub;

#remove stuff
sudo apt purge imagemagick* lximage-qt* neovim* thunderbird musikcube transmission-* qutebrowser* ranger

# core install
sudo apt -y install build-essential git lm-sensors curl wget htop sshuttle usb-creator-gtk rfkill p7zip-full unrar xiccd python3-venv cmake

#extra install 
sudo apt -y install seahorse screen virt-viewer remmina remmina-plugin-vnc firefox firefox-locale-nl smbclient terminator cifs-utils nfs-common gvfs-fuse android-file-transfer --no-install-recommends
#sudo apt -y install thunar thunar-volman tumbler tumbler-plugins-extra ffmpegthumbnailer gthumb gvfs gvfs-backends ntp --no-install-recommends
sudo apt -y install gthumb gvfs gvfs-backends ntp --no-install-recommends

# make time dual boot compatible with windows
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# office and spelling
sudo apt -y install libreoffice aspell-nl cups hunspell-nl atril

#development
sudo usermod -aG dialout $USER
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=36000'
git config --global user.email "sln302@vu.nl"
git config --global user.name "sln302"


# multimedia
sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/download/2024.03.10/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
#set python
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 11


#ff2mpv for firefox
firefox &
sleep 5
pkill firefox
cd ~/
git clone https://github.com/woodruffw/ff2mpv
cd ff2mpv
./install.sh

#clean apt cache dir
sudo apt-get -y autoremove --purge
sudo rm /var/cache/apt/archives/*.deb

# color profiles
sudo pkill xiccd
sudo systemctl restart colord.service
xiccd &

# switch
if [ $MACHINE == "T14SG3" ]
then
        colormgr device-add-profile 'xrandr-eDP-1' 'icc-5a0baf48c67ff298a4ae0e50c9f3d55f'
        colormgr device-make-profile-default 'xrandr-eDP-1' 'icc-5a0baf48c67ff298a4ae0e50c9f3d55f'
elif [ $MACHINE == "WERKBAK" ]
then
        colormgr device-add-profile 'xrandr-DP-1' 'icc-79a4f0cdb3785ace113fb83e78e0a0ce'
        colormgr device-make-profile-default 'xrandr-DP-1' 'icc-79a4f0cdb3785ace113fb83e78e0a0ce'
else
        echo "No machine selected";
        exit 1;
fi
