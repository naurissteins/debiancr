#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Archcraftify your Debian Installation
##
## It is advised that you install this on a fresh installation of Debian 12 Desktop
## Created on : Debian 12 x86_64

## ANSI colors
RED="$(printf '\033[31m')"      GREEN="$(printf '\033[32m')"
ORANGE="$(printf '\033[33m')"   BLUE="$(printf '\033[34m')"
MAGENTA="$(printf '\033[35m')"  CYAN="$(printf '\033[36m')"
WHITE="$(printf '\033[37m')"    BLACK="$(printf '\033[30m')"

## Reset terminal colors
reset_color() {
	tput sgr0   # reset attributes
	tput op     # reset color
    return
}

## Script termination
exit_on_signal_SIGINT() {
    echo -e ${RED}"\n[!] Script interrupted.\n"
	{ reset_color; exit 1; }
}

exit_on_signal_SIGTERM() {
    echo -e ${RED}"\n[!] Script terminated.\n"
	{ reset_color; exit 1; }
}

trap exit_on_signal_SIGINT SIGINT
trap exit_on_signal_SIGTERM SIGTERM

## List of packages
_dir="`pwd`"
_packages=(
		  # For lightdm
			lightdm
			lightdm-gtk-greeter
			lightdm-gtk-greeter-settings

		  # For Openbox
		  ffmpeg
		  nitrogen
		  obconf
		  openbox
		  plank
		  python3
		  tint2
		  xfce4-settings
		  xfce4-terminal
		  xmlstarlet

		  # For Bspwm
		  bspwm
		  feh
		  sxhkd
		  xsettingsd

		  # For i3wm
		  i3-wm
		  hsetroot

		  # Common tools for Openbox and Bspwm
		  dunst
		  light
		  picom
		  polybar
		  pulsemixer
		  rofi
		  xfce4-power-manager

		  # Basic applications
		  atril
		  galculator
		  geany
		  geany-plugins
		  mplayer
		  thunar
		  thunar-archive-plugin
		  thunar-media-tags-plugin
		  thunar-volman
		  viewnior

		  # CLI tools
		  htop
		  ncdu
		  nethogs
		  ranger
		  vim
		  zsh

		  # Utilities
		  acpi
		  blueman
		  ffmpegthumbnailer
		  fonts-noto-core
		  highlight
		  inotify-tools
		  iw
		  jq
		  libwebp-dev
		  libavif-dev
		  libheif-dev
		  maim
		  meld
		  mpc
		  mpd
		  ncmpcpp
		  neofetch
		  pavucontrol
		  powertop
		  qt5ct
		  qt5-style-kvantum
		  simplescreenrecorder
		  trash-cli
		  tumbler
		  wmctrl
		  wmname
		  xclip
		  xdg-user-dirs
		  xdg-user-dirs-gtk
		  xdotool
		  yad

		  # Archives
		  bzip2
		  gzip
		  lrzip
		  lz4
		  lzip
		  lzop
		  p7zip
		  tar
		  unzip
		  xarchiver
		  zip
		  zstd
			git

		  # For networkmanager_dmenu
		  gir1.2-nm-1.0
		  libnm0

		  # for Ueberzug
		  python3-attr
		  python3-docopt
		  python3-xlib

		  # for Pywal
		  python3-pip
)
_failed_to_install=()

## Banner
banner() {
	clear
    cat <<- EOF
		${RED}░█░█░█▀▄░█░█░█▀█░▀█▀░█░█░█▀▀░█▀▄░█▀█░█▀▀░▀█▀
		${RED}░█░█░█▀▄░█░█░█░█░░█░░█░█░█░░░█▀▄░█▀█░█▀▀░░█░
		${RED}░▀▀▀░▀▀░░▀▀▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀░░░░▀░${WHITE}

		${CYAN}Debiancraft  ${WHITE}: ${MAGENTA}Install Debiancraft on Debian
		${CYAN}Developed By ${WHITE}: ${MAGENTA}Aditya Shakya (@adi1090x)

		${RED}Recommended  ${WHITE}: ${GREEN}Install this on a fresh MINIMAL installation of Debian 12 ${WHITE}
	EOF
}

## Check command status
check_cmd_status() {
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to $1 '$2'"; reset_color; exit 1; }
	fi
}

## Check internet connection
check_internet() {
	{ echo -e ${BLUE}"\n[*] Checking for internet connection..."; reset_color; }
	if nc -zw1 google.com 443 &>/dev/null; then
		{ echo -e ${GREEN}"[+] Connected to internet."; reset_color; }
	else
		{ echo -e ${RED}"[-] No internet connectivity.\n[!] Connect to internet and run the script again.\n"; reset_color; exit 1; }
	fi
}

## Perform system upgrade
upgrade_system() {
	check_internet
	{ echo -e ${BLUE}"\n[*] Performing system upgrade..."; reset_color; }
	sudo apt-get update --yes
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to retrieve new lists of packages\n"; reset_color; exit 1; }
	fi
	sudo apt-get upgrade --yes
	if [[ "$?" != '0' ]]; then
		{ echo -e ${RED}"\n[!] Failed to perform an upgrade\n"; reset_color; exit 1; }
	fi
}

