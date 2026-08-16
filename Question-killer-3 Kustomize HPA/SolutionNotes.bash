#!/bin/bash

cat <<'EOF'

============================================================
Question 5 — Solution
Kustomize Configure HPA Autoscaler
============================================================

cd /opt/course/5/api-gateway

------------------------------------------------------------
STEP 1 — Inspect
------------------------------------------------------------

ls
kubectl kustomize base
kubectl kustomize staging
kubectl kustomize prod

------------------------------------------------------------
STEP 2 — Remove old ConfigMap
------------------------------------------------------------

rm -f base/horizontal-scaling-config.yaml
rm -f staging/horizontal-scaling-config.yaml
rm -f prod/horizontal-scaling-config.yaml

------------------------------------------------------------
STEP 3 — Edit Kustomization files
------------------------------------------------------------

Remove references to:

horizontal-scaling-config.yaml

from:

base/kustomization.yaml
staging/kustomization.yaml
prod/kustomization.yaml

------------------------------------------------------------
STEP 4 — Create HPA
------------------------------------------------------------

cat > base/hpa.yaml <<'EOF2'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api-gateway
  minReplicas: 2
  maxReplicas: 4
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
EOF2

------------------------------------------------------------
STEP 5 — Add HPA to BASE
------------------------------------------------------------

Add to:

base/kustomization.yaml

resources:
  - hpa.yaml

------------------------------------------------------------
STEP 6 — Production HPA
------------------------------------------------------------

cat > prod/hpa.yaml <<'EOF2'
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6
EOF2

Add to:

prod/kustomization.yaml

patches:
  - path: hpa.yaml

------------------------------------------------------------
STEP 7 — Validate
------------------------------------------------------------

kubectl kustomize staging
kubectl kustomize prod

kubectl kustomize staging | grep -A10 -B3 HorizontalPodAutoscaler
kubectl kustomize prod | grep -A10 -B3 HorizontalPodAutoscaler

kubectl kustomize staging | grep horizontal-scaling-config
kubectl kustomize prod | grep horizontal-scaling-config

------------------------------------------------------------
STEP 8 — Apply STAGING
------------------------------------------------------------

kubectl kustomize staging | kubectl apply -f -

kubectl -n api-gateway-staging get hpa

kubectl -n api-gateway-staging get hpa api-gateway \
  -o jsonpath='{.spec.minReplicas}'; echo

kubectl -n api-gateway-staging get hpa api-gateway \
  -o jsonpath='{.spec.maxReplicas}'; echo

------------------------------------------------------------
STEP 9 — Apply PRODUCTION
------------------------------------------------------------

kubectl kustomize prod | kubectl apply -f -

kubectl -n api-gateway-prod get hpa

kubectl -n api-gateway-prod get hpa api-gateway \
  -o jsonpath='{.spec.minReplicas}'; echo

kubectl -n api-gateway-prod get hpa api-gateway \
  -o jsonpath='{.spec.maxReplicas}'; echo

------------------------------------------------------------
STEP 10 — Delete old ConfigMaps
------------------------------------------------------------

kubectl -n api-gateway-staging delete configmap \
  horizontal-scaling-config --ignore-not-found

kubectl -n api-gateway-prod delete configmap \
  horizontal-scaling-config --ignore-not-found

------------------------------------------------------------
STEP 11 — Final Verification
------------------------------------------------------------

kubectl -n api-gateway-staging get hpa
kubectl -n api-gateway-prod get hpa

kubectl -n api-gateway-staging get configmap
kubectl -n api-gateway-prod get configmap

kubectl -n api-gateway-staging get hpa api-gateway \
  -o jsonpath='{.spec.minReplicas}{" "}{.spec.maxReplicas}{" "}{.spec.metrics[0].resource.target.averageUtilization}'; echo

kubectl -n api-gateway-prod get hpa api-gateway \
  -o jsonpath='{.spec.minReplicas}{" "}{.spec.maxReplicas}{" "}{.spec.metrics[0].resource.target.averageUtilization}'; echo

============================================================
Expected
============================================================

STAGING:
minReplicas = 2
maxReplicas = 4
CPU = 50%

PRODUCTION:
minReplicas = 2
maxReplicas = 6
CPU = 50%

horizontal-scaling-config:
NOT FOUND

============================================================
END OF SOLUTION
============================================================

EOF
