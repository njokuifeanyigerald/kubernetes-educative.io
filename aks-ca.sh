# Source: https://gist.github.com/473ae1856998bdbe9a8adc9ccf63b545

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

rm -f $PWD/cluster/kubecfg-aks

az aks create \
    --resource-group $NAME-group \
    --name $NAME-cluster \
    --node-count 3 \
    --node-vm-size $VM_SIZE \
    --generate-ssh-keys

az aks get-credentials \
    --resource-group devops25-group \
    --name devops25-cluster \
    -f cluster/kubecfg-aks

export KUBECONFIG=$PWD/cluster/kubecfg-aks

#######################
# Destroy the cluster #
#######################

az group delete \
    --name devops25-group \
    --yes