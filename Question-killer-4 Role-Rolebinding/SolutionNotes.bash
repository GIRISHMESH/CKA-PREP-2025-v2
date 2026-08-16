#!/bin/bash
cat <<'EOF'
======================================================================
Question 9 + 10 — Solution
ServiceAccount, RBAC & Kubernetes API
======================================================================
STEP 1 — Namespace
kubectl create namespace project-hamster
STEP 2 — ServiceAccount
kubectl create serviceaccount processor -n project-hamster
STEP 3 — Role
kubectl create role processor -n project-hamster --verb=create --resource=secrets --resource=configmaps
STEP 4 — RoleBinding
kubectl create rolebinding processor -n project-hamster --role=processor --serviceaccount=project-hamster:processor
STEP 5 — Verify RBAC
kubectl auth can-i create secrets --as=system:serviceaccount:project-hamster:processor -n project-hamster
kubectl auth can-i create configmaps --as=system:serviceaccount:project-hamster:processor -n project-hamster
kubectl auth can-i create pods --as=system:serviceaccount:project-hamster:processor -n project-hamster
kubectl auth can-i delete secrets --as=system:serviceaccount:project-hamster:processor -n project-hamster
kubectl auth can-i get configmaps --as=system:serviceaccount:project-hamster:processor -n project-hamster
STEP 6 — Pod
Create Pod api-contact using nginx:1-alpine and ServiceAccount processor.
STEP 7 — API Access
kubectl exec -it api-contact -n project-hamster -- sh
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
STEP 8 — Query API
curl -k https://kubernetes.default/api/v1/namespaces/project-hamster/secrets -H "Authorization: Bearer ${TOKEN}" > result.json
STEP 9 — Copy Result
mkdir -p /opt/course/9-10
kubectl exec -n project-hamster api-contact -- cat /result.json > /opt/course/9-10/result.json
STEP 10 — Final Verification
ls -lh /opt/course/9-10/result.json
======================================================================
END OF SOLUTION
======================================================================
EOF
