#!/bin/bash
set -euo pipefail

echo "🔹 Preparing Question 9+10 — ServiceAccount, RBAC and Kubernetes API"

NAMESPACE="project-hamster"

echo "🔹 Creating namespace..."
kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating ServiceAccount: processor..."

kubectl -n "$NAMESPACE" create serviceaccount processor \
  --dry-run=client -o yaml | kubectl apply -f -

echo "🔹 Creating initial RBAC configuration..."

kubectl -n "$NAMESPACE" create role processor \
  --verb=create \
  --resource=secret \
  --resource=configmap \
  --dry-run=client -o yaml > /tmp/processor-role.yaml

kubectl apply -f /tmp/processor-role.yaml

kubectl -n "$NAMESPACE" create rolebinding processor \
  --role=processor \
  --serviceaccount="$NAMESPACE:processor" \
  --dry-run=client -o yaml > /tmp/processor-rolebinding.yaml

kubectl apply -f /tmp/processor-rolebinding.yaml

echo "🔹 Creating API-access Pod..."

kubectl run api-contact \
  --image=nginx:1-alpine \
  -n "$NAMESPACE" \
  --dry-run=client -o yaml > /tmp/api-contact.yaml

sed -i '/^spec:/a\  serviceAccountName: processor' /tmp/api-contact.yaml

kubectl apply -f /tmp/api-contact.yaml

echo "🔹 Waiting for Pod..."
kubectl -n "$NAMESPACE" wait \
  --for=condition=Ready \
  pod/api-contact \
  --timeout=120s

echo
echo "=========================================="
echo "✅ Lab setup complete"
echo "=========================================="

echo
echo "Starting state:"
echo "- Namespace: project-hamster"
echo "- ServiceAccount: processor"
echo "- Role: processor"
echo "- RoleBinding: processor"
echo "- Pod: api-contact"
echo "- Image: nginx:1-alpine"

echo
echo "⚠️ Candidate must complete the API query and save:"
echo "/opt/course/9-10/result.json"
