# Secret Management Guide (Zero-Touch Sync)

This guide explains how to manage application secrets using the **External Secrets Operator (ESO)** and **Google Secret Manager (GSM)** without modifying any Helm charts or Git code.

---

## 🏗️ How it Works
Your microservices are configured to automatically "discover" secrets in Google Secret Manager based on **Labels**. 

When you add a secret with the correct label, it is mirrored into your GKE cluster within **60 seconds**.

---

## 🏷️ Applying Labels in GCP

Each secret in the Google Cloud Console must have the following labels to be discovered:

| Label Key | Value | Result |
| :--- | :--- | :--- |
| `postpilot-service` | `[service-name]` | Only synced to that specific service (e.g. `ai-service`). |
| `postpilot-service` | `global` | Synced to **ALL** microservices in the cluster. |
| `postpilot-env` | `stage` or `prod` | **REQUIRED:** Ensures secrets are only synced to the correct environment. |
| `postpilot-sync` | `true` | Required for the discovery logic to activate. |

---

## 🔄 Automatic Variable Renaming (Aliasing)

If your application expects a common environment variable name (like `API_KEY`) but you have different values for different services in Secret Manager, use the **Naming Convention** below.

### 1. Automated Mapping (Recommended)
The system automatically strips the service name prefix from the secret. This allows multiple services to use the same internal variable name with different external secret names.

**Convention:** `[SERVICE_NAME]_[VAR_NAME]` or `[service-name]-[VAR_NAME]`

| Secret Name in GSM | Target Var in Application |
| :--- | :--- |
| `WEB_SERVICE_API_KEY` | `API_KEY` |
| `AI_SERVICE_API_KEY` | `API_KEY` |
| `ai-service-DB_PASSWORD` | `DB_PASSWORD` |

### 2. Explicit Mapping (Advanced)
If you cannot follow the naming convention, you can manually map a secret in the service's `values.yaml`:

```yaml
gsm:
  mappings:
    - secretKey: API_KEY        # Name inside the container
      remoteKey: my_custom_key  # Name in Secret Manager
```

---

## 🛠️ Management via CLI

### 1. Create and Label a NEW Secret
```powershell
# Create the secret
gcloud secrets create my-new-password --project="glassy-storm-491011-q6"

# Label it for discovery (example for UAT)
gcloud secrets update my-new-password `
    --project="glassy-storm-491011-q6" `
    --update-labels="postpilot-service=ai-service,postpilot-env=stage,postpilot-sync=true"
```

### 2. Update an EXISTING Secret
```powershell
gcloud secrets update existing-secret `
    --project="glassy-storm-491011-q6" `
    --update-labels="postpilot-service=global,postpilot-env=stage,postpilot-sync=true"
```

---

## 🔍 Verification in GKE

Once labeled, you can verify the synchronization in your Kubernetes cluster:

```powershell
# 1. Check the sync status (Status should be 'SecretSynced')
kubectl get externalsecret -n postpilot

# 2. Verify the native Secret object exists
kubectl get secret ai-service-gsm-sync -n postpilot -o yaml

# 3. Check environment variables in a running Pod
kubectl exec -it [POD_NAME] -n postpilot -- printenv | grep PASSWORD
```

---

## ⚠️ Security Notes
- **RBAC**: Only the `postpilot-app-sa` identity has permission to read secrets labeled for this project.
- **Rotation**: If you create a new **version** of a secret in GCP, it will automatically update in GKE within 60 seconds.
- **Cleanup**: Deleting a label in GCP will cause the secret to be removed from the Kubernetes pods (once the cache expires).

---

## 🚀 Initializing New Environments

### 1. Individual Service Sync
Run the script against a `.env` file (usually within an application repo) to push its secrets with the correct service prefix:

```powershell
.\scripts\update-secrets.ps1 -ServiceName "ai-service" -EnvFilePath ".env"
```

### 2. Bulk Sync / Placeholder Creation
If you don't have `.env` files and want to quickly prepare the entire project with placeholders (`REPLACE_ME`) for all services:

```powershell
.\scripts\init-all-services.ps1
```
