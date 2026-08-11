#!/usr/bin/env bash

cat <<'EOF'
============================================================
CKA QUESTION 15 - NetworkPolicy
============================================================

Cluster:
  KillerCoda Kubernetes playground

Namespace:
  project-snake

Security incident:
  An intruder was able to access the whole cluster from a
  single hacked backend Pod.

Task:
  Create a NetworkPolicy named:

    np-backend

  in namespace:

    project-snake

Requirements:

  1. The policy must select backend-* Pods using the Pod label:
       app=backend

  2. backend-* Pods must be allowed to connect to:
       db1-* Pods on TCP port 1111

  3. backend-* Pods must be allowed to connect to:
       db2-* Pods on TCP port 2222

  4. backend-* Pods must NOT be able to connect to:
       vault-* Pods on TCP port 3333

Important:
  Use Pod labels in the policy. Do not depend on Pod names or
  dynamically assigned Pod IP addresses.

Useful commands:

  kubectl -n project-snake get pod -L app -o wide

  kubectl -n project-snake exec backend-0 -- \
    curl -s <DB1_POD_IP>:1111

  kubectl -n project-snake exec backend-0 -- \
    curl -s <DB2_POD_IP>:2222

  kubectl -n project-snake exec backend-0 -- \
    curl -s <VAULT_POD_IP>:3333

Expected result after your NetworkPolicy:

  backend -> db1:1111       ALLOWED
  backend -> db2:2222       ALLOWED
  backend -> vault:3333     BLOCKED

Create the NetworkPolicy yourself.

Do NOT look at SolutionNotes.bash until you have attempted it.
============================================================
EOF
