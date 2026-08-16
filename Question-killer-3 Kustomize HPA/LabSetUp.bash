#!/bin/bash
set -euo pipefail

echo "🔹 Preparing Question 5 - Kustomize HPA lab..."

BASE="/opt/course/5/api-gateway"

rm -rf "$BASE"

mkdir -p "$BASE/base"
mkdir -p "$BASE/staging"
mkdir -p "$BASE/prod"

# ------------------------------------------------------------
# Namespaces
# ------------------------------------------------------------

echo "🔹 Creating namespaces..."

kubectl create namespace api-gateway-staging \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace api-gateway-prod \
  --dry-run=client -o yaml | kubectl apply -f -

# ------------------------------------------------------------
# BASE - ServiceAccount
# ------------------------------------------------------------

cat > "$BASE/base/serviceaccount.yaml" <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-gateway
EOF

# ------------------------------------------------------------
# BASE - Old ConfigMap
# ------------------------------------------------------------

cat > "$BASE/base/horizontal-scaling-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  horizontal-scaling: "70"
EOF

# ------------------------------------------------------------
# BASE - Deployment
# ------------------------------------------------------------

cat > "$BASE/base/api-gateway.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
  selector:
    matchLabels:
      id: api-gateway
  template:
    metadata:
      labels:
        id: api-gateway
    spec:
      serviceAccountName: api-gateway
      containers:
        - name: httpd
          image: httpd:2-alpine
          resources:
            requests:
              cpu: 10m
              memory: 16Mi
            limits:
              cpu: 100m
              memory: 64Mi
EOF

# ------------------------------------------------------------
# BASE - Kustomization
# ------------------------------------------------------------

cat > "$BASE/base/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - serviceaccount.yaml
  - horizontal-scaling-config.yaml
  - api-gateway.yaml
EOF

# ------------------------------------------------------------
# STAGING - Deployment patch
# ------------------------------------------------------------

cat > "$BASE/staging/api-gateway.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
EOF

# ------------------------------------------------------------
# STAGING - ConfigMap patch
# ------------------------------------------------------------

cat > "$BASE/staging/horizontal-scaling-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  horizontal-scaling: "60"
EOF

# ------------------------------------------------------------
# STAGING - Kustomization
# ------------------------------------------------------------

cat > "$BASE/staging/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: api-gateway-staging

resources:
  - ../base

patches:
  - path: api-gateway.yaml
  - path: horizontal-scaling-config.yaml
EOF

# ------------------------------------------------------------
# PROD - Deployment patch
# ------------------------------------------------------------

cat > "$BASE/prod/api-gateway.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
spec:
  replicas: 1
EOF

# ------------------------------------------------------------
# PROD - ConfigMap patch
# ------------------------------------------------------------

cat > "$BASE/prod/horizontal-scaling-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
data:
  horizontal-scaling: "50"
EOF

# ------------------------------------------------------------
# PROD - Kustomization
# ------------------------------------------------------------

cat > "$BASE/prod/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: api-gateway-prod

resources:
  - ../base

patches:
  - path: api-gateway.yaml
  - path: horizontal-scaling-config.yaml
EOF

# ------------------------------------------------------------
# Deploy initial state
# ------------------------------------------------------------

echo "🔹 Deploying initial staging configuration..."

kubectl kustomize "$BASE/staging" | kubectl apply -f -

echo "🔹 Deploying initial production configuration..."

kubectl kustomize "$BASE/prod" | kubectl apply -f -

echo
echo "=========================================="
echo "✅ Lab setup complete"
echo "=========================================="

echo
echo "📁 Kustomize directory:"
echo "$BASE"

echo
echo "Starting state:"
echo "- Namespace api-gateway-staging: created"
echo "- Namespace api-gateway-prod: created"
echo "- api-gateway Deployment: exists"
echo "- horizontal-scaling-config: exists"
echo "- HPA: NOT created"
echo "- Candidate must remove the ConfigMap"
echo "- Candidate must create the HPA"
echo "- Staging maxReplicas: 4"
echo "- Production maxReplicas: 6"
