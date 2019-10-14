#!/bin/sh

# Script Arguments:
# $1 - MTU
# $2 - allinone IP address
# $3 - allinone short name
MTU=$1
ALLINONE_IP=$2
ALLINONE_NAME=$3

BASE_PACKAGES="git bridge-utils ebtables python-pip python-dev build-essential ntp openvswitch-switch jq vlan python3-dev"
DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy $BASE_PACKAGES
echo export LC_ALL=en_US.UTF-8 >> ~/.bash_profile
echo export LANG=en_US.UTF-8 >> ~/.bash_profile
echo source ~/.bashrc >> ~/.bash_profile

# FIXME(mestery): Remove once Vagrant boxes allow apt-get to work again
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get install -y git

# Enable history and command line editing
cat << DEVSTACKEOF >> .bashrc

# Enable history and command line editing
set -o vi
VISUAL=vim
DEVSTACKEOF

# Add vim plug-ins to make Python development easier

cat << DEVSTACKEOF > .vimrc
set tabstop=8
set expandtab
set shiftwidth=4
set softtabstop=4
set textwidth=79
syntax on
filetype on
filetype plugin indent on
set autoindent
set nu
set ruler
execute pathogen#infect()
autocmd FileType python set omnifunc=pythoncomplete#Complete
let g:syntastic_auto_loc_list=1
let g:syntastic_python_checkers=['flake8']
let g:syntastic_quiet_messages = {"regex": "D10*"}
set background=dark
color gruvbox
DEVSTACKEOF

mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
sudo pip install flake8
git clone https://github.com/scrooloose/syntastic.git .vim/bundle/syntastic
git clone https://github.com/tmhedberg/SimpylFold .vim/bundle/SimpylFold
git clone https://github.com/Raimondi/delimitMate .vim/bundle/delimitMate
git clone https://github.com/morhetz/gruvbox .vim/bundle/gruvbox
git clone https://github.com/tpope/vim-fugitive .vim/bundle/vim-fugitive

# Prepare for devstack

sudo chown vagrant:vagrant /opt
sudo chown vagrant:vagrant /opt/stack
git clone https://git.openstack.org/openstack-dev/devstack.git

# If available, use repositories on host to facilitate testing local changes.
# Vagrant requires that shared folders exist on the host, so additionally
# check for the ".git" directory in case the parent exists but lacks
# repository contents.

if [ ! -d "/opt/stack/neutron/.git" ]; then
    git clone https://git.openstack.org/openstack/neutron.git
fi

if [ ! -d "/opt/stack/nova/.git" ]; then
    git clone http://git.openstack.org/openstack/nova.git
fi

# We need swap space to do any sort of scale testing with the Vagrant config.
# Without this, we quickly run out of RAM and the kernel starts whacking things.
sudo rm -f /swapfile1
sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=8388608
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo mkswap /swapfile1
sudo swapon /swapfile1
