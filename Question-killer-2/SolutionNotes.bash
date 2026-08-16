# ============================================================
# Solution — Question 2
# MinIO Operator, CRD Config, Helm Install
# ============================================================
# ============================================================
# TASK 1
# Create Namespace
# ============================================================
kubectl create namespace minio
# ============================================================
# TASK 2
# Install MinIO Operator using Helm
# ============================================================
helm repo list
helm search repo minio/operator
helm -n minio install minio-operator minio/operator

# Verify Helm release
helm -n minio list

# Verify Operator pods
kubectl -n minio get pods

# ============================================================
# TASK 3
# Modify Tenant YAML
# ============================================================

vim /opt/course/2/minio-tenant.yaml

# Change:
#
# enableSFTP: false
#
# to:
#
# enableSFTP: true

# You can verify the setting with:

grep -n -A5 -B2 "features:" /opt/course/2/minio-tenant.yaml

# Expected:

# features:
#   bucketDNS: false
#   enableSFTP: true

# ============================================================
# TASK 4
# Apply Tenant
# ============================================================
kubectl apply -f /opt/course/2/minio-tenant.yaml

# ============================================================
# VERIFICATION
# ============================================================

kubectl get crd | grep minio
kubectl -n minio get tenant
kubectl -n minio get tenant tenant -o yaml
# Verify enableSFTP:
kubectl -n minio get tenant tenant \
  -o jsonpath='{.spec.features.enableSFTP}'

echo
