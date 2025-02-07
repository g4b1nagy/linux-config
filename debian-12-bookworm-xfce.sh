#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# =========================================================================
# Prerequisites
# =========================================================================

# Add yourself to the sudo group.
su --login
adduser john sudo

# Log out and log back in.

full_name="John Doe"
email="john@doe.com"

# =========================================================================
# Install packages
# =========================================================================

packages=(
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
    python3-venv
    redis-server
    sublime-text
    viewnior
    vim
    vlc

    gvfs-backends
    gvfs-fuse
    mtp-tools
)

# Add Sublime Text apt repository (https://www.sublimetext.com/docs/linux_repositories.html)
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

sudo apt update
sudo apt install "${packages[@]}"

# =========================================================================
# Configure Bash
# =========================================================================

cp ~/.bashrc ~/.bashrc_backup_$(date +%F_%T)
cp ~/.profile ~/.profile_backup_$(date +%F_%T)

echo "

# =========================================================================
# $USER's config
# =========================================================================

function cd {
    builtin cd \"\$@\"
    if [[ -d venv ]]
    then
        source venv/bin/activate
    elif [[ -d .venv ]]
    then
        source .venv/bin/activate
    fi
}

export PAGER='less -S'

alias grep='grep --color=auto'
alias ls='ls -l --human-readable --color=auto'
alias py='python3'

alias b='git branch'
alias c='git checkout'
alias d='git diff --minimal'
alias dc='git diff --minimal --cached'
alias s='git status'

alias doff='xrandr --output eDP-1 --off'
alias don='xrandr --output eDP-1 --auto'
" >> ~/.bashrc

# =========================================================================
# Configure Xsession (https://wiki.debian.org/Xsession)
# =========================================================================

echo "if [ -r ~/.profile ]
then
    . ~/.profile
fi
" >> ~/.xsessionrc

# =========================================================================
# Configure Guake
# =========================================================================

echo "
[general]
compat-delete='delete-sequence'
display-n=0
display-tab-names=0
gtk-use-system-default-theme=false
hide-tabs-if-one-tab=false
history-size=1000
infinite-history=true
load-guake-yml=true
max-tab-name-length=14
mouse-display=true
open-tab-cwd=false
prompt-on-quit=true
quick-open-command-line='gedit %(file_path)s'
restore-tabs-notify=true
restore-tabs-startup=false
save-tabs-when-changed=true
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

sudo cp /usr/share/applications/guake.desktop /etc/xdg/autostart/

# =========================================================================
# Configure Sublime Text
# =========================================================================

mkdir -p ~/.config/sublime-text/Packages/User/

echo '[
    {"command": "expand_selection", "args": {"to": "line"}},
    {"command": "left_delete"}
]' > ~/.config/sublime-text/Packages/User/DeleteLine.sublime-macro

# Preferences => Key Bindings
echo '[
    { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "Packages/User/DeleteLine.sublime-macro"}},
    { "keys": ["ctrl+tab"], "command": "next_view" },
    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
    { "keys": ["ctrl+f"], "command": "show_panel", "args": { "panel": "find", "in_selection": false } }
]' > ~/.config/sublime-text/Packages/User/Default\ \(Linux\).sublime-keymap

# Preferences => Settings
echo '{
    "auto_close_tags": false,
    "auto_complete": false,
    "caret_style": "smooth",
    "color_scheme": "Monokai.sublime-color-scheme",
    "enable_tab_scrolling": false,
    "ensure_newline_at_eof_on_save": true,
    "folder_exclude_patterns": [".git", ".ipynb_checkpoints", ".mypy_cache", ".pytest_cache", ".ruff_cache", "__pycache__", "node_modules", "venv"],
    "font_size": 10,
    "mini_diff": false,
    "rulers": [88],
    "show_definitions": false,
    "show_git_status": false,
    "spell_check": false,
    "tab_completion": false,
    "tab_size": 4,
    "theme": "Adaptive.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_only_modified_white_space": false,
    "trim_trailing_white_space_on_save": "all",
}' > ~/.config/sublime-text/Packages/User/Preferences.sublime-settings

