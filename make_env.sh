#!/bin/bash

PROGNAME="$( basename $0 )"

# usage
function usage() {
  cat << EOS >&2
Usage: ${PROGNAME} [--cpu] [--gpu]
  Make research enviroment on Ubuntu18.04.

Options:
  --cpu        Normal Installation.
  --gpu        Install Nvidiadocker.
  -h, --help    Show usage.
EOS
  exit 1
}

# option
PARAM=()
for opt in "$@"; do
    case "${opt}" in
        '--cpu') CPU_OPTION=true; shift;;
        '--gpu') GPU_OPTION=true; shift;;
        '-h' | '--help') usage;;
        '--' | '-') shift; PARAM+=("$@"); break;;
        -* | *) echo "${PROGNAME}: illegal option -- '$( echo $1 | sed 's/^-*//' )'" 1>&2; exit 1;;
    esac
done

# update && upgrade
CURRENT_DIRECTORY=$PWD
sudo apt update && sudo apt upgrade -y

# install openssh-server
sudo apt install -y openssh-server
sudo sed -i -e "s/#Port 22/Port 8080/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
sudo service ssh restart

# configuration for static ip

# install samba

# install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable test edge"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER


# install nvidia-docker if you want
if [ ${GPU_OPTION:-false} == true ]; then
   # install nvidia-gpu-driver
    sudo add-apt-repository -y ppa:graphics-drivers/ppa
    sudo apt update
    apt-cache search nvidia-driver
    sudo apt-get -y install ubuntu-drivers-common
    sudo ubuntu-drivers autoinstall
    #sudo reboot
    # install nvidia-docker
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt-get update
    sudo apt-get install -y nvidia-docker2
    sudo pkill -SIGHUP dockerd
fi

# install tmux
sudo apt install -y tmux

# autoremove
sudo apt autoremove -y

# reboot
sudo reboot
