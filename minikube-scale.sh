# Create The Cluster #
######################

# Make sure that your minikube version is v0.25 or higher

minikube start \
    --vm-driver virtualbox \
    --cpus 2 \
    --memory 2048

###################
# Install Storage #
###################

minikube addons enable storage-provisioner

minikube addons enable default-storageclass

#######################
# Destroy the cluster #
#######################

minikube delete