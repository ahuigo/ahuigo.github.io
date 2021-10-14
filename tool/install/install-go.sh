sudo apt-get update
sudo apt-get -y upgrade

v=1.15.15
wget https://dl.google.com/go/go$v.linux-amd64.tar.gz
mkdir -p gotmp && tar -xvf go$v.linux-amd64.tar.gz -C gotmp
sudo mv gotmp/go /usr/local/
rmdir gotmp

cat <<MM >>~/.zshrc
export GOROOT=/usr/local/go 
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
MM
