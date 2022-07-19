######################
# Create The Cluster #
######################

# Tested with minikube v1.6.1

minikube start \
    --vm-driver virtualbox \
    --cpus 2 \
    --memory 10240

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

kubectl -n kube-system rollout status deployment metrics-server

##################
# Get Cluster IP #
##################

export LB_IP=$(minikube ip)
    
#######################
# Destroy the cluster #
#######################

minikube delete