# minikube
alias drun-fx="$CLB_BASE_DIR/fx/spikes/docker/fxbld/doc-ci/drun.sh"

on-kube() {
    minikube start\
        --kubernetes-version=v1.12.0\
        --vm-driver=virtualbox\
        --cpus=2\
        --memory=4096\
        --disk-size=40g\
        --v=0
}

on-kube-local () {
    #mkdir -p $HOME/.minikube
    #mkdir -p $HOME/.kube
    #touch $HOME/.kube/config

    local MINIKUBE_WANTUPDATENOTIFICATION=false
    local MINIKUBE_WANTREPORTERRORPROMPT=false
    local MINIKUBE_HOME=$HOME
    local CHANGE_MINIKUBE_NONE_USER=true
    local KUBECONFIG=$HOME/.kube/config

    sudo -E minikube start --vm-driver=none

    # this for loop waits until kubectl can access the api server that Minikube has created
    for i in {1..150}; do # timeout for 5 minutes
       kubectl get po &> /dev/null
       if [ $? -ne 1 ]; then
          break
      fi
      sleep 2
    done

    # kubectl commands are now able to interact with Minikube cluster
    echo "minikube intitialized!"
}

run-kube-local() {
    local MINIKUBE_WANTUPDATENOTIFICATION=false
    local MINIKUBE_WANTREPORTERRORPROMPT=false
    local MINIKUBE_HOME=$HOME
    local CHANGE_MINIKUBE_NONE_USER=true
    local KUBECONFIG=$HOME/.kube/config

    sudo -E minikube "$@"
}
