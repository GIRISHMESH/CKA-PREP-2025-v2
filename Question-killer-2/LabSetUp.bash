#!/bin/bash
set -euo pipefail

echo "🔹 Creating namespace: minio"

kubectl create namespace minio \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "🔹 Adding MinIO Helm repository..."

helm repo add minio http://localhost:6000 2>/dev/null || true

echo "🔹 Updating Helm repositories..."

helm repo update

echo "🔹 Checking MinIO Operator chart..."

helm search repo minio/operator

echo "🔹 Installing MinIO Operator..."

helm upgrade --install minio-operator minio/operator \
  --namespace minio \
  --create-namespace

echo "🔹 Waiting for MinIO Operator deployment..."

kubectl -n minio rollout status deployment \
  -l app.kubernetes.io/name=operator \
  --timeout=120s || true

echo "🔹 Creating initial Tenant YAML..."

cat > /opt/course/2/minio-tenant.yaml <<'EOF'
apiVersion: minio.min.io/v2
kind: Tenant
metadata:
  name: tenant
  namespace: minio
  labels:
    app: minio
spec:
  features:
    bucketDNS: false
    enableSFTP: false

  image: quay.io/minio/minio:latest

  pools:
    - servers: 1
      name: pool-0
      volumesPerServer: 0

  requestAutoCert: true

  volumeClaimTemplate:
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata: {}
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Mi
      storageClassName: standard
    status: {}
EOF

echo
echo "✅ MinIO Operator lab setup complete."
echo
echo "Namespace:"
kubectl get namespace minio

echo
echo "Helm release:"
helm -n minio list

echo
echo "MinIO CRDs:"
kubectl get crd | grep -E 'minio|sts' || true

echo
echo "Tenant YAML created:"
ls -l /opt/course/2/minio-tenant.yaml