# Add .ini syntax highlighting
wget https://github.com/jwortmann/ini-syntax/archive/refs/tags/v1.5.2.tar.gz
tar -xzvf v1.5.2.tar.gz --directory ~/.config/sublime-text/Packages/

# Add .toml syntax highlighting
wget https://github.com/jasonwilliams/sublime_toml_highlighting/archive/refs/tags/v2.5.0.tar.gz
tar -xzvf v2.5.0.tar.gz --directory ~/.config/sublime-text/Packages/

# Add .tf syntax highlighting
wget https://github.com/alexlouden/Terraform.tmLanguage/archive/refs/tags/1.2.0.tar.gz
tar -xzvf 1.2.0.tar.gz --directory ~/.config/sublime-text/Packages/

# =========================================================================
# Configure Vim
# =========================================================================

mkdir -p ~/.vim/colors/
wget -P ~/.vim/colors/ https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim

echo "colorscheme molokai
set expandtab
set mouse-=a
set shiftwidth=4
set tabstop=4
syntax on" > ~/.vimrc

sudo update-alternatives --set editor /usr/bin/vim.basic

# =========================================================================
# Configure Git
# =========================================================================

git config --global advice.skippedCherryPicks false
git config --global color.ui true
git config --global init.defaultBranch master
git config --global pull.rebase true
git config --global user.email "${email}"
git config --global user.name "${full_name}"

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
# Configure sqlite3
# =========================================================================

echo ".header on
.mode table" > ~/.sqliterc

# =========================================================================
# Disable suspend and hibernation (https://wiki.debian.org/Suspend)
# =========================================================================

sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# =========================================================================
# Configure keyboard layouts
# =========================================================================

sudo cp /usr/share/X11/xkb/symbols/ch /usr/share/X11/xkb/symbols/ch_backup_$(date +%F_%T)

echo '
// DE_US / programmer layout.
// Based on:
// https://faiwer.ru/content/175-custom_english-german_layout_for_ubuntu

default  partial alphanumeric_keys
xkb_symbols "basic" {
    include "us"

    name[Group1]="German";

    key <AC01> { [     a,          A,    adiaeresis,       Adiaeresis ] };
    key <AC02> { [     s,          S,    ssharp,           section    ] };
    key <AD07> { [     u,          U,    udiaeresis,       Udiaeresis ] };
    key <AD09> { [     o,          O,    odiaeresis,       Odiaeresis ] };
    key <AD03> { [     e,          E,    eacute,           Eacute     ] };

    include "level3(ralt_switch)"
};' | sudo tee /usr/share/X11/xkb/symbols/ch

xfconf-query -c keyboard-layout -p /Default/XkbLayout -n -t string -s "ro,ch"

# =========================================================================
# Set first day of week to Monday (https://wiki.debian.org/Locale)
# =========================================================================

sudo cp /etc/locale.gen /etc/locale.gen_backup_$(date +%F_%T)
sudo sed -i '/^# en_GB\.UTF-8/s/^# //' /etc/locale.gen
sudo locale-gen

sudo cp /etc/default/locale /etc/default/locale_backup_$(date +%F_%T)
echo '
LC_TIME="en_GB.UTF-8"
' | sudo tee -a /etc/default/locale

# =========================================================================
# Set timezone
# =========================================================================

sudo timedatectl set-timezone Europe/Bucharest

# =========================================================================
# Configure fonts
# =========================================================================

# Remove Noto fonts so the system may fall back to DejaVu.
sudo cp /usr/share/fontconfig/conf.avail/60-latin.conf /usr/share/fontconfig/conf.avail/60-latin.conf_backup_$(date +%F_%T)
sudo sed -i 's/.*Noto.*//g' /usr/share/fontconfig/conf.avail/60-latin.conf

# =========================================================================
# XFCE settings
# =========================================================================

# Power Manager => System => When laptop lid is closed: => Switch off display
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t int -s "0"
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t int -s "0"
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -n -t bool -s "false"

