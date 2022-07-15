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

#######################
# Destroy the cluster #
#######################

gcloud container clusters \
    delete devops25 \
    --region $REGION \
    --quiet