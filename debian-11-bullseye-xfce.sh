#!/usr/bin/env bash


# =========================================================================
# Prerequisites
# =========================================================================

username="john"
full_name="John Doe"
email="john@doe.com"

# Add user to sudo group
usermod -aG sudo $username

# =========================================================================
# Install WiFi firmware (https://wiki.debian.org/iwlwifi)
# =========================================================================

wget http://ftp.debian.org/debian/pool/non-free/f/firmware-nonfree/firmware-iwlwifi_20210315-3_all.deb
sudo dpkg -i firmware-iwlwifi_20200421-1_all.deb
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi

# =========================================================================
# Fix /etc/apt/sources.list (https://wiki.debian.org/SourcesList)
# =========================================================================

sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup_$(date +%F_%T)

echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free

deb http://deb.debian.org/debian bullseye main non-free
deb-src http://deb.debian.org/debian bullseye main non-free

deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free" | sudo tee /etc/apt/sources.list > /dev/null

sudo apt update
sudo apt upgrade

# =========================================================================
# Install packages
# =========================================================================

packages="
blueman
chromium
dconf-cli
filezilla
gimp
git
guake
imagemagick
inkscape
ncal
nginx
postgresql
redis-server
redis-tools
viewnior
vim
vlc

gvfs-backends
gvfs-fuse
mtp-tools

firmware-iwlwifi
firmware-linux
firmware-sof-signed
"

sudo apt install $packages

# + https://www.sublimetext.com/docs/linux_repositories.html

# =========================================================================
# Configure Bash
# =========================================================================

cp /home/$USER/.bashrc /home/$USER/.bashrc_backup_$(date +%F_%T)

echo "

# =========================================================================
# $USER's config
# =========================================================================

function cd {
    builtin cd \"\$@\"
    if [ -d venv ]
    then
        source venv/bin/activate
    fi
}

alias ls='ls -lh --color=auto'
alias grep='grep --color=auto'
alias py='python3'

alias s='git status'
alias d='git diff --minimal'
alias c='git checkout'

alias doff='xrandr --output eDP-1 --off'
alias don='xrandr --output eDP-1 --auto'
" >> /home/$USER/.bashrc

echo "
set enable-bracketed-paste off
" >> /home/$USER/.inputrc

# =========================================================================
# Configure Guake
# =========================================================================

echo "
[general]
abbreviate-tab-names=false
compat-delete='delete-sequence'
display-n=0
history-size=1000
infinite-history=true
max-tab-name-length=14
mouse-display=true
open-tab-cwd=false
prompt-on-quit=true
quick-open-command-line='gedit %(file_path)s'
restore-tabs-notify=false
restore-tabs-startup=false
save-tabs-when-changed=false
scroll-keystroke=true
use-default-font=true
use-popup=false
use-scrollbar=true
use-trayicon=false
window-halignment=0
window-height=100
window-losefocus=false
window-refocus=false
window-tabbar=true
window-width=100

[keybindings/global]
show-hide='<Primary>space'

[keybindings/local]
decrease-height='disabled'
decrease-transparency='disabled'
increase-height='disabled'
increase-transparency='disabled'
new-tab='<Primary><Shift>n'
new-tab-home='disabled'
next-tab='<Primary><Shift>Right'
previous-tab='<Primary><Shift>Left'
toggle-transparency='disabled'

[style/background]
transparency=100

[style/font]
allow-bold=true
palette='#1C1C1D1D1919:#D0D01B1B2424:#A7A7D3D32C2C:#D8D8CFCF6767:#6161B8B8D0D0:#69695A5ABBBB:#D5D538386464:#FEFEFFFFFEFE:#1C1C1D1D1919:#D0D01B1B2424:#A7A7D3D32C2C:#D8D8CFCF6767:#6161B8B8D0D0:#69695A5ABBBB:#D5D538386464:#FEFEFFFFFEFE:#F6F6F5F5EEEE:#232325252626'
palette-name='Monokai'
" | dconf load /apps/guake/

mkdir -p /home/$USER/.config/autostart/
cp /usr/share/applications/guake.desktop /home/$USER/.config/autostart/

