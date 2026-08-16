# Question 2 — MinIO Operator, CRD Config, Helm Install
# Task
# 1. Create the Namespace: minio
#
# 2. Install the MinIO Operator using Helm:
#
#    Helm repository: minio
#    Chart: minio/operator
#    Install the Helm chart into the Namespace: minio
#    The Helm release must be called:minio-operator
#
# 3. A Tenant Custom Resource definition is available in: /opt/course/2/minio-tenant.yaml
#    Modify the Tenant resource so that:
#    spec.features.enableSFTP  is set to: true
#
# 4. Create/apply the Tenant resource from:
#
#    /opt/course/2/minio-tenant.yaml
# Do not create a different Tenant YAML file.
# Verify that the Tenant resource was created successfully.
