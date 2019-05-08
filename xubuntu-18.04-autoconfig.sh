#!/bin/bash


# =========================================================================
# Install packages
# =========================================================================

sudo true    # ask for sudo password

packages="
audacious
audacity
build-essential
chromium-browser
dconf-cli
gimp
git
guake
imagemagick
inkscape
lamp-server^
nodejs
npm
postgresql-10
postgresql-server-dev-10
python-virtualenv
python3
python3-dev
redis-server
redis-tools
sqlite3
vim
virtualenv
vlc
"
sudo apt-get update
sudo apt-get install $packages

# Install skypeforlinux, sublime-text


# =========================================================================
# Desktop settings
# =========================================================================

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-enabled -n -t bool -s false    # Display power management => Disable

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -n -t int -s 3                 # When laptop lid is closed => Lock screen
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -n -t int -s 3            # When laptop lid is closed => Lock screen
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/logind-handle-lid-switch -n -t bool -s false    # When laptop lid is closed => Lock screen

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-on-ac -n -t int -s 9         # Display => Brightness reduction => Never
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/brightness-on-battery -n -t int -s 9    # Display => Brightness reduction => Never

xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/critical-power-action -n -t int -s 1    # On critical battery power => Suspend

xfconf-query -c xfwm4 -p /general/workspace_count -n -t int -s 2

xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-filesystem -n -t bool -s false
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-home -n -t bool -s true
xfconf-query -c xfce4-desktop -p /desktop-icons/file-icons/show-removable -n -t bool -s true

# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/image-style -n -t int -s 0    # Background => Style => None
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor1/workspace0/image-style -n -t int -s 0    # Background => Style => None
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/color1 -n -t int -t int -t int -t int -s 8738 -s 8738 -s 8738 -s 65535    # Background => Color => #222222

xfconf-query -c thunar -p /default-view -n -t string -s ThunarCompactView

xfconf-query -c keyboards -p /Default/KeyRepeat/Delay -n -t int -s 250
xfconf-query -c keyboards -p /Default/KeyRepeat/Rate -n -t int -s 50

xfconf-query -c pointers -p /Logitech_M310/Acceleration -n -t string -s 10,000000
xfconf-query -c pointers -p /Logitech_M310/Threshold -n -t int -s 1

xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -n -t string -s xfce4-popup-whiskermenu
xfconf-query -c xfce4-keyboard-shortcuts -p "/xfwm4/custom/<Primary><Super>d" -n -t string -s show_desktop_key


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


# =========================================================================
# Guake
# =========================================================================

echo "
[apps/guake/general]
prompt-on-quit=true
window-height=100
mouse-display=true
window-width=100
max-tab-name-length=100
window-losefocus=false
infinite-history=true
history-size=1000
open-tab-cwd=false
window-tabbar=true
window-halignment=0
quick-open-command-line='gedit %(file_path)s'
compat-delete='delete-sequence'
scroll-keystroke=true
abbreviate-tab-names=false
display-n=0
use-default-font=true
use-trayicon=false
use-scrollbar=true
window-refocus=false
use-popup=false

[apps/guake/keybindings/local]
toggle-transparency='disabled'
decrease-transparency='disabled'
new-tab='<Primary><Shift>n'
previous-tab='<Primary><Shift>Left'
increase-transparency='disabled'
next-tab='<Primary><Shift>Right'
decrease-height='disabled'
increase-height='disabled'

[apps/guake/keybindings/global]
show-hide='<Primary>space'

[apps/guake/style/background]
transparency=100

[apps/guake/style/font]
allow-bold=true
palette='#1C1C1D1D1919:#D0D01B1B2424:#A7A7D3D32C2C:#D8D8CFCF6767:#6161B8B8D0D0:#69695A5ABBBB:#D5D538386464:#FEFEFFFFFEFE:#1C1C1D1D1919:#D0D01B1B2424:#A7A7D3D32C2C:#D8D8CFCF6767:#6161B8B8D0D0:#69695A5ABBBB:#D5D538386464:#FEFEFFFFFEFE:#F6F6F5F5EEEE:#232325252626'
palette-name='Monokai'
" | dconf load /

mkdir -p /home/$USER/.config/autostart/
cp /usr/share/applications/guake.desktop /home/$USER/.config/autostart/


