#!/bin/bash

set -euo pipefail

NAMESPACE="project-hamster"
SERVICE_ACCOUNT="processor"
POD="api-contact"

echo "======================================================================"
echo "Solution Notes — Combined CKA Question 9 + 10"
echo "ServiceAccount + RBAC + Kubernetes API"
echo "======================================================================"


# ----------------------------------------------------------------------
# STEP 1
# ----------------------------------------------------------------------

echo
echo "===== STEP 1: Create Namespace ====="

kubectl create namespace "${NAMESPACE}"

echo
echo "Verify:"
kubectl get namespace "${NAMESPACE}"


# ----------------------------------------------------------------------
# STEP 2
# ----------------------------------------------------------------------

echo
echo "===== STEP 2: Create ServiceAccount ====="

kubectl create serviceaccount "${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo
echo "Verify:"
kubectl get serviceaccount "${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"


# ----------------------------------------------------------------------
# STEP 3
# ----------------------------------------------------------------------

echo
echo "===== STEP 3: Create Role ====="

echo
echo "The Role must ONLY allow:"
echo
echo "  create secrets"
echo "  create configmaps"

kubectl create role processor \
  -n "${NAMESPACE}" \
  --verb=create \
  --resource=secrets \
  --resource=configmaps

echo
echo "Verify Role:"
kubectl get role processor \
  -n "${NAMESPACE}"

echo
echo "Role details:"
kubectl describe role processor \
  -n "${NAMESPACE}"


# ----------------------------------------------------------------------
# STEP 4
# ----------------------------------------------------------------------

echo
echo "===== STEP 4: Create RoleBinding ====="

kubectl create rolebinding processor \
  -n "${NAMESPACE}" \
  --role=processor \
  --serviceaccount="${NAMESPACE}:${SERVICE_ACCOUNT}"

echo
echo "Verify RoleBinding:"
kubectl get rolebinding processor \
  -n "${NAMESPACE}"

echo
echo "RoleBinding details:"
kubectl describe rolebinding processor \
  -n "${NAMESPACE}"


# ----------------------------------------------------------------------
# STEP 5
# ----------------------------------------------------------------------

echo
echo "===== STEP 5: Verify RBAC Before Creating Pod ====="

echo
echo "Create Secret:"
kubectl auth can-i create secrets \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: yes"

echo
echo "Create ConfigMap:"
kubectl auth can-i create configmaps \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: yes"

echo
echo "Create Pod:"
kubectl auth can-i create pods \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"

echo
echo "Delete Secret:"
kubectl auth can-i delete secrets \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"

echo
echo "Get ConfigMap:"
kubectl auth can-i get configmaps \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"


# ----------------------------------------------------------------------
# STEP 6
# ----------------------------------------------------------------------

echo
echo "===== STEP 6: Create Pod ====="

cat > /tmp/api-contact.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: api-contact
  namespace: project-hamster
spec:
  serviceAccountName: processor
  containers:
  - name: api-contact
    image: nginx:1-alpine
EOF

kubectl apply -f /tmp/api-contact.yaml

echo
echo "Verify Pod:"
kubectl get pod "${POD}" \
  -n "${NAMESPACE}"

echo
echo "Verify ServiceAccount used by Pod:"

kubectl get pod "${POD}" \
  -n "${NAMESPACE}" \
  -o jsonpath='{.spec.serviceAccountName}'

echo


# ----------------------------------------------------------------------
# STEP 7
# ----------------------------------------------------------------------

echo
echo "===== STEP 7: Exec Into Pod ====="

echo
echo "Run:"
echo
echo "kubectl exec -it ${POD} -n ${NAMESPACE} -- sh"


# ----------------------------------------------------------------------
# STEP 8
# ----------------------------------------------------------------------

echo
echo "===== STEP 8: Get ServiceAccount Token ====="

echo
echo "Inside the Pod run:"
echo
echo 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)'


# ----------------------------------------------------------------------
# STEP 9
# ----------------------------------------------------------------------

echo
echo "===== STEP 9: Query Kubernetes API ====="

echo
echo "Required API endpoint:"
echo
echo "https://kubernetes.default/api/v1/namespaces/project-hamster/secrets"

