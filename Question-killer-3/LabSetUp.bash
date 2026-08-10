#!/bin/bash
set -euo pipefail

echo "🔹 Preparing Question 5 - Kustomize HPA lab..."

BASE="/opt/course/5/api-gateway"

# ------------------------------------------------------------
# Clean previous lab if it exists
# ------------------------------------------------------------

rm -rf "$BASE"

mkdir -p "$BASE/base"
mkdir -p "$BASE/staging"
mkdir -p "$BASE/prod"

# ------------------------------------------------------------
# Create namespaces
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
  namespace: NAMESPACE_REPLACE
EOF

# ------------------------------------------------------------
# BASE - Old ConfigMap
# ------------------------------------------------------------

cat > "$BASE/base/horizontal-scaling-config.yaml" <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: horizontal-scaling-config
  namespace: NAMESPACE_REPLACE
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
  namespace: NAMESPACE_REPLACE
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
# STAGING patch
# ------------------------------------------------------------

cat > "$BASE/staging/api-gateway.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  labels:
    env: staging
EOF

# ------------------------------------------------------------
# STAGING patch for old ConfigMap
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
# STAGING Kustomization
# ------------------------------------------------------------

cat > "$BASE/staging/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base

patches:
  - path: api-gateway.yaml
  - path: horizontal-scaling-config.yaml

transformers:
  - |
    apiVersion: builtin
    kind: NamespaceTransformer
    metadata:
      name: notImportantHere
    namespace: api-gateway-staging
EOF

# ------------------------------------------------------------
# PROD patch
# ------------------------------------------------------------

cat > "$BASE/prod/api-gateway.yaml" <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  labels:
    env: prod
EOF

# ------------------------------------------------------------
# PROD patch for old ConfigMap
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
# PROD Kustomization
# ------------------------------------------------------------

cat > "$BASE/prod/kustomization.yaml" <<'EOF'
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../base

patches:
  - path: api-gateway.yaml
  - path: horizontal-scaling-config.yaml

transformers:
  - |
    apiVersion: builtin
    kind: NamespaceTransformer
    metadata:
      name: notImportantHere
    namespace: api-gateway-prod
EOF

# ------------------------------------------------------------
# Deploy INITIAL state
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
echo "- Namespaces created"
echo "- api-gateway Deployment exists"
echo "- horizontal-scaling-config exists"
echo "- No HPA exists"
echo "- Staging ConfigMap scaling value: 60"
echo "- Production ConfigMap scaling value: 50"
echo "- Candidate must remove the ConfigMap"
echo "- Candidate must create the HPA"
echo "- Candidate must configure prod maxReplicas = 6"
