#!/bin/bash
# Plan Terraform for a specific environment
# Usage: ./scripts/plan.sh <env>   (e.g. dev, staging, prod)
set -euo pipefail

ENV=${1:-}
if [ -z "$ENV" ]; then
  echo "Usage: $0 <env>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}/../environments/${ENV}"
terraform plan -out=tfplan