echo
echo "Inside the Pod run:"
echo

cat <<'EOF'
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl -k \
  https://kubernetes.default/api/v1/namespaces/project-hamster/secrets \
  -H "Authorization: Bearer ${TOKEN}"
EOF


# ----------------------------------------------------------------------
# STEP 10
# ----------------------------------------------------------------------

echo
echo "===== STEP 10: Save Complete API Response ====="

echo
echo "Inside the Pod run:"
echo

cat <<'EOF'
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl -k \
  https://kubernetes.default/api/v1/namespaces/project-hamster/secrets \
  -H "Authorization: Bearer ${TOKEN}" \
  > result.json
EOF

echo
echo "Verify inside Pod:"
echo
echo "cat result.json"


# ----------------------------------------------------------------------
# STEP 11
# ----------------------------------------------------------------------

echo
echo "===== STEP 11: Preferred HTTPS Method ====="

echo
echo "The Pod also contains the Kubernetes CA certificate:"
echo
echo "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

echo
echo "Therefore, instead of -k, you can use:"

cat <<'EOF'

CACERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)

curl --cacert "${CACERT}" \
  https://kubernetes.default/api/v1/namespaces/project-hamster/secrets \
  -H "Authorization: Bearer ${TOKEN}" \
  > result.json
EOF


# ----------------------------------------------------------------------
# STEP 12
# ----------------------------------------------------------------------

echo
echo "===== STEP 12: Exit Pod ====="

echo
echo "exit"


# ----------------------------------------------------------------------
# STEP 13
# ----------------------------------------------------------------------

echo
echo "===== STEP 13: Copy result.json ====="

echo
echo "Create destination directory:"

echo
echo "mkdir -p /opt/course/9-10"

echo
echo "Copy result.json from Pod:"

echo
echo "kubectl exec -n project-hamster api-contact -- cat /result.json > /opt/course/9-10/result.json"


# ----------------------------------------------------------------------
# STEP 14
# ----------------------------------------------------------------------

echo
echo "===== STEP 14: Verify Result File ====="

echo
echo "Check file:"
echo

echo "ls -lh /opt/course/9-10/result.json"

echo
echo "Check contents:"
echo

echo "cat /opt/course/9-10/result.json"


# ----------------------------------------------------------------------
# STEP 15
# ----------------------------------------------------------------------

echo
echo "===== STEP 15: Final RBAC Verification ====="

echo
echo "------------------------------------------------"
echo "Create Secret"
echo "------------------------------------------------"

kubectl auth can-i create secrets \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: yes"


echo
echo "------------------------------------------------"
echo "Create ConfigMap"
echo "------------------------------------------------"

kubectl auth can-i create configmaps \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: yes"


echo
echo "------------------------------------------------"
echo "Create Pod"
echo "------------------------------------------------"

kubectl auth can-i create pods \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"


echo
echo "------------------------------------------------"
echo "Delete Secret"
echo "------------------------------------------------"

kubectl auth can-i delete secrets \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"


echo
echo "------------------------------------------------"
echo "Get ConfigMap"
echo "------------------------------------------------"

kubectl auth can-i get configmaps \
  --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  -n "${NAMESPACE}"

echo "Expected: no"


# ----------------------------------------------------------------------
# STEP 16
# ----------------------------------------------------------------------

echo
echo "===== STEP 16: Final File Check ====="

if [ -s /opt/course/9-10/result.json ]; then
    echo "✅ RESULT FILE OK"
    echo
    echo "Final result:"
    echo "/opt/course/9-10/result.json"
else
    echo "❌ RESULT FILE MISSING OR EMPTY"
    exit 1
fi


echo
echo "======================================================================"
echo "Expected Final RBAC"
echo "======================================================================"

echo
echo "Create Secret     -> yes"
echo "Create ConfigMap  -> yes"
echo "Create Pod        -> no"
echo "Delete Secret     -> no"
echo "Get ConfigMap     -> no"

echo
echo "Final API response:"
echo
echo "/opt/course/9-10/result.json"

echo
echo "======================================================================"
echo "END OF SOLUTION"
echo "======================================================================"
