### Question 5 — Kustomize HPA Autoscaler
###Previously, the application api-gateway used an external autoscaler. Replace it with a Kubernetes HorizontalPodAutoscaler (HPA).
### Solve this task on the current Kubernetes cluster.
###
### The application "api-gateway" is deployed in the following environments:
###   api-gateway-staging
###   api-gateway-prod
###
### The existing Kustomize configuration for the application is located at: /opt/course/5/api-gateway
###
### Tasks
###
### 1. Modify the existing configuration to replace the application's  current external autoscaling configuration with a Kubernetes-based autoscaling configuration.
###
### 2. Configure autoscaling for the "api-gateway" application with:
###
###    - Minimum replicas: 2
###    - Maximum replicas in staging: 4
###    - Target CPU utilization: 50%
###
### 3. In the production environment, configure the maximum number of replicas as 6.
###
### 4. Deploy the updated configuration to both:
###
###    - api-gateway-staging
###    - api-gateway-prod
###
### 5. Verify that the required autoscaling configuration is active in both environments.
###
### 6. Verify that the previous external horizontal scaling configuration is no longer present.
###
### Important
###
### - Make the changes using the existing Kustomize configuration.
### - Do not create a separate configuration outside the existing
###   application structure.
### - Do not modify resources unrelated to this task.
