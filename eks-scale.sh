# Source: https://gist.github.com/281a6386150b28e8d3fdc819918e1749

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

#######################
# Destroy the cluster #
#######################

eksctl delete cluster -n devops25