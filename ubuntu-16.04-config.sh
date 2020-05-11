#!/bin/bash


# =========================================================================
# Install packages
# =========================================================================

packages="
audacious
audacity
build-essential
gimp
git
guake
imagemagick
inkscape
lamp-server^
nodejs
npm
python-virtualenv
python3-dev
sqlite3
vim
virtualbox
virtualbox-guest-additions-iso
vlc
"
sudo apt-get update
sudo apt-get install $packages


# =========================================================================
# Desktop settings
# =========================================================================

gsettings set com.canonical.desktop.interface scrollbar-mode normal # display normal scrollbars instead of overlay

gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2 # enable workspaces

gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ disable-show-desktop true # hide 'Show desktop' icon from Alt-Tab
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 32 # launcher icon size
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ launcher-hide-mode 1 # auto hide launcher
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ edge-responsiveness 4 # launcher show sensitivity

gsettings set org.gnome.desktop.background color-shading-type solid
gsettings set org.gnome.desktop.background picture-options 'none'
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.background primary-color '#222'

# gsettings set org.gnome.desktop.interface document-font-name 'Sans 9'
# gsettings set org.gnome.desktop.interface font-name 'Ubuntu 9'
# gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'

gsettings set org.gnome.desktop.privacy remember-recent-files false
gsettings set org.gnome.desktop.screensaver lock-enabled false
# gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'

# gsettings set org.gnome.gedit.preferences.editor use-default-font false
# gsettings set org.gnome.gedit.preferences.editor editor-font 'Monospace 8'
gsettings set org.gnome.gedit.preferences.editor insert-spaces true
gsettings set org.gnome.gedit.preferences.editor scheme oblivion
gsettings set org.gnome.gedit.preferences.editor tabs-size 4

gsettings set org.gnome.gnome-screenshot auto-save-directory file:///home/$USER/Desktop/

gsettings set org.gnome.nautilus.preferences always-use-location-entry true
gsettings set org.gnome.nautilus.preferences default-folder-viewer list-view
gsettings set org.gnome.nautilus.icon-view default-zoom-level small
gsettings set org.gnome.nautilus.list-view default-zoom-level smallest
# gsettings set org.gnome.nautilus.preferences show-hidden-files false

gsettings set org.gnome.desktop.peripherals.keyboard delay 250 # key press repeat delay
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 20 # key press repeat interval
gsettings set org.gnome.desktop.peripherals.mouse speed 0.5 # mouse speed
gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled # disable touchpad
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action nothing


# =========================================================================
# Bash
# =========================================================================

echo "



# =========================================================================
# $USER's stuff
# =========================================================================

function cd {
    builtin cd \"\$@\"

    if [ -d venv ]
    then
        source venv/bin/activate
    fi

    if [ -f 'Pipfile' ]
    then
        pipenv shell
    fi
}


alias ls='ls -lh --color=auto'
alias py='python3'


alias s='git status'
alias d='git diff --minimal'
alias c='git checkout'
" >> /home/$USER/.bashrc
source ~/.bashrc


# =========================================================================
# Vim
# =========================================================================

mkdir -p /home/$USER/.vim/colors/
wget -P /home/$USER/.vim/colors/ https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim

echo "
set expandtab
set tabstop=4
set shiftwidth=4
syntax on
colorscheme molokai
set t_Co=256
" >> /home/$USER/.vimrc

sudo update-alternatives --config editor


# =========================================================================
# Git
# =========================================================================

git config --global user.name "Gabi Nagy"
git config --global user.email ???????
git config --global color.ui true


# =========================================================================
# SSH
# =========================================================================

mkdir -p /home/$USER/.ssh/
echo "
Host example.com
    ForwardAgent yes
" >> /home/$USER/.ssh/config


# =========================================================================
# /var/www/html
# =========================================================================

sudo chown gabi:gabi -R /var/www/html/
sudo chmod 755 -R /var/www/html/


# =========================================================================
# Others
# =========================================================================

sudo locale-gen ro_RO.UTF-8

echo "
.headers on
.mode column
" >> /home/$USER/.sqliterc

mkdir -p /home/$USER/.config/autostart/
echo "
[Desktop Entry]
Type=Application
Exec=guake
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=guake
Name=guake
Comment[en_US]=
Comment=
" > /home/$USER/.config/autostart/guake.desktop

gconftool --set /apps/guake/keybindings/global/show_hide "<Control>space" -t string
gconftool --set /apps/guake/keybindings/local/new_tab "<Primary><Shift>n" -t string
gconftool --set /apps/guake/keybindings/local/next_tab "<Primary><Shift>Right" -t string
gconftool --set /apps/guake/keybindings/local/previous_tab "<Primary><Shift>Left" -t string

# /etc/fstab
sudo blkid
UUID={{ UUID }}    /media/saved    ext4    defaults    0    2


# =========================================================================
# Bash show Git branch
# =========================================================================

# add this to your ~/.bashrc file
get_git_branch() {
    git branch 2>/dev/null | grep '*' | tr -d '* ' | sed 's/^/ (/' | sed 's/$/) /';
}

PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "                                  # default
PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$(get_git_branch)\$ "                # show branch
PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\e[32m\$(get_git_branch)\e[39m\$ "    # show branch, colored
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"


# =========================================================================
# Sublime Text 3
# =========================================================================

# make Sublime the default application for text files
echo '
application/x-perl=sublime_text.desktop
text/plain=sublime_text.desktop
text/x-chdr=sublime_text.desktop
text/x-csrc=sublime_text.desktop
text/x-dtd=sublime_text.desktop
text/x-java=sublime_text.desktop
text/mathml=sublime_text.desktop
text/x-python=sublime_text.desktop
text/x-sql=sublime_text.desktop
' >> /home/$USER/.local/share/applications/mimeapps.list

mkdir -p /home/$USER/.config/sublime-text-3/Packages/User/

echo '
[
    {"command": "expand_selection", "args": {"to": "line"}},
    {"command": "left_delete"}
]
' > /home/$USER/.config/sublime-text-3/Packages/User/DeleteLine.sublime-macro

# Preferences => Key Bindings - User
echo '
[
    { "keys": ["ctrl+d"], "command": "run_macro_file", "args": {"file": "Packages/User/DeleteLine.sublime-macro"}},
    { "keys": ["ctrl+tab"], "command": "next_view" },
    { "keys": ["ctrl+shift+tab"], "command": "prev_view" },
    { "keys": ["ctrl+f"], "command": "show_panel", "args": { "panel": "find", "in_selection": false } }
]
' > /home/$USER/.config/sublime-text-3/Packages/User/Default\ \(Linux\).sublime-keymap

# Preferences => Settings - User
echo '
{
    "auto_close_tags": false,
    "auto_complete": false,
    "color_scheme": "Packages/Color Scheme - Default/Monokai.tmTheme",
    "enable_tab_scrolling": false,
    "ensure_newline_at_eof_on_save": true,
    "font_size": 13,
    "spell_check": false,
    "tab_completion": false,
    "tab_size": 4,
    "theme": "Adaptive.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "word_wrap": true,
    "show_definitions": false
}
' > /home/$USER/.config/sublime-text-3/Packages/User/Preferences.sublime-settings