## Install packages
install_pkgs() {
	upgrade_system
	{ echo -e ${BLUE}"\n[*] Installing required packages..."; reset_color; }
	for _pkg in "${_packages[@]}"; do
		{ echo -e ${ORANGE}"\n[+] Installing package : $_pkg"; reset_color; }
		sudo apt-get install "$_pkg" --yes
		if [[ "$?" != '0' ]]; then
			{ echo -e ${RED}"\n[!] Failed to install package: $_pkg"; reset_color; }
			_failed_to_install+=("$_pkg")
		fi
	done

	# List failed packages
	echo
	for _failed in "${_failed_to_install[@]}"; do
		{ echo -e ${RED}"[!] Failed to install package : ${ORANGE}${_failed}"; reset_color; }
	done
	if [[ -n "${_failed_to_install}" ]]; then
		{ echo -e ${RED}"\n[!] Install these packages manually to continue, exiting...\n"; reset_color; exit 1; }
	fi
}

## Install Alacritty from source
install_alacritty_from_source() {
    { echo -e ${ORANGE}"\n[+] Installing Alacritty from source"; reset_color; }

    # Install dependencies
    sudo apt-get install -y cmake cargo libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    check_cmd_status 'install dependencies' 'for alacritty'

    # Ensure Rust is installed
    if ! command -v cargo &> /dev/null; then
        { echo -e ${ORANGE}"\n[+] Installing Rust (required for building Alacritty)"; reset_color; }
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
        check_cmd_status 'install' 'Rust'
    fi

    # Clone Alacritty repository
    if [[ -d "alacritty" ]]; then
        { echo -e ${ORANGE}"[!] Removing existing alacritty directory"; reset_color; }
        rm -rf alacritty
    fi

    git clone https://github.com/alacritty/alacritty.git
    check_cmd_status 'clone repository' 'alacritty'

    # Build Alacritty
    pushd alacritty || { echo -e ${RED}"[!] Failed to enter alacritty directory"; reset_color; exit 1; }
    cargo build --release
    check_cmd_status 'build' 'alacritty'

    # Install Alacritty
    sudo cp target/release/alacritty /usr/local/bin/
    sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
    sudo desktop-file-install extra/linux/Alacritty.desktop
    sudo update-desktop-database
    check_cmd_status 'install' 'Alacritty'

    popd
    rm -rf alacritty
    { echo -e ${GREEN}"[+] Alacritty installation completed."; reset_color; }
}

## Install extra packages
install_extra_pkgs() {
	{ echo -e ${BLUE}"[*] Installing extra packages..."; reset_color; }

	# Install pastel deb package
	{ echo -e ${ORANGE}"\n[+] Installing pastel from local package"; reset_color; }
	sudo dpkg --install "$_dir"/pkgs/pastel_*.deb
	check_cmd_status 'install' 'pastel'

	# Variables
	venv_dir="$HOME/pywal_venv"  # Directory for virtual environment
	_wal_bin="$venv_dir/bin/wal" # Path to wal binary inside virtual environment

	# Install Python venv if not already installed
	{ echo -e ${ORANGE}"\n[+] Checking for python3-venv and installing if necessary"; reset_color; }
	sudo apt install -y python3-venv

	# Create virtual environment if it doesn't exist
	if [[ ! -d "$venv_dir" ]]; then
			{ echo -e ${ORANGE}"\n[+] Creating Python virtual environment at $venv_dir"; reset_color; }
			python3 -m venv "$venv_dir"
	fi

	# Activate the virtual environment and install pywal
	{ echo -e ${ORANGE}"\n[+] Activating virtual environment and installing pywal"; reset_color; }
	source "$venv_dir/bin/activate"
	pip install pywal
	deactivate

	# Check if pywal was installed and move the wal binary to /usr/local/bin
	if [[ -e "$_wal_bin" ]]; then
			{ echo -e ${ORANGE}"\n[+] Copying wal binary to /usr/local/bin"; reset_color; }
			sudo cp --preserve=mode --force --recursive "$_wal_bin" /usr/local/bin
	else
			{ echo -e ${RED}"[!] pywal installation failed"; reset_color; }
	fi
}

