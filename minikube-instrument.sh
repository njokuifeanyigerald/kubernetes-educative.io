######################
# Create The Cluster #
######################

# Tested with minikube v1.6.1

minikube start \
    --vm-driver virtualbox \
    --cpus 2 \
    --memory 3072

###############################
# Install Ingress and Storage #
###############################

minikube addons enable ingress

minikube addons enable storage-provisioner

minikube addons enable default-storageclass

##################
# Metrics Server #
##################

minikube addons enable metrics-server

kubectl -n kube-system \
    rollout status \
    deployment metrics-server

##################
# Get Cluster IP #
##################

export LB_IP=$(minikube ip)

############################
# Install Prometheus Chart #
############################

PROM_ADDR=mon.$LB_IP.nip.io

AM_ADDR=alertmanager.$LB_IP.nip.io

helm repo update

kubectl create namespace metrics

helm install prometheus \
    stable/prometheus \
    --namespace metrics \
    --version 9.5.2 \
    --set server.ingress.hosts={$PROM_ADDR} \
    --set alertmanager.ingress.hosts={$AM_ADDR} \
    -f mon/prom-values.yml

kubectl -n metrics \
    rollout status \
    deploy prometheus-server
    
#######################
# Destroy the cluster #
#######################

minikube delete