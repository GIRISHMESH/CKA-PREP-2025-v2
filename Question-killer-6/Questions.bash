#!/usr/bin/env bash

cat <<'EOF'
============================================================
CKA QUESTION 2 - KUBE-PROXY / IPTABLES
============================================================

Connect to:
  ssh cka3962

Namespace:
  project-hamster

Scenario:
  Confirm that kube-proxy is running correctly and is
  programming iptables rules for a Kubernetes Service.

TASKS
-----

1. Create a Pod named:

     p2-pod

   using image:

     nginx:1-alpine

2. Create a Service named:

     p2-service

   Requirements:
     - ClusterIP Service
     - Service port: 3000
     - target Pod port: 80

   Mapping:

     p2-service:3000 -> p2-pod:80

3. On node cka3962, find the iptables rules belonging
   to p2-service.

4. Save those matching rules to:

     /opt/course/p2/iptables.txt

5. Delete the Service p2-service.

6. Confirm that the iptables rules belonging to
   p2-service are gone.

OPTIONAL CHECK
--------------

Find the kube-proxy container with:

  crictl ps | grep kube-proxy

Then inspect its logs and confirm that kube-proxy is
using iptables.

EXPECTED RESULT
---------------

Before deleting the Service:

  iptables-save | grep p2-service

should show matching rules.

After deleting the Service:

  iptables-save | grep p2-service

should produce no output.

IMPORTANT
---------

Do not hard-code ClusterIP or Pod IP addresses.

The exact IP addresses and iptables chain names vary.

Do not look at SolutionNotes.bash until you have attempted
the task yourself.

============================================================
EOF
