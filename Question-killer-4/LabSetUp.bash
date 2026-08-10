#!/bin/bash
set -euo pipefail

NAMESPACE="project-hamster"

echo "🔹 Preparing Question 9+10 practice lab..."

echo "🔹 Creating namespace: $NAMESPACE"
kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo
echo "=========================================="
echo "✅ Lab setup complete"
echo "=========================================="

echo
echo "Starting state:"
echo "- Namespace: project-hamster exists"
echo "- ServiceAccount: NOT created"
echo "- Role: NOT created"
echo "- RoleBinding: NOT created"
echo "- API-access Pod: NOT created"
echo
echo "⚠️ Candidate must complete ALL tasks."
