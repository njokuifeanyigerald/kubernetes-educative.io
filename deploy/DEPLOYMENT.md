# Deployment Strategies#
Let’s look into a bit of detail of both Recreate and RollingUpdate strategies.

## Recreate Strategy#
The Recreate strategy is much better suited for our single-replica database. We should have set up the native database replication (not the same as Kubernetes ReplicaSet object), but, that is out of the scope of this chapter.

If we’re running the database as a single replica, we must have mounted a network drive volume. That would allow us to avoid data loss when updating it or in case of a failure. Since most databases (MongoDB included) cannot have multiple instances writing to the same data files, killing the old release before creating a new one is a good strategy when replication is absent. We’ll apply it later.

## RollingUpdate Strategy#
The RollingUpdate strategy is the default type, for a good reason. It allows us to deploy new releases without downtime. It creates a new ReplicaSet with zero replicas and, depending on other parameters, increases the replicas of the new one, and decreases those from the old one. The process is finished when the replicas of the new ReplicaSet entirely replace those from the old one.

When RollingUpdate is the strategy of choice, it can be fine-tuned with the maxSurge and maxUnavailable fields. The former defines the maximum number of Pods that can exceed the desired number (set using replicas). It can be set to an absolute number (e.g., 2) or a percentage (e.g., 35%). The total number of Pods will never exceed the desired number (set using replicas) and the maxSurge combined. The default value is 25%.

maxUnavailable defines the maximum number of Pods that are not operational. If, for example, the number of replicas is set to 15 and this field is set to 4, the minimum number of Pods that would run at any given moment would be 11. Just as the maxSurge field, this one also defaults to 25%. If this field is not specified, there will always be at least 75% of the desired Pods.

In most cases, the default values of the Deployment specific fields are a good option. We changed the default settings only as a way to demonstrate better all the options we can use. We’ll remove them from most of the Deployment definitions that follow.

# The Template#
The template is the same PodTemplate we used before. A best practice is to be explicit with image tags like we did when we set mongo:3.3. However, that might not always be the best strategy with the images we’re building. Given we employ right practices, we can rely on latest tags being stable. Even if we discover they’re not, we can remedy that quickly by creating a new latest tag. However, We cannot expect the same from third-party images. They must always be tagged to a specific version.