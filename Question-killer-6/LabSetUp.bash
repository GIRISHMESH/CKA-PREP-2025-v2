
#!/usr/bin/env bash
set -euo pipefail

NS="project-hamster"

echo "==> Preparing namespace: ${NS}"
kubectl create namespace "${NS}" --dry-run=client -o yaml | kubectl apply -f -

echo "==> Creating p2-pod..."
kubectl -n "${NS}" run p2-pod --image=nginx:1-alpine --restart=Never
kubectl -n "${NS}" wait --for=condition=Ready pod/p2-pod --timeout=120s

echo "==> Creating p2-service:3000 -> p2-pod:80..."
kubectl -n "${NS}" expose pod p2-pod   --name=p2-service   --port=3000   --target-port=80

echo
echo "============================================================"
echo "Lab setup complete."
echo "============================================================"
kubectl -n "${NS}" get pod,svc -o wide
echo
echo "Solve the task using Questions.bash."
echo "The setup intentionally does NOT create the requested"
echo "/opt/course/p2/iptables.txt answer file."
echo "============================================================"
