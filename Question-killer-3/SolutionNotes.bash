#!/bin/bash

cat <<'EOF'

============================================================
Question 5 — Solution Notes
Kustomize Configure HPA Autoscaler
============================================================

Goal:

Replace the old horizontal-scaling ConfigMap with an HPA.

Kustomize structure:

/opt/course/5/api-gateway/
├── base/
├── staging/
└── prod/


------------------------------------------------------------
STEP 1 — Inspect the existing configuration
------------------------------------------------------------

cd /opt/course/5/api-gateway

ls

kubectl kustomize base

kubectl kustomize staging

kubectl kustomize prod


The ConfigMap:

horizontal-scaling-config

exists in the base and is also patched by staging/prod.

Therefore, simply deleting it from base is not enough.


------------------------------------------------------------
STEP 2 — Remove the ConfigMap from BASE
------------------------------------------------------------

Remove:

base/horizontal-scaling-config.yaml

from:

base/kustomization.yaml

The base resources should no longer contain:

horizontal-scaling-config.yaml


------------------------------------------------------------
STEP 3 — Remove ConfigMap PATCHES
------------------------------------------------------------

The staging and prod overlays currently contain patches
for horizontal-scaling-config.

Remove these patch files:

staging/horizontal-scaling-config.yaml

prod/horizontal-scaling-config.yaml


And remove their references from:

staging/kustomization.yaml
prod/kustomization.yaml


Otherwise Kustomize will report an error because the
patch target no longer exists.


------------------------------------------------------------
STEP 4 — Create HPA in BASE
------------------------------------------------------------

Create:

base/hpa.yaml

with:

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


------------------------------------------------------------
STEP 5 — Add HPA to base kustomization
------------------------------------------------------------

Edit:

base/kustomization.yaml

Add:

  - hpa.yaml

Example:

resources:
  - serviceaccount.yaml
  - api-gateway.yaml
  - hpa.yaml


------------------------------------------------------------
STEP 6 — Configure production maxReplicas
------------------------------------------------------------

The base HPA has:

maxReplicas: 4

Staging should inherit this value.

Production needs:

maxReplicas: 6

Create:

prod/hpa.yaml

with:

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-gateway
spec:
  maxReplicas: 6


Then add it to:

prod/kustomization.yaml

using:

patches:
  - path: api-gateway.yaml
  - path: hpa.yaml


------------------------------------------------------------
STEP 7 — Test Kustomize output
------------------------------------------------------------

Build staging:

kubectl kustomize staging

Check:

kubectl kustomize staging | grep -A10 -B3 HorizontalPodAutoscaler


Build production:

kubectl kustomize prod

Check:

kubectl kustomize prod | grep -A10 -B3 HorizontalPodAutoscaler


Expected:

STAGING:

maxReplicas: 4

PROD:

maxReplicas: 6


------------------------------------------------------------
STEP 8 — Make sure ConfigMap is gone
------------------------------------------------------------

Check:

kubectl kustomize staging | grep horizontal-scaling-config

kubectl kustomize prod | grep horizontal-scaling-config

There should be no output.


------------------------------------------------------------
STEP 9 — Apply staging
------------------------------------------------------------

kubectl kustomize staging | kubectl apply -f


Verify:

kubectl -n api-gateway-staging get hpa


Expected:

NAME           REFERENCE                TARGETS
api-gateway    Deployment/api-gateway   ...


Check:

kubectl -n api-gateway-staging get hpa api-gateway \
  -o jsonpath='{.spec.minReplicas}'; echo

Expected:

2


Check:

kubectl -n api-gateway-staging get hpa api-gateway \
  -o jsonpath='{.spec.maxReplicas}'; echo

Expected:

4


------------------------------------------------------------
STEP 10 — Apply production
------------------------------------------------------------

kubectl kustomize prod | kubectl apply -f


Verify:

kubectl -n api-gateway-prod get hpa


Check:

kubectl -n api-gateway-prod get hpa api-gateway \
  -o jsonpath='{.spec.maxReplicas}'; echo

Expected:

6


------------------------------------------------------------
STEP 11 — Delete the old ConfigMaps
------------------------------------------------------------

Kustomize does not automatically delete a resource that
was previously applied but has now been removed from the
Kustomize configuration.

Therefore manually delete the old ConfigMaps:

kubectl -n api-gateway-staging delete configmap \
  horizontal-scaling-config

kubectl -n api-gateway-prod delete configmap \
  horizontal-scaling-config


------------------------------------------------------------
STEP 12 — Final verification
------------------------------------------------------------

kubectl -n api-gateway-staging get hpa

kubectl -n api-gateway-prod get hpa

kubectl -n api-gateway-staging get cm

kubectl -n api-gateway-prod get cm


Expected:

STAGING HPA:
minReplicas = 2
maxReplicas = 4
CPU = 50%

PROD HPA:
minReplicas = 2
maxReplicas = 6
CPU = 50%

horizontal-scaling-config:
NOT FOUND


------------------------------------------------------------
IMPORTANT CKA POINT
------------------------------------------------------------

Kustomize builds Kubernetes YAML.

It does not maintain state like Helm.

Therefore:

kubectl kustomize ...
| kubectl apply -f -

will create/update resources represented by the
current Kustomize output.

However, when a resource is removed from the Kustomize
configuration, Kustomize does not automatically know
that it should delete the old remote resource.

Therefore the old ConfigMap must be deleted manually.


============================================================
END OF SOLUTION
============================================================

EOF
