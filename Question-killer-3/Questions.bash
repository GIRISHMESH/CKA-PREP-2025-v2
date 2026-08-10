# Question 5 — Kustomize Configure HPA Autoscaler

# Solve this question on:
# the current Kubernetes cluster

#
# Background
#

# The application "api-gateway" previously used an external
# autoscaler configuration.
#
# This should now be replaced with a Kubernetes
# HorizontalPodAutoscaler (HPA).
#
# The application is deployed in:
#
#   api-gateway-staging
#   api-gateway-prod
#

#
# Kustomize configuration:
#

# /opt/course/5/api-gateway

#
# Tasks
#

# 1. Remove the ConfigMap:
#
#    horizontal-scaling-config
#
# completely from the Kustomize configuration.

#
# 2. Add a HorizontalPodAutoscaler named:
#
#    api-gateway
#
# for the Deployment:
#
#    api-gateway
#
# Configure the HPA with:
#
#    minReplicas: 2
#    maxReplicas: 4
#    average CPU utilization: 50%
#
# Use autoscaling/v2.

#
# 3. In the production overlay:
#
#    api-gateway-prod
#
# change the HPA so that:
#
#    maxReplicas: 6

#
# 4. Apply the Kustomize configuration to:
#
#    api-gateway-staging
#    api-gateway-prod
#
# so that the changes are reflected in the cluster.

#
# 5. Verify:
#
#    - HPA exists in staging
#    - HPA exists in production
#    - staging maxReplicas = 4
#    - production maxReplicas = 6
#    - old horizontal-scaling-config ConfigMaps are removed
#
#
# Useful commands:
#
# kubectl kustomize
# kubectl apply
# kubectl diff
# kubectl get hpa
# kubectl get configmap
# kubectl describe hpa
#
# Do not create a separate HPA outside the Kustomize configuration.
#
# Modify the existing Kustomize configuration under:
#
# /opt/course/5/api-gateway
