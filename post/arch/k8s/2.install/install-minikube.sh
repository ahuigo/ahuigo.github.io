function installK8sMac(){
    # docker-cli 或 docker-desktop m1
    brew install docker
    brew install kubectl
    kubectl version --client #Client Version:  GitVersion:"v1.23.5"
    # brew install kubernetes-helm
    brew install minikube

}
function installK8sLinux(){
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

    # curl -LO https://storage.flutter-io.cn/minikube/releases/latest/minikube-linux-amd64
    # sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64
}

echo "install k8s... "
if [ "$(uname)" == "Darwin" ]; then
    installK8sMac
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    installK8sLinux
else
    echo "Unknown OS"
fi