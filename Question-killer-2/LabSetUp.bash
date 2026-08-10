#!/bin/bash
set -euo pipefail

echo "🔹 Preparing Tenant YAML..."

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

  requestAutoCert: true
EOF

echo
echo "=========================================="
echo "✅ Lab setup complete"
echo "=========================================="

echo
echo "📁 Tenant YAML:"
echo "/opt/course/2/minio-tenant.yaml"

echo
echo "⚠️ Candidate must now complete the question."

echo
echo "Starting state:"
echo "- Namespace minio: NOT created"
echo "- MinIO Operator: NOT installed"
echo "- MinIO CRDs: NOT installed"
echo "- Tenant YAML: prepared"
echo "- enableSFTP: false"
