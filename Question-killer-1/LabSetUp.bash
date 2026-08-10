#!/bin/bash
set -euo pipefail

echo "🔹 Creating directories..."

mkdir -p /opt/course/1

echo "🔹 Creating test certificates..."

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Create CA
openssl genrsa -out "$TMP_DIR/ca.key" 2048 2>/dev/null

openssl req -x509 \
  -new \
  -nodes \
  -key "$TMP_DIR/ca.key" \
  -sha256 \
  -days 365 \
  -out "$TMP_DIR/ca.crt" \
  -subj "/CN=kubernetes-ca" \
  2>/dev/null

# Create client certificate for account-0027@internal
openssl genrsa -out "$TMP_DIR/account-0027.key" 2048 2>/dev/null

openssl req \
  -new \
  -key "$TMP_DIR/account-0027.key" \
  -out "$TMP_DIR/account-0027.csr" \
  -subj "/CN=account-0027@internal" \
  2>/dev/null

openssl x509 \
  -req \
  -in "$TMP_DIR/account-0027.csr" \
  -CA "$TMP_DIR/ca.crt" \
  -CAkey "$TMP_DIR/ca.key" \
  -CAcreateserial \
  -out "$TMP_DIR/account-0027.crt" \
  -days 365 \
  -sha256 \
  2>/dev/null

# Create admin certificate
openssl genrsa -out "$TMP_DIR/admin.key" 2048 2>/dev/null

openssl req \
  -new \
  -key "$TMP_DIR/admin.key" \
  -out "$TMP_DIR/admin.csr" \
  -subj "/CN=admin@internal" \
  2>/dev/null

openssl x509 \
  -req \
  -in "$TMP_DIR/admin.csr" \
  -CA "$TMP_DIR/ca.crt" \
  -CAkey "$TMP_DIR/ca.key" \
  -CAcreateserial \
  -out "$TMP_DIR/admin.crt" \
  -days 365 \
  -sha256 \
  2>/dev/null

# Create account-0028 certificate
openssl genrsa -out "$TMP_DIR/account-0028.key" 2048 2>/dev/null

openssl req \
  -new \
  -key "$TMP_DIR/account-0028.key" \
  -out "$TMP_DIR/account-0028.csr" \
  -subj "/CN=account-0028@internal" \
  2>/dev/null

openssl x509 \
  -req \
  -in "$TMP_DIR/account-0028.csr" \
  -CA "$TMP_DIR/ca.crt" \
  -CAkey "$TMP_DIR/ca.key" \
  -CAcreateserial \
  -out "$TMP_DIR/account-0028.crt" \
  -days 365 \
  -sha256 \
  2>/dev/null

echo "🔹 Creating kubeconfig..."

KUBECONFIG="/opt/course/1/kubeconfig"
rm -f "$KUBECONFIG"

kubectl config --kubeconfig="$KUBECONFIG" \
  set-cluster kubernetes \
  --server=https://127.0.0.1:6443 \
  --certificate-authority="$TMP_DIR/ca.crt" >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-credentials admin@internal \
  --client-certificate="$TMP_DIR/admin.crt" \
  --client-key="$TMP_DIR/admin.key" >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-credentials account-0027@internal \
  --client-certificate="$TMP_DIR/account-0027.crt" \
  --client-key="$TMP_DIR/account-0027.key" >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-credentials account-0028@internal \
  --client-certificate="$TMP_DIR/account-0028.crt" \
  --client-key="$TMP_DIR/account-0028.key" >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-context cluster-admin \
  --cluster=kubernetes \
  --user=admin@internal >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-context cluster-w100 \
  --cluster=kubernetes \
  --user=account-0027@internal >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  set-context cluster-w200 \
  --cluster=kubernetes \
  --user=account-0028@internal >/dev/null

kubectl config --kubeconfig="$KUBECONFIG" \
  use-context cluster-w200 >/dev/null

echo "✅ Kubeconfig lab setup complete."
