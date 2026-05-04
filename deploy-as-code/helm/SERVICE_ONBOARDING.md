# New Service Onboarding Guide

This document provides a step-by-step guide for adding a new microservice to the POSTPILOT GKE cluster using the standardized **Golden Path** template.

---

## Step 1: Create the Chart
Copy the `service-template` folder to a new directory for your service:

```powershell
# Example: Adding 'notification-service'
cp -Recurse charts/postpilot-services/service-template charts/postpilot-services/notification-service
```

## Step 2: Configure the Chart
Modify the `values.yaml` in your new chart directory:

1.  **Image**: Set `image.repository` (e.g., `notification-service`).
2.  **Ports**: Set `service.targetPort` to match your application's listening port (default: `3000` for Node/Next.js, `80` for Nginx).
3.  **Secrets**: **None!** (Auto-discovery is enabled by default).
4.  **Health Checks**: Update `healthchecks` to match your app's endpoints.
5.  **Hardened Volumes**: Ensure your `values.yaml` includes mandatory `emptyDir` volumes for writable paths (e.g., `/var/cache/nginx`, `/tmp`, or `logs/`).

## Step 3: Register in Helmfile
Add your new service to the `releases` section of `helm/helmfile.yaml`:

```yaml
  - name: notification-service
    namespace: postpilot
    chart: charts/postpilot-services/notification-service
    values:
      - environments/stage.yaml
```

## Step 4: Configure the Environment (stage.yaml)
Open `helm/environments/stage.yaml` and add your service configuration:

1.  **Resources**: Add replicas and memory limits under `services:`.
2.  **Host URL**: Add the desired domain to `global.host_urls`.

```yaml
global:
  host_urls:
    notification_url: "notification.postpilot.ai"

services:
  notification-service:
    replicas: 2
    resources:
      memory_limits: "2Gi"
```

## Step 5: Update the Gateway (Routing)
To expose your service to the internet, add a route to `charts/postpilot-services/postpilot-gateway/values.yaml`:

```yaml
routes:
  - host: notification.postpilot.ai
    serviceName: notification-service
    servicePort: 80
```

> [!IMPORTANT]
> **CDN & WAF**: The `postpilot-gateway` chart automatically attaches the **WAF (Cloud Armor)**. To enable **CDN Caching** for your service, ensure `global.gateway.cdn.enabled` is `true` in your environment manifest. The filter will be automatically attached to your route.

## Step 6: Deploy & Verify
Run the following commands to apply your changes:

```powershell
# 1. Test rendering
helmfile -e uat template --selector name=notification-service

# 2. Apply to cluster
helmfile -e uat apply
```

### Verification Checklist:
- [ ] `kubectl get gateway postpilot-gateway -n postpilot` (Wait for Programmed: True)
- [ ] `kubectl get gcpbackendpolicy -n postpilot` (Verify it matches your service)
- [ ] `kubectl get httproute -n postpilot` (Verify `Reconciled: True`)
- [ ] `kubectl get secret -n postpilot` (Check for `[service-name]-gsm-sync` secret)
- [ ] Access your URL via browser/curl.

---

## 🔐 Automated Secret Management

You no longer need to update YAML files to add secrets. Follow these steps:

1.  **Create Secret**: Create a secret in Google Secret Manager (e.g., `my-api-key`).
2.  **Label for Service**: Add a label `postpilot-service: notification-service`.
3.  **Label for Global**: If every service needs it, use `postpilot-service: global` instead.
4.  **Tag for Sync**: Ensure it has `postpilot-sync: true` (for extra safety).
5.  **Verify**: Within 60 seconds, the secret will be available in the pod as an environment variable `MY_API_KEY`.

---

## ❓ Troubleshooting

### 1. Secret is not Syncing
- **Symptom**: `kubectl get secret` shows old values or doesn't exist.
- **Fix**: Check status: `kubectl get externalsecret [service]-gsm-sync -n postpilot`. 

### 2. Gateway is not Programmed
- **Symptom**: `kubectl get gateway` shows `PROGRAMMED: False`.
- **Fix**: usually caused by an invalid IP reference or SSL certificate path. Check description: `kubectl describe gateway postpilot-gateway -n postpilot`.

### 3. Service is not accessible (404/502/504)
- **Check HTTPRoute**: `kubectl get httproute [route-name] -n postpilot -o yaml`
- **Check Policies**: Ensure `GCPBackendPolicy` (WAF) and `GCPHTTPFilter` (CDN) are reconciled.
- **Backend Health**: Use `kubectl describe backendpolicy [name]` to check NEG health.

---

## 🏗️ Technical Architecture Reference

As of **v1.35.2**, the platform uses a **Private-First** networking model:

1.  **Private Nodes**: All GKE nodes stay in a private subnet. Outbound traffic uses **Cloud NAT**.
2.  **Gateway API**: Uses the `gke-l7-global-external-managed` controller. 
    - **CDN** is attached via `GCPHTTPFilter`.
    - **WAF** is attached via `GCPBackendPolicy`.
3.  **Security Hardening**:
    - **Isolation**: All services are isolated via `default-deny-all` NetworkPolicies.
    - **Intra-Namespace**: High-performance, low-latency pod-to-pod communication is allowed via `allow-intra-namespace`.
    - **User Privileges**: Containers are hardened to `runAsNonRoot` with privilege escalation disabled and `readOnlyRootFilesystem: true`.
    - **Mandatory Volumes**: To support `readOnlyRootFilesystem`, services must define `emptyDir` volumes for any required writable paths (logs, nginx cache, tmp).
4.  **Database Access**: **MongoDB** is used for persistence. Ensure your service's connection strings are managed in **Secret Manager** as `MONGODB_URI`.
5.  **Identity**: Pods use **Workload Identity** to assume the `postpilot-prod-gke-sa` GSA role.
