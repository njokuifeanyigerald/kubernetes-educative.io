# Source: https://gist.github.com/0cef62546884f6e70474dd87b5de36c5

####################
# Create A Cluster #
####################

# Open Docker Preferences, select the Kubernetes tab, and select the "Enable Kubernetes" checkbox

# Open Docker Preferences, select the Advanced tab, set CPUs to 2, and Memory to 3.0

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

kubectl --namespace metrics \
    rollout status \
    deployment metrics-server

##################
# Get Cluster IP #
##################

LB_IP=[...] # Replace with the IP of the cluster usually obtained through `ifconfig`

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

# Reset Kubernetes cluster