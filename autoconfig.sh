#!/bin/bash


# =========================================================================
# INSTALL PACKAGES
# =========================================================================

sudo apt-get update
sudo apt-get install audacious audacity build-essential filezilla gconf-editor gimp git guake imagemagick inkscape lamp-server^ lftp mongodb nodejs npm pyrenamer python-dev python-pip python-virtualenv python3-dev sqlite3 tesseract-ocr vim virtualbox virtualbox-guest-additions-iso vlc


# =========================================================================
# APPLY SETTINGS
# =========================================================================

gsettings set com.canonical.desktop.interface scrollbar-mode normal # display normal scrollbars instead of overlay
gsettings set com.canonical.Unity.Lenses remote-content-search none # hide online search results from dash

gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2 # enable workspaces

gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ disable-show-desktop true # hide 'Show desktop' icon from Alt-Tab
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ edge-responsiveness 4 # launcher show sensitivity
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 32 # launcher icon size
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-hide-mode 1 # auto hide launcher

gsettings set org.gnome.desktop.background color-shading-type solid
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.background primary-color '#222'

gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 9'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'

gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'

gsettings set org.gnome.gedit.preferences.editor editor-font 'Monospace 8'
gsettings set org.gnome.gedit.preferences.editor insert-spaces true
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set org.gnome.gedit.preferences.editor tabs-size 2
gsettings set org.gnome.gedit.preferences.editor use-default-font false

gsettings set org.gnome.gnome-screenshot auto-save-directory file:///home/gabi/Desktop/

gsettings set org.gnome.nautilus.icon-view default-zoom-level small
gsettings set org.gnome.nautilus.list-view default-zoom-level smallest
gsettings set org.gnome.nautilus.preferences always-use-location-entry true
gsettings set org.gnome.nautilus.preferences default-folder-viewer list-view
gsettings set org.gnome.nautilus.preferences show-hidden-files false

gsettings set org.gnome.settings-daemon.peripherals.keyboard delay 250 # key press repeat delay
gsettings set org.gnome.settings-daemon.peripherals.keyboard repeat-interval 20 # key press repeat interval
gsettings set org.gnome.settings-daemon.peripherals.mouse motion-acceleration 6 # mouse speed
gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled false
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action nothing

gsettings set org.gtk.Settings.FileChooser show-hidden false


# =========================================================================
# BASHRC
# =========================================================================

out='/home/gabi/.bashrc'

echo "


# =========================================================================
# gabi's stuff
# =========================================================================
" >> $out

echo '
check_virtualenv() {
    if [ -e .venv ]
    then
        source .venv/bin/activate
    fi
}
venv_cd() {
    builtin cd "$@" && check_virtualenv
}
check_virtualenv
alias cd="venv_cd"
' >> $out

echo "
alias ton='gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled true'
alias toff='gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled false'

alias ls='ls -lh --color=auto'
alias py='python3'

alias s='git status'
alias d='git diff'
alias c='git checkout'
" >> $out


# =========================================================================
# LAMP
# =========================================================================

sudo chown gabi:gabi -R /var/www/html/
sudo chmod 755 -R /var/www/html/


# =========================================================================
# SSH
# =========================================================================

mkdir -p /home/gabi/.ssh/
cp id_rsa* /home/gabi/.ssh/

echo '
Host 188.166.33.15
  ForwardAgent yes

Host 188.166.70.97
  ForwardAgent yes
' >> /home/gabi/.ssh/config


# =========================================================================
# VIM
# =========================================================================

mkdir -p /home/gabi/.vim/colors/
cp molokai.vim /home/gabi/.vim/colors/

echo '
set tabstop=2
set expandtab
colorscheme molokai
set t_Co=256
' >> /home/gabi/.vimrc

sudo update-alternatives --config editor


# =========================================================================
# OTHERS
# =========================================================================

echo '
.headers on
.mode column
' >> /home/gabi/.sqliterc

git config --global user.name "Gabi Nagy"
git config --global user.email gabrian.nagy@gmail.com
git config --global color.ui true

sudo locale-gen ro_RO.UTF-8


# =========================================================================
# SUBLIME TEXT
# =========================================================================

mkdir -p /home/gabi/.config/sublime-text-2/Packages/User/

echo '
[
  {"command": "expand_selection", "args": {"to": "line"}},
  {"command": "left_delete"}
]
' > '/home/gabi/.config/sublime-text-2/Packages/User/Delete line.sublime-macro'

# Preferences => Key Bindings - User
echo '
[
  { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "Packages/User/Delete line.sublime-macro"}},
  { "keys": ["ctrl+tab"], "command": "next_view" },
  { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
  { "keys": ["ctrl+f"], "command": "show_panel", "args": { "panel": "find", "in_selection": false } }
]
' > '/home/gabi/.config/sublime-text-2/Packages/User/Default (Linux).sublime-keymap'

# Preferences => Settings - User
echo '
{
  "auto_close_tags": false,
  "auto_complete": false,
  "enable_tab_scrolling": false,
  "ensure_newline_at_eof_on_save": true,
  "font_size": 9,
  "spell_check": false,
  "tab_completion": false,
  "tab_size": 2,
  "translate_tabs_to_spaces": true,
  "trim_trailing_white_space_on_save": true,
  "word_wrap": true
}
' > '/home/gabi/.config/sublime-text-2/Packages/User/Preferences.sublime-settings'


# =========================================================================
# FSTAB
# =========================================================================

# sudo mkdir /home/saved/
# sudo mount -t auto -v /dev/sda6 /home/saved/

# uuid=`sudo blkid -o value -s UUID /dev/sda6`
# sudo echo "
# UUID=$uuid    /home/saved/    ext4    defaults    0    2" >> /etc/fstab

# ln -s /home/saved/ /home/gabi/Desktop/saved


# =========================================================================
# MANUAL
# =========================================================================

# * gconf-editor: apps => guake => keybindings => global => show_die to '<Control>space'
# * add guake to startup applications
# * guake preferences i.e. height, transparency, shortcuts
