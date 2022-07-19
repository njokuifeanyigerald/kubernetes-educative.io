####################
# Create A Cluster #
####################

# Open Docker Preferences, select the Kubernetes tab, and select the "Enable Kubernetes" checkbox

# Open Docker Preferences, select the Advanced tab, set CPUs to 2, and Memory to 10.0

###################
# Install Ingress #
###################

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/mandatory.yaml

kubectl apply \
    -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/1cd17cd12c98563407ad03812aebac46ca4442f2/deploy/provider/cloud-generic.yaml

##################
# Metrics Server #
##################

kubectl create namespace metrics

helm install metrics-server \
    stable/metrics-server \
    --namespace metrics \
    --set args={"--kubelet-insecure-tls=true"}

##################
# Get Cluster IP #
##################

LB_IP=[...] # Replace with the IP of the cluster usually obtained through `ifconfig`

#######################
# Destroy the cluster #
#######################

# Reset Kubernetes cluster