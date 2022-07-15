# Source: https://gist.github.com/f96aaf28940529b2e88c901c29faebe1

######################
# Create The Cluster #
######################

# Make sure that you're using eksctl v0.1.5+.

# Follow the instructions from https://github.com/weaveworks/eksctl to intall eksctl.

export AWS_ACCESS_KEY_ID=[...] # Replace [...] with AWS access key ID

export AWS_SECRET_ACCESS_KEY=[...] # Replace [...] with AWS secret access key

export AWS_DEFAULT_REGION=us-west-2

export NAME=devops25

mkdir -p cluster

eksctl create cluster \
    -n $NAME \
    -r $AWS_DEFAULT_REGION \
    --kubeconfig cluster/kubecfg-eks \
    --node-type t2.small \
    --nodes-max 9 \
    --nodes-min 3 \
    --asg-access \
    --managed

export KUBECONFIG=$PWD/cluster/kubecfg-eks

##################
# Metrics Server #
##################

kubectl create namespace metrics

helm install metrics-server \
    stable/metrics-server \
    --version 2.0.2 \
    --namespace metrics

kubectl -n metrics \
    rollout status \
    deployment metrics-server

#######################
# Destroy the cluster #
#######################

IAM_ROLE=$(aws iam list-roles \
    | jq -r ".Roles[] \
    | select(.RoleName \
    | startswith(\"eksctl-$NAME-nodegroup\")) \
    .RoleName")

echo $IAM_ROLE

aws iam delete-role-policy \
    --role-name $IAM_ROLE \
    --policy-name $NAME-AutoScaling

eksctl delete cluster -n $NAME