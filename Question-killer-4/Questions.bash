#!/bin/bash

cat <<'EOF'

======================================================================
Combined CKA Question 9 + 10
ServiceAccount, RBAC & Kubernetes API
======================================================================

Solve this question on:

    ssh cka9412


You are working in a Kubernetes cluster.

Starting from scratch, configure access for a ServiceAccount and use
it to access the Kubernetes API from inside a Pod.


TASK 1 — CREATE NAMESPACE
----------------------------------------------------------------------

Create a Namespace named:

    project-hamster


TASK 2 — CREATE SERVICEACCOUNT
----------------------------------------------------------------------

Create a ServiceAccount named:

    processor

in the project-hamster Namespace.


TASK 3 — CREATE ROLE
----------------------------------------------------------------------

Create a Role named:

    processor

in the project-hamster Namespace.

The Role must allow the processor ServiceAccount to ONLY create:

    - Secrets
    - ConfigMaps

It must not grant any other permissions.


TASK 4 — CREATE ROLEBINDING
----------------------------------------------------------------------

Create a RoleBinding named:

    processor

in the project-hamster Namespace.

Bind the Role:

    processor

to the ServiceAccount:

    processor


TASK 5 — CREATE POD
----------------------------------------------------------------------

Create a Pod named:

    api-contact

in the project-hamster Namespace using:

    nginx:1-alpine

The Pod must use the ServiceAccount:

    processor


TASK 6 — ACCESS KUBERNETES API
----------------------------------------------------------------------

Exec into the api-contact Pod.

Inside the Pod, use the ServiceAccount token located at:

    /var/run/secrets/kubernetes.io/serviceaccount/token

to authenticate with the Kubernetes API.


TASK 7 — QUERY ALL SECRETS
----------------------------------------------------------------------

Query ALL Secrets in the project-hamster Namespace using:

    https://kubernetes.default/api/v1/namespaces/project-hamster/secrets

The API request MUST be authenticated using the processor
ServiceAccount token.


TASK 8 — SAVE API RESPONSE
----------------------------------------------------------------------

Save the COMPLETE API response inside the Pod as:

    result.json


TASK 9 — COPY RESULT
----------------------------------------------------------------------

Copy the result.json file from the Pod to:

    /opt/course/9-10/result.json


TASK 10 — VERIFY RBAC
----------------------------------------------------------------------

Verify the RBAC permissions of the processor ServiceAccount.

The results must be:

    Action                    Expected
    ------------------------------------------------
    Create Secret             yes
    Create ConfigMap          yes
    Create Pod                no
    Delete Secret             no
    Get ConfigMap             no


IMPORTANT
----------------------------------------------------------------------

- Do NOT assume the Namespace already exists.
- Do NOT assume the ServiceAccount already exists.
- The RBAC configuration must be created from scratch.
- The API request MUST use the ServiceAccount token for authentication.
- The final API response MUST exist at:

    /opt/course/9-10/result.json


ServiceAccount token location inside the Pod:

    /var/run/secrets/kubernetes.io/serviceaccount/token

======================================================================
END OF QUESTION
======================================================================

EOF
