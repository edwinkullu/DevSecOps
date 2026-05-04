#!/bin/bash
# Initialize Terraform for a specific environment
# Usage: ./scripts/init.sh <env>   (e.g. dev, staging, prod)
set -euo pipefail

ENV=${1:-}
if [ -z "$ENV" ]; then
  echo "Usage: $0 <env>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_VARS="${SCRIPT_DIR}/../environments/${ENV}/terraform.tfvars"

# Extract bucket name from the environment's terraform.tfvars
if [ -f "$ENV_VARS" ]; then
  BUCKET=$(grep '^bucket\s*=' "$ENV_VARS" | cut -d'=' -f2 | tr -d ' "' | xargs)
else
  echo "Error: terraform.tfvars not found for environment $ENV at $ENV_VARS"
  exit 1
fi

if [ -z "$BUCKET" ]; then
  echo "Error: 'bucket' not defined in $ENV_VARS"
  exit 1
fi

echo "Initializing environment: $ENV using bucket: $BUCKET"

cd "${SCRIPT_DIR}/../environments/${ENV}"
terraform init -backend-config="bucket=${BUCKET}"