## Install the files
install_files() {
	_copy_cmd='sudo cp --preserve=mode --force --recursive'
	_rootfs="$_dir/files"
	_skel='/etc/skel'
	_libdir='/usr/lib'
	_bindir='/usr/local/bin'
	_sharedir='/usr/share'

	{ echo -e ${BLUE}"\n[*] Installing required files..."; reset_color; }

	# Copy libraries
	{ echo -e ${ORANGE}"\n[+] Installing libraries..."; reset_color; }
	${_copy_cmd} --verbose "$_rootfs"/usr/lib/* "$_libdir"

	# Copy binaries and scripts
	{ echo -e ${ORANGE}"\n[+] Installing binaries and scripts..."; reset_color; }
	${_copy_cmd} --verbose "$_rootfs"/usr/local/bin/* "$_bindir"
	sudo chmod 755 "$_bindir"/*

	# Copy shared files
	{ echo -e ${ORANGE}"\n[+] Installing shared files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/usr/share/* "$_sharedir"

	# Copy config files
	{ echo -e ${ORANGE}"\n[+] Installing config files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/etc/skel/. "$_skel"

	# Copy Misc files
	{ echo -e ${ORANGE}"\n[+] Installing misc config files..."; reset_color; }
	${_copy_cmd} "$_rootfs"/etc/xdg/autostart/* /etc/xdg/autostart
	${_copy_cmd} "$_rootfs"/etc/udev/rules.d/70-backlight.rules /etc/udev/rules.d
	${_copy_cmd} "$_rootfs"/etc/X11/xorg.conf.d/02-touchpad-ttc.conf /etc/X11/xorg.conf.d
}

## Copy files in user's directory
copy_files_in_home() {
	_cp_cmd='cp --preserve=mode --force --recursive'
	_skel_dir='/etc/skel'
	_bnum=`echo $RANDOM`

	{ echo -e ${BLUE}"\n[*] Copying config files in $HOME directory..."; reset_color; }
	_cfiles=(
		  '.cache'
		  '.config'
		  '.dmrc'
		  '.face'
		  '.fehbg'
		  '.gtkrc-2.0'
		  '.hushlogin'
		  '.icons'
		  '.mpd'
		  '.ncmpcpp'
		  '.oh-my-zsh'
		  '.vimrc'
		  '.vim_runtime'
		  '.zshrc'
		  Music
		  Pictures
		  )

	for _file in "${_cfiles[@]}"; do
		if [[ -e "$HOME/$_file" ]]; then
			{ echo -e ${MAGENTA}"\n[*] Backing-up : $HOME/$_file"; reset_color; }
			mv "$HOME/$_file" "$HOME/${_file}_backup_${_bnum}"
			{ echo -e ${CYAN}"[*] Backup stored in : $HOME/${_file}_backup_${_bnum}"; reset_color; }
		fi
		{ echo -e ${ORANGE}"[+] Copying $_skel_dir/$_file in $HOME directory"; reset_color; }
		${_cp_cmd} "$_skel_dir/$_file" "$HOME"
	done
}

## Copy files in root directory
copy_files_in_root() {
	_cp_cmd='sudo cp --preserve=mode --force --recursive'
	_skel_dir='/etc/skel'
	_bnum=`echo $RANDOM`

	{ echo -e ${BLUE}"\n[*] Copying config files in /root directory..."; reset_color; }
	_cfiles=(
		  '.config'
		  '.gtkrc-2.0'
		  '.oh-my-zsh'
		  '.vimrc'
		  '.vim_runtime'
		  '.zshrc'
		  )

	for _file in "${_cfiles[@]}"; do
		if [[ -e "/root/$_file" ]]; then
			{ echo -e ${MAGENTA}"\n[*] Backing-up : /root/$_file"; reset_color; }
			sudo mv "/root/$_file" "/root/${_file}_backup_${_bnum}"
			{ echo -e ${CYAN}"[*] Backup stored in : /root/${_file}_backup_${_bnum}"; reset_color; }
		fi
		{ echo -e ${ORANGE}"[+] Copying $_skel_dir/$_file in /root directory"; reset_color; }
		${_cp_cmd} "$_skel_dir/$_file" /root
	done
}

## Manage services
manage_services() {
	{ echo -e ${BLUE}"\n[*] Managing services..."; reset_color; }

	# Enable lightdm service
	{ echo -e ${ORANGE}"\n[+] Enabling lightdm service..."; reset_color; }
	if ! systemctl is-enabled lightdm.service &>/dev/null; then
			sudo systemctl enable lightdm.service
			check_cmd_status 'enable' 'lightdm service'
	fi

	# Enable betterlockscreen service
	{ echo -e ${ORANGE}"\n[+] Enabling betterlockscreen service..."; reset_color; }
	if ! systemctl is-enabled betterlockscreen@$USER.service &>/dev/null; then
		sudo systemctl enable betterlockscreen@$USER.service
		check_cmd_status 'enable' 'lockscreen service'
	fi
}

## Finalization
finalization() {
	{ echo -e ${BLUE}"\n[*] Adding $USER to 'video' group..."; reset_color; }
	sudo usermod -a -G video "$USER"

	{ echo -e ${BLUE}"\n[*] Changing ${USER}'s shell to zsh..."; reset_color; }
	sudo chsh -s /bin/zsh "$USER"

	{ echo -e ${BLUE}"\n[*] Cleaning up..."; reset_color; }

	# Remove all unused packages
	{ echo -e ${ORANGE}"\n[-] Removing unused packages..."; reset_color; }
	sudo apt-get autoremove --yes

	# Erase downloaded archive files
	{ echo -e ${ORANGE}"\n[-] Removing downloaded package archives..."; reset_color; }
	sudo apt-get clean --yes

	# Completed
	{ echo -e ${GREEN}"\n[*] Installation Completed, You may now reboot your computer.\n"; reset_color; }
}

## Main ------------
banner
install_pkgs
install_alacritty_from_source
install_extra_pkgs
install_files
copy_files_in_home
copy_files_in_root
manage_services
finalization
