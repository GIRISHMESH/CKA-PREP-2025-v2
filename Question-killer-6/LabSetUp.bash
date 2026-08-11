#!/usr/bin/env bash
set -euo pipefail

kubectl create namespace project-hamster \
  --dry-run=client -o yaml | kubectl apply -f -

mkdir -p /opt/course/p2

echo "Lab environment ready."
echo "Now run: bash Questions.bash"
