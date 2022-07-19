# Source: https://gist.github.com/fc3c01d066af3a83472ce24dfaaf8131

######################
# Create The Cluster #
######################

gcloud auth login

REGION=us-east1

MACHINE_TYPE=n1-standard-1

gcloud container clusters \
    create devops25 \
    --region $REGION \
    --machine-type $MACHINE_TYPE \
    --enable-autoscaling \
    --num-nodes 1 \
    --max-nodes 3 \
    --min-nodes 1

kubectl create clusterrolebinding \
    cluster-admin-binding \
    --clusterrole cluster-admin \
    --user $(gcloud config get-value account)

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

export LB_IP=$(kubectl -n ingress-nginx \
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

gcloud container clusters \
    delete devops25 \
    --region $REGION \
    --quiet