# =========================================================================
# Configure Sublime Text
# =========================================================================

mkdir -p /home/$USER/.config/sublime-text/Packages/User/

echo '[
    {"command": "expand_selection", "args": {"to": "line"}},
    {"command": "left_delete"}
]' > /home/$USER/.config/sublime-text/Packages/User/DeleteLine.sublime-macro

# Preferences => Key Bindings - User
echo '[
    { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "Packages/User/DeleteLine.sublime-macro"}},
    { "keys": ["ctrl+tab"], "command": "next_view" },
    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
    { "keys": ["ctrl+f"], "command": "show_panel", "args": { "panel": "find", "in_selection": false } }
]' > /home/$USER/.config/sublime-text/Packages/User/Default\ \(Linux\).sublime-keymap

# Preferences => Settings - User
echo '{
    "auto_close_tags": false,
    "auto_complete": false,
    "caret_style": "smooth",
    "color_scheme": "Monokai.sublime-color-scheme",
    "enable_tab_scrolling": false,
    "ensure_newline_at_eof_on_save": true,
    "folder_exclude_patterns": [".git", "node_modules"],
    "font_size": 10,
    "mini_diff": false,
    "show_definitions": false,
    "show_git_status": false,
    "spell_check": false,
    "tab_completion": false,
    "tab_size": 4,
    "theme": "Adaptive.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_only_modified_white_space": false,
    "trim_trailing_white_space_on_save": "all",
}' > /home/$USER/.config/sublime-text/Packages/User/Preferences.sublime-settings

# Add .ini file syntax highlighting
wget https://codeload.github.com/jwortmann/ini-syntax/tar.gz/refs/tags/v1.4.3
tar -xzvf v1.4.3 --directory /home/$USER/.config/sublime-text/Packages/

# Add .toml file syntax highlighting
wget https://github.com/jasonwilliams/sublime_toml_highlighting/archive/refs/tags/v2.5.0.tar.gz
tar -xzvf v2.5.0.tar.gz --directory /home/$USER/.config/sublime-text/Packages/

# =========================================================================
# Configure Vim
# =========================================================================

mkdir -p /home/$USER/.vim/colors/
wget -P /home/$USER/.vim/colors/ https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim

echo "colorscheme molokai
set expandtab
set mouse-=a
set shiftwidth=4
set t_Co=256
set tabstop=4
syntax on" > /home/$USER/.vimrc

sudo update-alternatives --config editor

# =========================================================================
# Configure nginx
# =========================================================================

sudo chown $USER:$USER -R /var/www/html/
sudo chmod 755 -R /var/www/html/

mv /var/www/html/index.nginx-debian.html /var/www/html/backup_index.nginx-debian.html
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default_backup_$(date +%F_%T)
sudo sed -i '/^\tlocation \/ {/s/{/{\n\t\tautoindex on;/' /etc/nginx/sites-available/default
sudo systemctl restart nginx

# =========================================================================
# Configure Git
# =========================================================================

git config --global user.name "$full_name"
git config --global user.email "$email"
git config --global pull.rebase true
git config --global color.ui true
git config --global init.defaultBranch master

# =========================================================================
# Set timezone
# =========================================================================

sudo timedatectl set-timezone Europe/Bucharest

# =========================================================================
# Set first day of week to Monday (https://wiki.debian.org/Locale)
# =========================================================================

sudo cp /etc/locale.gen /etc/locale.gen_backup_$(date +%F_%T)
sudo sed -i '/^# en_GB\.UTF-8/s/^# //' /etc/locale.gen
sudo locale-gen

sudo cp /etc/default/locale /etc/default/locale_backup_$(date +%F_%T)
echo '
LC_TIME="en_GB.UTF-8"
' | sudo tee -a /etc/default/locale > /dev/null

# =========================================================================
# XFCE settings
# =========================================================================

# Power Manager => Show label: Percentage
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/show-panel-label -n -t int -s "1"

# Clock => Format: %H:%M
clock_plugin=$(xfconf-query -c xfce4-panel -p /plugins -l -v | grep clock | cut -d' ' -f 1)
xfconf-query -c xfce4-panel -p $clock_plugin/digital-format -n -t string -s "%H:%M"


