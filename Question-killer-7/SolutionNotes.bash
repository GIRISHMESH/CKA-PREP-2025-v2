#!/usr/bin/env bash

cat <<'EOF'

============================================================
SOLUTION — CHANGE SERVICE CIDR
============================================================

Goal:

  Existing Service
       |
       +--> keeps old ClusterIP

  New Service
       |
       +--> receives IP from 11.96.0.0/12


============================================================
STEP 1 — CREATE THE POD
============================================================

Create:

  check-ip

Image:

  httpd:2-alpine

Command:

  kubectl run check-ip --image=httpd:2-alpine

Verify:

  kubectl get pod check-ip

Expected:

  NAME       READY   STATUS
  check-ip   1/1     Running


============================================================
STEP 2 — CREATE THE FIRST SERVICE
============================================================

Create:

  check-ip-service

Port:

  80

Command:

  kubectl expose pod check-ip \
    --name=check-ip-service \
    --port=80

Verify:

  kubectl get svc

Example:

  NAME               TYPE        CLUSTER-IP     PORT(S)
  check-ip-service   ClusterIP   10.97.6.41     80/TCP

IMPORTANT:

Record the ClusterIP.

For example:

  10.97.6.41

Your cluster will probably have a different IP.


============================================================
STEP 3 — UNDERSTAND THE CURRENT SERVICE CIDR
============================================================

Check kube-apiserver:

  grep service-cluster-ip-range \
    /etc/kubernetes/manifests/kube-apiserver.yaml

You will normally see:

  --service-cluster-ip-range=10.96.0.0/12

This is the old Service CIDR.


============================================================
STEP 4 — BECOME ROOT
============================================================

Run:

  sudo -i


============================================================
STEP 5 — CHANGE KUBE-APISERVER SERVICE CIDR
============================================================

Edit:

  vim /etc/kubernetes/manifests/kube-apiserver.yaml

Find:

  - --service-cluster-ip-range=10.96.0.0/12

Change to:

  - --service-cluster-ip-range=11.96.0.0/12

Save and exit.

Because kube-apiserver is a static Pod, kubelet will
detect the manifest change and restart it.


============================================================
STEP 6 — WAIT FOR KUBE-APISERVER
============================================================

Check:

  kubectl -n kube-system get pods | grep kube-apiserver

Wait until the kube-apiserver Pod is:

  1/1 Running


============================================================
STEP 7 — CHANGE KUBE-CONTROLLER-MANAGER
============================================================

Check:

  grep service-cluster-ip-range \
    /etc/kubernetes/manifests/kube-controller-manager.yaml

Find:

  - --service-cluster-ip-range=10.96.0.0/12

Edit:

  vim /etc/kubernetes/manifests/kube-controller-manager.yaml

Change to:

  - --service-cluster-ip-range=11.96.0.0/12

Save and exit.


============================================================
STEP 8 — WAIT FOR CONTROLLER MANAGER
============================================================

Check:

  kubectl -n kube-system get pods | \
    grep kube-controller-manager

Wait until it is:

  1/1 Running


============================================================
STEP 9 — CHECK SERVICECIDR
============================================================

Run:

  kubectl get servicecidr

You may see:

  NAME         CIDRS
  kubernetes   10.96.0.0/12

The old ServiceCIDR represents the existing range.


============================================================
STEP 10 — CREATE THE NEW SERVICECIDR
============================================================

Create a ServiceCIDR for the new range:

  cat <<'EOF2' | kubectl apply -f -
  apiVersion: networking.k8s.io/v1
  kind: ServiceCIDR
  metadata:
    name: svc-cidr-new
  spec:
    cidrs:
    - 11.96.0.0/12
  EOF2

Check:

  kubectl get servicecidr

Expected conceptually:

  NAME           CIDRS
  kubernetes     10.96.0.0/12
  svc-cidr-new   11.96.0.0/12


============================================================
STEP 11 — DO NOT DELETE THE FIRST SERVICE
============================================================

Check:

  kubectl get svc

You should still see:

  check-ip-service

with its original ClusterIP.

For example:

  check-ip-service   ClusterIP   10.97.6.41


IMPORTANT:

The existing Service is NOT renumbered.

Its IP remains the same.


============================================================
STEP 12 — OPTIONAL: CHECK THE OLD SERVICECIDR
============================================================

You may attempt:

  kubectl delete servicecidr kubernetes

However, the old ServiceCIDR may remain in:

  Terminating

because existing Services still use IP addresses from
the old CIDR.

This is expected.

Do NOT delete the existing Services just to remove the
old ServiceCIDR.


============================================================
STEP 13 — CREATE THE SECOND SERVICE
============================================================

The Pod is still:

  check-ip

Create another Service:

  kubectl expose pod check-ip \
    --name=check-ip-service2 \
    --port=80

Check:

  kubectl get svc


============================================================
STEP 14 — VERIFY THE RESULT
============================================================

You should see something conceptually like:

  NAME                TYPE        CLUSTER-IP       PORT(S)
  check-ip-service    ClusterIP   10.97.6.41       80/TCP
  check-ip-service2   ClusterIP   11.108.174.69    80/TCP
  kubernetes          ClusterIP   10.96.0.1        443/TCP


The exact IPs will vary.

The important part is:

  check-ip-service
        |
        +--> OLD IP
             10.x.x.x

  check-ip-service2
        |
        +--> NEW IP
             11.x.x.x


============================================================
STEP 15 — VERIFY THE NEW IP IS IN THE NEW CIDR
============================================================

For example, if:

  check-ip-service2 = 11.108.174.69

Then verify that it belongs to:

  11.96.0.0/12

The first Service should still have its original IP.


============================================================
WHAT HAPPENED?
============================================================

Initially:

  Service CIDR
      |
      +--> 10.96.0.0/12

  check-ip-service
      |
      +--> 10.x.x.x


After changing the configuration:

  Service CIDR
      |
      +--> 11.96.0.0/12


Existing Service:

  check-ip-service
      |
      +--> OLD 10.x.x.x
            |
            +--> unchanged


New Service:

  check-ip-service2
      |
      +--> NEW 11.x.x.x


============================================================
IMPORTANT COMPONENTS
============================================================

kube-apiserver:

  --service-cluster-ip-range=11.96.0.0/12


kube-controller-manager:

  --service-cluster-ip-range=11.96.0.0/12


ServiceCIDR:

  apiVersion: networking.k8s.io/v1
  kind: ServiceCIDR

  spec:
    cidrs:
    - 11.96.0.0/12


============================================================
CKA MEMORY TRICK
============================================================

Service CIDR change:

  kube-apiserver
        +
  kube-controller-manager
        +
  ServiceCIDR
        |
        v
  NEW Services get IPs
  from the NEW range


Existing Services:

  KEEP their existing ClusterIP


============================================================
FINAL CHECK
============================================================

Run:

  kubectl get pod
  kubectl get svc
  kubectl get servicecidr

You should have:

  Pod:
    check-ip

  Services:
    check-ip-service
    check-ip-service2

  ServiceCIDRs:
    old CIDR
    new CIDR

And most importantly:

  check-ip-service2
       |
       +--> 11.x.x.x

============================================================
END SOLUTION
============================================================

EOF
