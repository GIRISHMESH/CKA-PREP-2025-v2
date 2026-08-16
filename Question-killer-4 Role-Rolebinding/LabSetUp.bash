#!/bin/bash

set -euo pipefail

NAMESPACE="project-hamster"

echo "============================================================"
echo " Preparing Combined CKA Question 9+10 Lab"
echo "============================================================"

echo
echo "Creating namespace: ${NAMESPACE}"

kubectl create namespace "${NAMESPACE}" \
  --dry-run=client -o yaml | kubectl apply -f -

# Clean target resources so the candidate starts from scratch.
echo
echo "Cleaning existing target resources..."

kubectl delete pod api-contact \
  -n "${NAMESPACE}" \
  --ignore-not-found

kubectl delete rolebinding processor \
  -n "${NAMESPACE}" \
  --ignore-not-found

kubectl delete role processor \
  -n "${NAMESPACE}" \
  --ignore-not-found

kubectl delete serviceaccount processor \
  -n "${NAMESPACE}" \
  --ignore-not-found

# Clean previous result if this is being run on the same lab machine.
rm -f /opt/course/9-10/result.json

echo
echo "============================================================"
echo " Lab Setup Complete"
echo "============================================================"

echo
echo "Starting state:"
echo
echo "Namespace:"
echo "  project-hamster        EXISTS"
echo
echo "ServiceAccount:"
echo "  processor              NOT CREATED"
echo
echo "Role:"
echo "  processor              NOT CREATED"
echo
echo "RoleBinding:"
echo "  processor              NOT CREATED"
echo
echo "Pod:"
echo "  api-contact            NOT CREATED"
echo
echo "Result:"
echo "  /opt/course/9-10/result.json  NOT CREATED"

echo
echo "Candidate must complete ALL tasks from scratch."
