
#!/usr/bin/env bash
set -euo pipefail

echo "============================================================"
echo "CKA LAB SETUP - CHANGE SERVICE CIDR"
echo "============================================================"

# Prepare the answer directory only.
# Do NOT create the Pod or Services here because those are
# part of the candidate's actual task.

mkdir -p /opt/course/18

echo
echo "Checking Kubernetes cluster..."
kubectl get nodes

echo
echo "Checking current Service CIDR configuration..."
grep -- '--service-cluster-ip-range=' \
  /etc/kubernetes/manifests/kube-apiserver.yaml || true

echo
echo "Checking current ServiceCIDR resources..."
kubectl get servicecidr 2>/dev/null || true

echo
echo "============================================================"
echo "LAB READY"
echo "============================================================"
echo
echo "Nothing has been created for the actual task."
echo
echo "Run:"
echo
echo "  bash Questions.bash"
echo
echo "Then solve the question yourself."
echo "============================================================"
