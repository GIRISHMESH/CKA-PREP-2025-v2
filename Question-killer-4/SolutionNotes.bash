#!/bin/bash

# Question 9+10 — Solution Notes
#
# ServiceAccount + RBAC + Kubernetes API

echo "===== STEP 1: Verify ServiceAccount ====="

kubectl -n project-hamster get serviceaccount processor


echo
echo "===== STEP 2: Verify Role ====="

kubectl -n project-hamster get role processor

kubectl -n project-hamster describe role processor


echo
echo "===== STEP 3: Verify RoleBinding ====="

kubectl -n project-hamster get rolebinding processor

kubectl -n project-hamster describe rolebinding processor


echo
echo "===== STEP 4: Verify Pod ====="

kubectl -n project-hamster get pod api-contact -o wide

kubectl -n project-hamster get pod api-contact \
  -o jsonpath='{.spec.serviceAccountName}'

echo


echo
echo "===== STEP 5: Test RBAC ====="

kubectl -n project-hamster auth can-i create secret \
  --as system:serviceaccount:project-hamster:processor

kubectl -n project-hamster auth can-i create configmap \
  --as system:serviceaccount:project-hamster:processor

kubectl -n project-hamster auth can-i create pod \
  --as system:serviceaccount:project-hamster:processor

kubectl -n project-hamster auth can-i delete secret \
  --as system:serviceaccount:project-hamster:processor

kubectl -n project-hamster auth can-i get configmap \
  --as system:serviceaccount:project-hamster:processor


echo
echo "===== STEP 6: Enter Pod ====="

echo "Run:"
echo
echo 'kubectl -n project-hamster exec -it api-contact -- sh'


echo
echo "===== STEP 7: Inside Pod — Get Token ====="

echo 'TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)'


echo
echo "===== STEP 8: Query Kubernetes API ====="

echo 'curl -k https://kubernetes.default/api/v1/namespaces/project-hamster/secrets \'
echo '  -H "Authorization: Bearer ${TOKEN}"'


echo
echo "===== STEP 9: Save Result inside Pod ====="

echo 'curl -k https://kubernetes.default/api/v1/namespaces/project-hamster/secrets \'
echo '  -H "Authorization: Bearer ${TOKEN}" > result.json'


echo
echo "===== STEP 10: Exit Pod ====="

echo "exit"


echo
echo "===== STEP 11: Copy result to required location ====="

echo 'mkdir -p /opt/course/9-10'

echo 'kubectl -n project-hamster exec api-contact -- cat result.json > /opt/course/9-10/result.json'


echo
echo "===== STEP 12: Verify ====="

echo 'cat /opt/course/9-10/result.json'


echo
echo "===== Expected RBAC ====="
echo "create secret     -> yes"
echo "create configmap  -> yes"
echo "create pod        -> no"
echo "delete secret     -> no"
echo "get configmap     -> no"
