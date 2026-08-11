#!/usr/bin/env bash

cat <<'EOF'
============================================================
CKA QUESTION 2 - SOLUTION NOTES
============================================================

GOAL
----

Verify:

  Service
    |
    v
  kube-proxy
    |
    v
  iptables
    |
    v
  Pod

------------------------------------------------------------
STEP 1 - Create the Pod
------------------------------------------------------------

kubectl -n project-hamster run p2-pod \
  --image=nginx:1-alpine \
  --restart=Never

Check:

kubectl -n project-hamster get pod p2-pod

Wait if needed:

kubectl -n project-hamster wait \
  --for=condition=Ready pod/p2-pod \
  --timeout=120s

------------------------------------------------------------
STEP 2 - Create the Service
------------------------------------------------------------

kubectl -n project-hamster expose pod p2-pod \
  --name=p2-service \
  --port=3000 \
  --target-port=80

Verify:

kubectl -n project-hamster get pod,svc -o wide

Expected mapping:

  p2-service:3000
        |
        v
  p2-pod:80

------------------------------------------------------------
STEP 3 - Become root
------------------------------------------------------------

sudo -i

------------------------------------------------------------
STEP 4 - Check kube-proxy
------------------------------------------------------------

Find kube-proxy:

crictl ps | grep kube-proxy

Then:

crictl logs <KUBE-PROXY-CONTAINER-ID> | grep -i iptables

Look for:

  Using iptables proxy

The container ID varies.

------------------------------------------------------------
STEP 5 - Find iptables rules
------------------------------------------------------------

iptables-save | grep p2-service

Look for rules containing:

  project-hamster/p2-service

You may see chains such as:

  KUBE-SERVICES
  KUBE-SVC-XXXX
  KUBE-SEP-XXXX

Exact chain names and IPs vary.

------------------------------------------------------------
STEP 6 - Save the requested rules
------------------------------------------------------------

iptables-save | grep p2-service   > /opt/course/p2/iptables.txt

Verify:

cat /opt/course/p2/iptables.txt

------------------------------------------------------------
STEP 7 - Delete the Service
------------------------------------------------------------

kubectl -n project-hamster delete svc p2-service

------------------------------------------------------------
STEP 8 - Confirm the rules are gone
------------------------------------------------------------

iptables-save | grep p2-service

Expected:

  NO OUTPUT

This confirms kube-proxy removed the rules for the deleted
Service.

------------------------------------------------------------
WHY?
------------------------------------------------------------

When a Service is created:

  Service
     |
     v
  kube-apiserver
     |
     v
  kube-proxy observes the change
     |
     v
  kube-proxy programs iptables
     |
     v
  ClusterIP:3000 -> PodIP:80

When the Service is deleted:

  Service deleted
       |
       v
  kube-proxy observes deletion
       |
       v
  iptables rules removed

------------------------------------------------------------
CONCEPTUAL IPTABLES FLOW
------------------------------------------------------------

Client
  |
  | ClusterIP:3000
  v
KUBE-SERVICES
  |
  v
KUBE-SVC-XXXX
  |
  v
KUBE-SEP-XXXX
  |
  | DNAT
  v
PodIP:80

------------------------------------------------------------
USEFUL CKA COMMANDS
------------------------------------------------------------

Create Pod:

kubectl -n project-hamster run p2-pod \
  --image=nginx:1-alpine \
  --restart=Never

Create Service:

kubectl -n project-hamster expose pod p2-pod \
  --name=p2-service \
  --port=3000 \
  --target-port=80

Find kube-proxy:

crictl ps | grep kube-proxy

Check mode:

crictl logs <CONTAINER_ID> | grep -i iptables

Find Service rules:

iptables-save | grep p2-service

Save rules:

iptables-save | grep p2-service \
  > /opt/course/p2/iptables.txt

Delete Service:

kubectl -n project-hamster delete svc p2-service

Verify removal:

iptables-save | grep p2-service

------------------------------------------------------------
CKA MEMORY TRICK
------------------------------------------------------------

Service created
      |
      v
kube-proxy sees it
      |
      v
iptables rules created

Service deleted
      |
      v
kube-proxy sees deletion
      |
      v
iptables rules removed

============================================================
END SOLUTION
============================================================
EOF
