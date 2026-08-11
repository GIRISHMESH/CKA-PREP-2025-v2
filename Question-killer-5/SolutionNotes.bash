#!/usr/bin/env bash

cat <<'EOF'
============================================================
CKA QUESTION 15 - SOLUTION NOTES
============================================================

Core idea:

  NetworkPolicy controls NETWORK traffic.

  RBAC controls Kubernetes API access.

Here we need EGRESS because traffic is leaving the backend Pod.

------------------------------------------------------------
1. Create the NetworkPolicy
------------------------------------------------------------

cat > /tmp/15_np.yaml <<'YAML'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-backend
  namespace: project-snake

spec:
  podSelector:
    matchLabels:
      app: backend

  policyTypes:
    - Egress

  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db1
      ports:
        - protocol: TCP
          port: 1111

    - to:
        - podSelector:
            matchLabels:
              app: db2
      ports:
        - protocol: TCP
          port: 2222
YAML

kubectl apply -f /tmp/15_np.yaml

------------------------------------------------------------
2. Why are there TWO egress rules?
------------------------------------------------------------

Rule 1 means:

  destination app=db1
  AND
  TCP port=1111

Rule 2 means:

  destination app=db2
  AND
  TCP port=2222

Multiple rules are effectively ORed:

  (db1 AND 1111)
       OR
  (db2 AND 2222)

This is exactly what the question asks.

------------------------------------------------------------
3. The common WRONG policy
------------------------------------------------------------

Do NOT write:

  egress:
    - to:
        - podSelector:
            matchLabels:
              app: db1
        - podSelector:
            matchLabels:
              app: db2
      ports:
        - protocol: TCP
          port: 1111
        - protocol: TCP
          port: 2222

That means:

  (db1 OR db2)
       AND
  (1111 OR 2222)

It can therefore allow combinations you did not intend,
such as db1:2222 or db2:1111.

------------------------------------------------------------
4. Verify the policy
------------------------------------------------------------

kubectl -n project-snake get networkpolicy

kubectl -n project-snake describe networkpolicy np-backend

------------------------------------------------------------
5. Test connectivity
------------------------------------------------------------

Get the current Pod IPs:

DB1_IP="$(kubectl -n project-snake get pod db1-0 -o jsonpath='{.status.podIP}')"
DB2_IP="$(kubectl -n project-snake get pod db2-0 -o jsonpath='{.status.podIP}')"
VAULT_IP="$(kubectl -n project-snake get pod vault-0 -o jsonpath='{.status.podIP}')"

echo "DB1:   ${DB1_IP}"
echo "DB2:   ${DB2_IP}"
echo "VAULT: ${VAULT_IP}"

echo
echo "Allowed #1: backend -> db1:1111"
kubectl -n project-snake exec backend-0 -- \
  curl -s --max-time 5 "${DB1_IP}:1111"

echo
echo "Allowed #2: backend -> db2:2222"
kubectl -n project-snake exec backend-0 -- \
  curl -s --max-time 5 "${DB2_IP}:2222"

echo
echo "Blocked: backend -> vault:3333"
kubectl -n project-snake exec backend-0 -- \
  curl -s --max-time 5 "${VAULT_IP}:3333" || true

------------------------------------------------------------
6. CKA MEMORY TRICK
------------------------------------------------------------

NetworkPolicy:

  podSelector = WHO is controlled

  egress = traffic LEAVING the selected Pod

  ingress = traffic ENTERING the selected Pod

Inside one rule:

  to + ports
      =
  destination AND port

Multiple rules:

  rule1 OR rule2 OR rule3

Therefore:

  egress:
    - to: db1
      ports: 1111

    - to: db2
      ports: 2222

means:

  db1:1111 OR db2:2222

------------------------------------------------------------
7. Final expected behavior
------------------------------------------------------------

backend -> db1:1111       ALLOWED
backend -> db2:2222       ALLOWED
backend -> vault:3333     BLOCKED

============================================================
END SOLUTION
============================================================
EOF
