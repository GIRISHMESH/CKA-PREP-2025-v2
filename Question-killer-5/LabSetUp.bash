
#!/usr/bin/env bash
set -euo pipefail

# CKA Question 15 - NetworkPolicy
# KillerCoda / Kubernetes lab setup
#
# Creates:
#   namespace: project-snake
#   backend-0  app=backend
#   db1-0      app=db1, nginx on TCP/1111
#   db2-0      app=db2, nginx on TCP/2222
#   vault-0    app=vault, nginx on TCP/3333
#
# All Pods use plain nginx images.

NS="project-snake"

echo "==> Creating namespace..."
kubectl create namespace "${NS}" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Creating lab Pods..."

cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: backend-0
  namespace: project-snake
  labels:
    app: backend
spec:
  containers:
  - name: nginx
    image: nginx:alpine
---
apiVersion: v1
kind: Pod
metadata:
  name: db1-0
  namespace: project-snake
  labels:
    app: db1
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      sed -i 's/listen       80;/listen       1111;/' /etc/nginx/conf.d/default.conf
      printf 'database one\n' > /usr/share/nginx/html/index.html
      exec nginx -g 'daemon off;'
---
apiVersion: v1
kind: Pod
metadata:
  name: db2-0
  namespace: project-snake
  labels:
    app: db2
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      sed -i 's/listen       80;/listen       2222;/' /etc/nginx/conf.d/default.conf
      printf 'database two\n' > /usr/share/nginx/html/index.html
      exec nginx -g 'daemon off;'
---
apiVersion: v1
kind: Pod
metadata:
  name: vault-0
  namespace: project-snake
  labels:
    app: vault
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    command: ["/bin/sh", "-c"]
    args:
    - |
      sed -i 's/listen       80;/listen       3333;/' /etc/nginx/conf.d/default.conf
      printf 'vault secret storage\n' > /usr/share/nginx/html/index.html
      exec nginx -g 'daemon off;'
EOF

echo "==> Waiting for Pods..."
kubectl -n "${NS}" wait --for=condition=Ready pod/backend-0 --timeout=120s
kubectl -n "${NS}" wait --for=condition=Ready pod/db1-0 --timeout=120s
kubectl -n "${NS}" wait --for=condition=Ready pod/db2-0 --timeout=120s
kubectl -n "${NS}" wait --for=condition=Ready pod/vault-0 --timeout=120s

echo
echo "============================================================"
echo "Lab ready."
echo "============================================================"
kubectl -n "${NS}" get pod -L app -o wide

echo
echo "Initial connectivity test:"
DB1_IP="$(kubectl -n "${NS}" get pod db1-0 -o jsonpath='{.status.podIP}')"
DB2_IP="$(kubectl -n "${NS}" get pod db2-0 -o jsonpath='{.status.podIP}')"
VAULT_IP="$(kubectl -n "${NS}" get pod vault-0 -o jsonpath='{.status.podIP}')"

kubectl -n "${NS}" exec backend-0 -- curl -s --max-time 5 "${DB1_IP}:1111" || true
kubectl -n "${NS}" exec backend-0 -- curl -s --max-time 5 "${DB2_IP}:2222" || true
kubectl -n "${NS}" exec backend-0 -- curl -s --max-time 5 "${VAULT_IP}:3333" || true

echo
echo "Now solve the task without creating any NetworkPolicy during setup."
