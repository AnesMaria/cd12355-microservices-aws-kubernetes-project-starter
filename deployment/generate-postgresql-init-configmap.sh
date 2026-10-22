#!/usr/bin/env bash
set -euo pipefail

# Execute from the repository root with kubectl connected to the target cluster.
# The ConfigMap is under Kubernetes' ~1 MiB object size recommendation.
kubectl create configmap coworking-db-init \
  --from-file=db/1_create_tables.sql \
  --from-file=db/2_seed_users.sql \
  --from-file=db/3_seed_tokens.sql \
  --dry-run=client -o yaml > deployment/postgresql-init-configmap.yaml

echo "Generated deployment/postgresql-init-configmap.yaml."
echo "Apply the file only after the EKS nodes are Ready."
