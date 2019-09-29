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

# create samba account
echo "Create a samba account:"
echo "new user: $USER"
read -sp "new password: " SAMBAPWD

# update && upgrade
CURRENT_DIRECTORY=$PWD
sudo apt update && sudo apt upgrade -y

# configuration for static ip

# install docker
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable test edge"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo usermod -aG docker $USER
sudo service docker start

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

# install openssh-server
sudo apt install -y openssh-server
#sudo sed -i -e "s/#Port 22/Port 8080/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config
sudo sed -i -e "s/#PasswordAuthentication yes/PasswordAuthentication no/g" /etc/ssh/sshd_config
if [[ ! -e ~/.ssh ]]; then
    mkdir ~/.ssh
fi
if [[ ! -e ~/.ssh/authorized_keys ]]; then
    sudo chmod 700 ~/.ssh
    sudo touch ~/.ssh/authorized_keys
    sudo chmod 600 ~/.ssh/authorized_keys
fi
sudo service ssh restart

# install tmux
sudo apt install -y tmux

# install samba
sudo docker pull dperson/samba
sudo mkdir /srv/samba
sudo chown 100 /srv/samba
sudo docker run --restart=always --name samba -p 139:139 -p 445:445 -v /srv/samba:/pub -d dperson/samba -p -u "$USER;$SAMBAPWD" -s "pub;/pub;yes;no;no;$USER"

<< COMMENTOUT
# install nextcloud
sudo docker pull nextcloud
sudo mkdir /srv/nextcloud
sudo docker run --restart=always --name nextcloud -p 80:80 -v /srv/nextcloud:/var/www/html -d nextcloud
COMMENTOUT

# set firewall
#ls /etc/ufw/applications.d/
#sudo ufw status
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 139 # for samba
sudo ufw allow 445 # for samba
sudo ufw allow 80  # for nextvloud
#sudo ufw allow cups # for printer in lan
sudo ufw reload

# install chrome
curl https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
sudo apt update
sudo apt install -y google-chrome-stable

# install visual studio code
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt install -y apt-transport-https
sudo apt update
sudo apt install code

# install libreoffice
sudo snap install libreoffice

# autoremove
sudo apt autoremove -y

# reboot
sudo reboot
