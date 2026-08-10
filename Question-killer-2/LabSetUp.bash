#!/bin/bash
set -euo pipefail

echo "🔹 Creating namespace: minio"

kubectl create namespace minio \
  --dry-run=client \
  -o yaml | kubectl apply -f -

echo "🔹 Adding MinIO Operator Helm repository..."

helm repo add minio-operator https://operator.min.io/ \
  --force-update

echo "🔹 Updating Helm repositories..."

helm repo update

echo "🔹 Searching MinIO Operator chart..."

helm search repo minio-operator

echo "🔹 Installing MinIO Operator..."

helm upgrade --install minio-operator \
  minio-operator/operator \
  --namespace minio \
  --create-namespace

echo "🔹 Waiting for MinIO Operator..."

kubectl -n minio rollout status deployment \
  -l app.kubernetes.io/name=operator \
  --timeout=120s || true

echo "🔹 Creating Tenant YAML..."

mkdir -p /opt/course/2

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
echo "=== Helm Repository ==="
helm repo list

echo
echo "=== Helm Release ==="
helm -n minio list

echo
echo "=== MinIO CRDs ==="
kubectl get crd | grep minio || true

echo
echo "=== Tenant YAML ==="
ls -l /opt/course/2/minio-tenant.yaml
