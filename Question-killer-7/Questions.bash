#!/usr/bin/env bash

cat <<'EOF'

============================================================
CKA QUESTION — CHANGE SERVICE CIDR
============================================================

Connect to:
  ssh cka9412

Namespace:
  default

------------------------------------------------------------
TASK
------------------------------------------------------------

1. Create a Pod named:

     check-ip

   using image:

     httpd:2-alpine


2. Expose the Pod using a ClusterIP Service named:

     check-ip-service

   on port:

     80

   Record the ClusterIP assigned to this Service.


3. Change the cluster Service CIDR to:

     11.96.0.0/12


4. Create a second Service named:

     check-ip-service2

   pointing to the same Pod on port 80.


5. Verify that:

     check-ip-service

   keeps its original ClusterIP.


6. Verify that:

     check-ip-service2

   receives a ClusterIP from:

     11.96.0.0/12


------------------------------------------------------------
IMPORTANT
------------------------------------------------------------

The first Service already exists before the CIDR change.

Its ClusterIP must NOT change.

Do not delete the first Service.

The second Service must receive an IP from the new
Service CIDR.

------------------------------------------------------------
EXPECTED FINAL STATE
------------------------------------------------------------

You should have:

  Pod:
    check-ip

  Services:
    check-ip-service
    check-ip-service2

The first Service:

    check-ip-service
          |
          +-- old Service CIDR IP

The second Service:

    check-ip-service2
          |
          +-- 11.x.x.x

------------------------------------------------------------
HELPFUL COMMANDS
------------------------------------------------------------

Inspect kube-apiserver:

  grep service-cluster-ip-range \
    /etc/kubernetes/manifests/kube-apiserver.yaml

Inspect kube-controller-manager:

  grep service-cluster-ip-range \
    /etc/kubernetes/manifests/kube-controller-manager.yaml

Inspect ServiceCIDRs:

  kubectl get servicecidr

Inspect Services:

  kubectl get svc

------------------------------------------------------------
IMPORTANT CKA POINT
------------------------------------------------------------

Changing the Service CIDR does NOT renumber existing
Services.

Existing Service:

  old ClusterIP
       |
       +-- remains unchanged

New Service:

  new ClusterIP
       |
       +-- comes from 11.96.0.0/12

------------------------------------------------------------
DO NOT READ THE SOLUTION UNTIL YOU ATTEMPT IT.
------------------------------------------------------------

EOF
