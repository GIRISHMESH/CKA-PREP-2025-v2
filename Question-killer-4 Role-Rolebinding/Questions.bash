#!/bin/bash
cat <<'EOF'
### ======================================================================
### CKA Question — ServiceAccount, RBAC & Kubernetes API
### Solve this question on:
###     ssh cka9412
### TASK 1 — NAMESPACE
### Create a Namespace:
###     project-hamster
### TASK 2 — SERVICEACCOUNT
### Create a ServiceAccount:
###     processor
### in:
###     project-hamster
### TASK 3 — ROLE
### Create a Role named:
###     processor
### Allow ONLY:
###     create Secrets
###     create ConfigMaps
### TASK 4 — ROLEBINDING
### Create a RoleBinding named:
###     processor
### Bind the Role to:
###     ServiceAccount: processor
### TASK 5 — POD
### Create a Pod named:
###     api-contact
### in:
###     project-hamster
### Use image:
###     nginx:1-alpine
### Use ServiceAccount:
###     processor
### TASK 6 — KUBERNETES API
### Exec into the Pod and use the ServiceAccount token to access:
###     https://kubernetes.default/api/v1/namespaces/project-hamster/secrets
### Save the complete API response as:
###     result.json
### TASK 7 — COPY RESULT
### Copy result.json from the Pod to:
###     /opt/course/9-10/result.json
### TASK 8 — VERIFY RBAC
### Verify that processor can:
###     Create Secret       YES
###     Create ConfigMap    YES
###     Create Pod          NO
###     Delete Secret       NO
###     Get ConfigMap       NO
### IMPORTANT
### - Configure everything from scratch.
### - Use the ServiceAccount token for API authentication.
### - The final file must exist at:
###     /opt/course/9-10/result.json
### ======================================================================
### END OF QUESTION
### ======================================================================
EOF