# Power Manager Plugin => Show label: Percentage
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/show-panel-label -n -t int -s "1"

# Disable power manager notifications
xfconf-query -c xfce4-notifyd -p /applications/muted_applications -n -t string -s "xfce4-power-manager" -a

# Tasklist
tasklist_plugin=$(xfconf-query -c xfce4-panel -p /plugins -l -v | grep tasklist | cut -d' ' -f 1)
# Panel => Window Buttons => Group windows by application
xfconf-query -c xfce4-panel -p $tasklist_plugin/grouping -n -t bool -s "false"

# Clock
clock_plugin=$(xfconf-query -c xfce4-panel -p /plugins -l -v | grep clock | cut -d' ' -f 1)
# Layout: Time Only
xfconf-query -c xfce4-panel -p $clock_plugin/digital-layout -n -t int -s "3"
# Font:
xfconf-query -c xfce4-panel -p $clock_plugin/digital-time-font -n -t string -s "Sans 10"

# thunar => Preferences => View new folders using: Compact List View
xfconf-query -c thunar -p /default-view -n -t string -s "ThunarCompactView"

# thunar => Close window with multiple tabs? => Do not ask me again
xfconf-query -c thunar -p /misc-confirm-close-multiple-tabs -n -t bool -s "false"

# xfwm4 => mousewheel_rollup
xfconf-query -c xfwm4 -p /general/mousewheel_rollup -n -t bool -s "false"

# Workspace Switcher => Number of workspaces: 2
xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s "2"

# Launch GNOME services on startup
xfconf-query -c xfce4-session -p /compat/LaunchGNOME -n -t bool -s "true"

# Log Out => Save session for future logins
xfconf-query -c xfce4-session -p /general/SaveOnExit -n -t bool -s "false"

# Desktop icons
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s "false"

# Keyboard
xfconf-query -c keyboards -p /Default/KeyRepeat/Delay -n -t int -s "250"
xfconf-query -c keyboards -p /Default/KeyRepeat/Rate -n -t int -s "50"
xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Print" -n -t string -s "xfce4-screenshooter -f -s /home/$USER/Desktop/"

# Mouse
xfconf-query -c pointers -p /Logitech_Wireless_Mouse/Acceleration -n -t double -s "8"

# =========================================================================
# XFCE theme (https://github.com/vinceliuice/Matcha-gtk-theme)
# =========================================================================

sudo apt-get install gtk2-engines-murrine gtk2-engines-pixbuf

wget https://github.com/vinceliuice/Matcha-gtk-theme/archive/refs/tags/2023-04-03.tar.gz
tar -xzvf 2023-04-03.tar.gz
cd Matcha-gtk-theme-2023-04-03/
./install.sh

xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "Matcha-dark-sea"

# =========================================================================
# XFCE icon theme (https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
# =========================================================================

sudo apt install papirus-icon-theme

xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "Papirus"

# =========================================================================
# Fix ~/.config/mimeapps.list
# =========================================================================

echo "[Default Applications]" > ~/.config/mimeapps.list

cat /usr/share/applications/mimeinfo.cache | grep 'vim.desktop' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=sublime_text.desktop;"
done >> ~/.config/mimeapps.list

cat /usr/share/applications/mimeinfo.cache | grep -E 'text/html|text/xml' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=chromium.desktop;"
done >> ~/.config/mimeapps.list

cat /usr/share/applications/mimeinfo.cache | grep 'display-im6.q16.desktop' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=viewnior.desktop;"
done >> ~/.config/mimeapps.list

cat /usr/share/applications/mimeinfo.cache | grep 'image/pdf' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=atril.desktop;"
done >> ~/.config/mimeapps.list

cat /usr/share/applications/mimeinfo.cache | grep -E 'QuodLibet|Parole' | cut -d'=' -f 1 | while read -r mime;
do
    echo "$mime=vlc.desktop;"
done >> ~/.config/mimeapps.list

# =========================================================================
# Configure Firefox
# =========================================================================

about:config
toolkit.tabbox.switchByScrolling => true
