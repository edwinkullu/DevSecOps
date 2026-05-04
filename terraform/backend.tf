# NOTE: This root-level backend.tf is intentionally left as documentation only.
# Each environment (dev / staging / prod) configures its own backend in:
#   environments/<env>/backend.tf
#
# Do NOT run `terraform init` directly from this root directory.
# Instead, use the helper scripts:
#   ./scripts/init.sh <env>
#   ./scripts/plan.sh <env>
#   ./scripts/apply.sh <env>
