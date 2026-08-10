#!/bin/bash

# Question 9+10 — ServiceAccount, RBAC and Kubernetes API

# Task
#
# You are working in the Kubernetes cluster.
#
# Namespace:
# project-hamster
#
# A ServiceAccount named:
# processor
#
# is available for an application Pod.
#
# 1. Create/configure RBAC so that the ServiceAccount processor
#    can ONLY create:
#
#    - Secrets
#    - ConfigMaps
#
#    in the project-hamster namespace.
#
# 2. Create/use a Pod named:
#
#    api-contact
#
#    using image:
#
#    nginx:1-alpine
#
#    The Pod must use the ServiceAccount:
#
#    processor
#
# 3. From inside the Pod, use the ServiceAccount token to
#    authenticate to the Kubernetes API.
#
# 4. Query all Secrets from the project-hamster namespace using:
#
#    https://kubernetes.default/api/v1/namespaces/project-hamster/secrets
#
# 5. Save the complete API response inside the Pod as:
#
#    result.json
#
# 6. Copy the result from the Pod to:
#
#    /opt/course/9-10/result.json
#
# 7. Verify that the processor ServiceAccount:
#
#    - can create Secrets
#    - can create ConfigMaps
#    - cannot create Pods
#    - cannot delete Secrets
#    - cannot get ConfigMaps
#
# The ServiceAccount token is mounted inside the Pod at:
#
# /var/run/secrets/kubernetes.io/serviceaccount/token
