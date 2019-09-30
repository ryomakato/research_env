# Make Research Enviroment with Tensorflow on Ubuntu 18.04
This repository let you make research env. with Tensorflow on Ubuntu 18.04 from Minimum Installation of Ubuntu 18.04.

## 1. Install git and clone this repository
```bash
$ sudo apt update
$ sudo apt install -y git
$ git clone https://github.com/ryomakato/research_env
```
## 2. Make Research Env.
Change dir. and bash make_env:
```bash
$ cd research_env
$ bash make_env
```
There are --gpu and --app options.
--gpu: install nvidia docker
--apps: install Chrome, VSC, and Libreoffice
```bash
$ bash make_env --gpu
$ bash make_env --app
$ bash make_env --gpu --app
```
## 3. Make Tensorflow Env.
Please note that you can make tensorflow env. any directory in this section.
```baswh
$ git clone https://github.com/ryomakato/tensorflow-cpu-env # cpu version
$ git clone https://github.com/ryomakato/tensorflow-gpu-env # gpu version
```
## 4. Build tensorflow env. with Docker and Run
First, change direcoty into tensorflow-env.
```bash
$ cd tensorflow-cpu-env # cpu version
$ cd tensorflow-gpu-env # gpu version
```
Then, build and run tensorflow env. with docker
```bash
$ sudo docker build -t tensorflow .
$ bash run_docker.sh
```
### TODO
- Static IP (bb router and ubuntu config.)
- Grobal IP (ddclient)
- wakeonlan
- samba mount place
- docker build detail with requirements.txt
- Nextcloud?
