# Solution — Question 1

## Step 1 — Inspect the kubeconfig

k --kubeconfig /opt/course/1/kubeconfig config get-contexts

## Step 2 — Extract all context names

k --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name > /opt/course/1/contexts

Verify:

cat /opt/course/1/contexts

Expected:

cluster-admin
cluster-w100
cluster-w200

## Step 3 — Find and save the current context

k --kubeconfig /opt/course/1/kubeconfig config current-context

k --kubeconfig /opt/course/1/kubeconfig config current-context > /opt/course/1/current-context

Verify:

cat /opt/course/1/current-context

Expected:

cluster-w200

## Step 4 — Extract and decode the client certificate

In this lab, account-0027@internal is the first user:

k --kubeconfig /opt/course/1/kubeconfig config view --raw -ojsonpath="{.users[0].user.client-certificate-data}" | base64 -d > /opt/course/1/cert

## Step 5 — Verify

cat /opt/course/1/cert

Optional:

openssl x509 -in /opt/course/1/cert -noout -subject

Expected:

subject=CN = account-0027@internal

## Fast solution

k --kubeconfig /opt/course/1/kubeconfig config get-contexts -o name > /opt/course/1/contexts

k --kubeconfig /opt/course/1/kubeconfig config current-context > /opt/course/1/current-context

k --kubeconfig /opt/course/1/kubeconfig config view --raw -ojsonpath="{.users[0].user.client-certificate-data}" | base64 -d > /opt/course/1/cert
