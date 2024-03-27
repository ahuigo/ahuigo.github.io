# install source
sudo apt update && sudo apt upgrade


sudo apt install wget build-essential libreadline-gplv2-dev libncursesw5-dev 
sudo apt install libssl-dev libsqlite3-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev

sudo apt-get build-dep tk-dev
sudo apt-get install  tk-dev 

wget https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz 
tar xzf Python-3.10.12.tgz
cd Python-3.10.12 
./configure --enable-optimizations 
make altinstall
python3.10 -V

# install ppa
## ppa1
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
apt list | grep python3.10
sudo apt-get install python3.10
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
sudo update-alternatives --config python3

## ppa2
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.10