# =========================================================================
# Sublime Text
# =========================================================================

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
    "font_size": 10,
    "mini_diff": false,
    "show_definitions": false,
    "show_git_status": false,
    "spell_check": false,
    "tab_completion": false,
    "tab_size": 4,
    "theme": "Adaptive.sublime-theme",
    "translate_tabs_to_spaces": true,
    "trim_trailing_white_space_on_save": true,
    "word_wrap": true
}
' > /home/$USER/.config/sublime-text-3/Packages/User/Preferences.sublime-settings


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
git config --global user.email gabrian.nagy@gmail.com
git config --global color.ui true


# =========================================================================
# /var/www/html
# =========================================================================

sudo chown $USER:$USER -R /var/www/html/
sudo chmod 755 -R /var/www/html/


# =========================================================================
# SQLite
# =========================================================================

echo "
.headers on
.mode column
" >> /home/$USER/.sqliterc


# =========================================================================
# Others
# =========================================================================

sudo locale-gen ro_RO.UTF-8

rm -rf /home/$USER/Templates/*


# =========================================================================
# Default applications
# =========================================================================

echo "
[Default Applications]
text/calendar=xfcalendar.desktop;sublime_text.desktop;
text/comma-separated-values=libreoffice-calc.desktop;sublime_text.desktop;
text/csv=libreoffice-calc.desktop;sublime_text.desktop;
text/english=sublime_text.desktop;
text/google-video-pointer=org.xfce.Parole.desktop;vlc.desktop;sublime_text.desktop;
text/html=google-chrome.desktop;sublime_text.desktop;
text/mathml=libreoffice-math.desktop;sublime_text.desktop;
text/plain=sublime_text.desktop;mousepad.desktop;
text/rtf=libreoffice-writer.desktop;sublime_text.desktop;
text/spreadsheet=libreoffice-calc.desktop;sublime_text.desktop;
text/tab-separated-values=libreoffice-calc.desktop;sublime_text.desktop;
text/x-apport=apport-gtk.desktop;sublime_text.desktop;
text/x-apt-sources-list=software-properties-gtk.desktop;sublime_text.desktop;
text/x-c=sublime_text.desktop;
text/x-c++=sublime_text.desktop;
text/x-c++hdr=sublime_text.desktop;
text/x-c++src=sublime_text.desktop;
text/x-chdr=sublime_text.desktop;
text/x-comma-separated-values=libreoffice-calc.desktop;sublime_text.desktop;
text/x-csrc=sublime_text.desktop;
text/x-csv=libreoffice-calc.desktop;sublime_text.desktop;
text/x-google-video-pointer=org.xfce.Parole.desktop;vlc.desktop;sublime_text.desktop;
text/x-java=sublime_text.desktop;
text/x-makefile=sublime_text.desktop;
text/x-moc=sublime_text.desktop;
text/x-pascal=sublime_text.desktop;
text/x-tcl=sublime_text.desktop;
text/x-tex=sublime_text.desktop;
text/xml=google-chrome.desktop;sublime_text.desktop;

application/x-shellscript=sublime_text.desktop;

application/x-flash-video=vlc.desktop;
text/google-video-pointer=vlc.desktop;
text/x-google-video-pointer=vlc.desktop;
video/3gp=vlc.desktop;
video/3gpp=vlc.desktop;
video/3gpp2=vlc.desktop;
video/avi=vlc.desktop;
video/divx=vlc.desktop;
video/dv=vlc.desktop;
video/fli=vlc.desktop;
video/flv=vlc.desktop;
video/mp2t=vlc.desktop;
video/mp4=vlc.desktop;
video/mp4v-es=vlc.desktop;
video/mpeg=vlc.desktop;
video/mpeg-system=vlc.desktop;
video/msvideo=vlc.desktop;
video/ogg=vlc.desktop;
video/quicktime=vlc.desktop;
video/vivo=vlc.desktop;
video/vnd.divx=vlc.desktop;
video/vnd.mpegurl=vlc.desktop;
video/vnd.rn-realvideo=vlc.desktop;
video/vnd.vivo=vlc.desktop;
video/webm=vlc.desktop;
video/x-anim=vlc.desktop;
video/x-avi=vlc.desktop;
video/x-flc=vlc.desktop;
video/x-fli=vlc.desktop;
video/x-flic=vlc.desktop;
video/x-flv=vlc.desktop;
video/x-m4v=vlc.desktop;
video/x-matroska=vlc.desktop;
video/x-mpeg=vlc.desktop;
video/x-mpeg-system=vlc.desktop;
video/x-mpeg2=vlc.desktop;
video/x-ms-asf=vlc.desktop;
video/x-ms-asf-plugin=vlc.desktop;
video/x-ms-asx=vlc.desktop;
video/x-ms-wm=vlc.desktop;
video/x-ms-wmv=vlc.desktop;
video/x-ms-wmx=vlc.desktop;
video/x-ms-wvx=vlc.desktop;
video/x-msvideo=vlc.desktop;
video/x-nsv=vlc.desktop;
video/x-ogm=vlc.desktop;
video/x-ogm+ogg=vlc.desktop;
video/x-theora=vlc.desktop;
video/x-theora+ogg=vlc.desktop;
video/x-totem-stream=vlc.desktop;
x-content/video-dvd=vlc.desktop;
x-content/video-svcd=vlc.desktop;
x-content/video-vcd=vlc.desktop;

audio/3gpp=audacious.desktop;
audio/3gpp2=audacious.desktop;
audio/AMR=audacious.desktop;
audio/AMR-WB=audacious.desktop;
audio/aac=audacious.desktop;
audio/ac3=audacious.desktop;
audio/basic=audacious.desktop;
audio/dv=audacious.desktop;
audio/eac3=audacious.desktop;
audio/flac=audacious.desktop;
audio/m4a=audacious.desktop;
audio/midi=audacious.desktop;
audio/mp1=audacious.desktop;
audio/mp2=audacious.desktop;
audio/mp3=audacious.desktop;
audio/mp4=audacious.desktop;
audio/mpeg=audacious.desktop;
audio/mpegurl=audacious.desktop;
audio/mpg=audacious.desktop;
audio/ogg=audacious.desktop;
audio/opus=audacious.desktop;
audio/prs.sid=audacious.desktop;
audio/scpls=audacious.desktop;
audio/vnd.dolby.heaac.1=audacious.desktop;
audio/vnd.dolby.heaac.2=audacious.desktop;
audio/vnd.dolby.mlp=audacious.desktop;
audio/vnd.dts=audacious.desktop;
audio/vnd.dts.hd=audacious.desktop;
audio/vnd.rn-realaudio=audacious.desktop;
audio/vorbis=audacious.desktop;
audio/wav=audacious.desktop;
audio/webm=audacious.desktop;
audio/x-aac=audacious.desktop;
audio/x-adpcm=audacious.desktop;
audio/x-aiff=audacious.desktop;
audio/x-ape=audacious.desktop;
audio/x-flac=audacious.desktop;
audio/x-gsm=audacious.desktop;
audio/x-it=audacious.desktop;
audio/x-m4a=audacious.desktop;
audio/x-matroska=audacious.desktop;
audio/x-mod=audacious.desktop;
audio/x-mp1=audacious.desktop;
audio/x-mp2=audacious.desktop;
audio/x-mp3=audacious.desktop;
audio/x-mpeg=audacious.desktop;
audio/x-mpegurl=audacious.desktop;
audio/x-mpg=audacious.desktop;
audio/x-ms-asf=audacious.desktop;
audio/x-ms-asx=audacious.desktop;
audio/x-ms-wax=audacious.desktop;
audio/x-ms-wma=audacious.desktop;
audio/x-musepack=audacious.desktop;
audio/x-pn-aiff=audacious.desktop;
audio/x-pn-au=audacious.desktop;
audio/x-pn-realaudio=audacious.desktop;
audio/x-pn-realaudio-plugin=audacious.desktop;
audio/x-pn-wav=audacious.desktop;
audio/x-pn-windows-acm=audacious.desktop;
audio/x-real-audio=audacious.desktop;
audio/x-realaudio=audacious.desktop;
audio/x-s3m=audacious.desktop;
audio/x-sbc=audacious.desktop;
audio/x-scpls=audacious.desktop;
audio/x-shorten=audacious.desktop;
audio/x-speex=audacious.desktop;
audio/x-stm=audacious.desktop;
audio/x-tta=audacious.desktop;
audio/x-vorbis=audacious.desktop;
audio/x-vorbis+ogg=audacious.desktop;
audio/x-wav=audacious.desktop;
audio/x-wavpack=audacious.desktop;
audio/x-xm=audacious.desktop;
x-content/audio-cdda=audacious.desktop;
x-content/audio-player=audacious.desktop;
" >> /home/$USER/.config/mimeapps.list
