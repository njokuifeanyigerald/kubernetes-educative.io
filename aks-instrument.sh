# Source: https://gist.github.com/94562339e570f05eaf9d76f57ce9f527

######################
# Create The Cluster #
######################

az login

az provider register -n Microsoft.Network

az provider register -n Microsoft.Storage

az provider register -n Microsoft.Compute

az provider register -n Microsoft.ContainerService

az group create \
    --name devops25-group \
    --location eastus

export VM_SIZE=Standard_B2s

export NAME=devops25

az aks create \
    --resource-group $NAME-group \
    --name $NAME-cluster \
    --node-count 3 \
    --node-vm-size $VM_SIZE \
    --generate-ssh-keys

rm -f $PWD/cluster/kubecfg-aks

az aks get-credentials \
    --resource-group devops25-group \
    --name devops25-cluster \
    -f cluster/kubecfg-aks

export KUBECONFIG=$PWD/cluster/kubecfg-aks

###################
# Install Ingress #
###################

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/provider/cloud-generic.yaml

##################
# Get Cluster IP #
##################

LB_IP=$(kubectl -n ingress-nginx \
    get svc ingress-nginx \
    -o jsonpath="{.status.loadBalancer.ingress[0].ip}")

echo $LB_IP

# Repeat the `export` command if the output is empty

############################
# Install Prometheus Chart #
############################

PROM_ADDR=mon.$LB_IP.nip.io

AM_ADDR=alertmanager.$LB_IP.nip.io

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

az group delete \
    --name devops25-group \
    --yes
