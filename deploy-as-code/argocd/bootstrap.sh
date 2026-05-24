#!/usr/bin/env bash
# ==============================================================================
# ArgoCD Bootstrap Script — PostPilot Production
#
# Run this ONCE from your local machine (or Cloud Shell) after the GKE cluster
# is provisioned by Terraform.  It installs ArgoCD + Image Updater, configures
# Workload Identity auth for Artifact Registry, wires GitHub credentials, and
# applies the root App-of-Apps so ArgoCD takes over all subsequent deploys.
#
# Usage:
#   chmod +x bootstrap.sh
#   ./bootstrap.sh
#
# Prerequisites:
#   - gcloud CLI authenticated with enough permissions (container.admin, iam.admin)
#   - kubectl, helm, and base64 installed
#   - A GitHub Personal Access Token (or SSH private key) with read access to
#     the DevSecOps repo
# ==============================================================================
set -euo pipefail

# ── CONFIG ────────────────────────────────────────────────────────────────────
PROJECT_ID="postpilot-0"
CLUSTER_NAME="postpilot-prod"
CLUSTER_ZONE="asia-south1"
ARGOCD_VERSION="7.3.4"            # helm chart version (maps to ArgoCD 2.11.x)
IMAGE_UPDATER_VERSION="0.12.2"    # argocd-image-updater manifest version

# The existing GSA (provisioned by Terraform) that already has artifactregistry.reader
PROD_GSA="postpilot-prod-gke-sa@${PROJECT_ID}.iam.gserviceaccount.com"

# GitHub repo that ArgoCD will watch (the DevSecOps repo)
REPO_URL="https://github.com/edwinkullu/DevSecOps.git"

# Set GITHUB_TOKEN before running, e.g.:  export GITHUB_TOKEN=ghp_xxx
: "${GITHUB_TOKEN:?ERROR: Set GITHUB_TOKEN to a PAT with repo:read scope}"

echo "──────────────────────────────────────────────"
echo "  PostPilot ArgoCD Bootstrap"
echo "  Cluster : ${CLUSTER_NAME} (${CLUSTER_ZONE})"
echo "  Project : ${PROJECT_ID}"
echo "──────────────────────────────────────────────"

# ── 1. CONNECT TO CLUSTER ─────────────────────────────────────────────────────
echo ""
echo "[1/8] Connecting to GKE cluster..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" \
  --zone "${CLUSTER_ZONE}" \
  --project "${PROJECT_ID}"

# ── 2. INSTALL ARGOCD VIA HELM ────────────────────────────────────────────────
echo ""
echo "[2/8] Installing ArgoCD (helm chart ${ARGOCD_VERSION})..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

helm repo add argo https://argoproj.github.io/argo-helm --force-update
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --version "${ARGOCD_VERSION}" \
  --set global.nodeSelector."kubernetes\.io/os"=linux \
  --set configs.params."server\.insecure"=true \
  --set server.service.type=ClusterIP \
  --wait --timeout 5m

echo "✓ ArgoCD installed"

# ── 3. INSTALL ARGOCD IMAGE UPDATER ──────────────────────────────────────────
echo ""
echo "[3/8] Installing ArgoCD Image Updater (${IMAGE_UPDATER_VERSION})..."
kubectl apply -n argocd \
  -f "https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/v${IMAGE_UPDATER_VERSION}/manifests/install.yaml"

echo "✓ Image Updater installed"

# ── 4. WORKLOAD IDENTITY: BIND IMAGE UPDATER SA TO PROD GSA ──────────────────
echo ""
echo "[4/8] Configuring Workload Identity for argocd-image-updater..."

# Allow the argocd-image-updater KSA to impersonate the prod GSA
gcloud iam service-accounts add-iam-policy-binding "${PROD_GSA}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:${PROJECT_ID}.svc.id.goog[argocd/argocd-image-updater]"

# Annotate the KSA so the metadata server issues tokens for the GSA
kubectl annotate serviceaccount argocd-image-updater \
  --namespace argocd \
  --overwrite \
  "iam.gke.io/gcp-service-account=${PROD_GSA}"

# Restart so the projected token volume is re-mounted with the new annotation
kubectl rollout restart deployment/argocd-image-updater -n argocd

echo "✓ Workload Identity bound"

# ── 5. APPLY IMAGE UPDATER REGISTRY CONFIG ────────────────────────────────────
echo ""
echo "[5/8] Configuring Image Updater registry (Artifact Registry)..."
kubectl apply -f "$(dirname "$0")/image-updater-registries.yaml"

# The gcloud-auth.sh script is in the ConfigMap but must be mounted into the pod
# at /scripts/ with execute permission (defaultMode 0755 = 493 decimal).
# Patch the Deployment to add this volume + volumeMount if not already present.
if ! kubectl get deployment argocd-image-updater -n argocd \
    -o jsonpath='{.spec.template.spec.volumes[*].name}' | grep -q "scripts"; then
  kubectl patch deployment argocd-image-updater -n argocd --type=json -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/volumes/-",
      "value": {
        "name": "scripts",
        "configMap": {
          "name": "argocd-image-updater-config",
          "defaultMode": 493,
          "items": [{"key": "gcloud-auth.sh", "path": "gcloud-auth.sh"}]
        }
      }
    },
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/volumeMounts/-",
      "value": {
        "name": "scripts",
        "mountPath": "/scripts"
      }
    }
  ]'
  echo "  Deployment patched to mount /scripts"
fi

kubectl rollout restart deployment/argocd-image-updater -n argocd
kubectl rollout status deployment/argocd-image-updater -n argocd --timeout=120s

echo "✓ Registry config applied"

# ── 6. ADD GITHUB REPO CREDENTIALS TO ARGOCD ─────────────────────────────────
echo ""
echo "[6/8] Adding GitHub repository credentials to ArgoCD..."

# Encode credentials for the Kubernetes secret
REPO_USERNAME="edwinkullu"
REPO_PASSWORD_B64=$(echo -n "${GITHUB_TOKEN}" | base64)
REPO_URL_B64=$(echo -n "${REPO_URL}" | base64)
REPO_USER_B64=$(echo -n "${REPO_USERNAME}" | base64)

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: postpilot-devsecops-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
data:
  url: ${REPO_URL_B64}
  username: ${REPO_USER_B64}
  password: ${REPO_PASSWORD_B64}
EOF

echo "✓ GitHub credentials registered"

# ── 7. BOOTSTRAP ROOT APP-OF-APPS ─────────────────────────────────────────────
echo ""
echo "[7/8] Applying root App-of-Apps..."

# Wait for ArgoCD CRDs to be ready before applying the Application resource
kubectl wait --for=condition=established crd/applications.argoproj.io --timeout=120s

kubectl apply -f "$(dirname "$0")/root-app.yaml"

echo "✓ Root app applied — ArgoCD will now sync all PostPilot services"

# ── 8. PRINT ACCESS INFO ──────────────────────────────────────────────────────
echo ""
echo "[8/8] Retrieving initial admin password..."
ARGOCD_PASS=$(kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "════════════════════════════════════════════════"
echo "  ArgoCD bootstrap complete!"
echo ""
echo "  Access ArgoCD UI via port-forward:"
echo "    kubectl port-forward svc/argocd-server -n argocd 8080:80"
echo "    Open: http://localhost:8080"
echo ""
echo "  Initial credentials:"
echo "    Username : admin"
echo "    Password : ${ARGOCD_PASS}"
echo ""
echo "  Change password immediately:"
echo "    argocd login localhost:8080 --username admin --insecure"
echo "    argocd account update-password"
echo "════════════════════════════════════════════════"