# thunar => Preferences => View new folders using: Compact List View
xfconf-query -c thunar -p /default-view -n -t string -s "ThunarCompactView"


# thunar => Close window with multiple tabs? => Do not ask me again
xfconf-query -c thunar -p /misc-confirm-close-multiple-tabs -n -t bool -s "false"


# Workspace Switcher => Number of workspaces: 2
xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s "2"


# Disable power manager notifications
xfconf-query -c xfce4-notifyd -p /applications/muted_applications -n -t string -s "xfce4-power-manager" -a


# Launch GNOME services on startup
xfconf-query -c xfce4-session -p /compat/LaunchGNOME -n -t bool -s "true"


# Log Out => Save session for future logins
xfconf-query -c xfce4-session -p /general/SaveOnExit -n -t bool -s "false"


# Keyboard
xfconf-query -c keyboards -p /Default/KeyRepeat/Delay -n -t int -s "250"
xfconf-query -c keyboards -p /Default/KeyRepeat/Rate -n -t int -s "50"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Print" -n -t string -s "xfce4-screenshooter -f -s /home/$USER/Desktop/"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary>Print" -n -t string -s "xfce4-screenshooter"


# Mouse
xfconf-query -c pointers -p /Logitech_Wireless_Mouse/Acceleration -n -t double -s "8"


# Desktop icons
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s "false"

# =========================================================================
# XFCE theme (https://github.com/vinceliuice/Matcha-gtk-theme)
# =========================================================================

sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf

# https://github.com/vinceliuice/Matcha-gtk-theme/releases => Latest release => Source code (tar.gz)
# tar -xf Matcha-gtk-theme-...
# cd Matcha-gtk-theme-...
# ./install.sh

xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Matcha-dark-sea"

# =========================================================================
# XFCE icon theme (https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
# =========================================================================

sudo apt-get install papirus-icon-theme

xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus"

# =========================================================================
# xfce4-screenshooter
# =========================================================================

echo "app=/usr/bin/display-im6.q16
last_user=
screenshot_dir=file:/home/$USER/Desktop
action=1
delay=0
region=1
show_mouse=0" > /home/$USER/.config/xfce4/xfce4-screenshooter

# =========================================================================
# xarchiver
# =========================================================================

mkdir -p /home/$USER/.config/xarchiver/

echo "[xarchiver]
preferred_format=11
prefer_unzip=true
confirm_deletion=true
sort_filename_content=false
store_output=false
icon_size=2
show_archive_comment=false
show_sidebar=true
show_location_bar=true
show_toolbar=true
preferred_custom_cmd=
preferred_temp_dir=/tmp
preferred_extract_dir=/home/$USER/Desktop
allow_sub_dir=0
ensure_directory=true
overwrite=false
full_path=true
touch=false
fresh=false
update=false
store_path=false
updadd=false
freshen=false
recurse=true
solid_archive=false
remove_files=false" > /home/$USER/.config/xarchiver/xarchiverrc

# =========================================================================
# Fix /home/$USER/.config/mimeapps.list
# =========================================================================

echo "[Default Applications]" > /home/$USER/.config/mimeapps.list


cat /usr/share/applications/mimeinfo.cache | grep 'vim.desktop' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=sublime_text.desktop;"
done >> /home/$USER/.config/mimeapps.list


cat /usr/share/applications/mimeinfo.cache | grep -E 'text/html|text/xml' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=chromium.desktop;"
done >> /home/$USER/.config/mimeapps.list


cat /usr/share/applications/mimeinfo.cache | grep 'display-im6.q16.desktop' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=viewnior.desktop;"
done >> /home/$USER/.config/mimeapps.list


cat /usr/share/applications/mimeinfo.cache | grep 'image/pdf' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=atril.desktop;"
done >> /home/$USER/.config/mimeapps.list


cat /usr/share/applications/mimeinfo.cache | grep -E 'QuodLibet|Parole' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=vlc.desktop;"
done >> /home/$USER/.config/mimeapps.list
