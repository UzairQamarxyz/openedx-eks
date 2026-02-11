# 📘 Open edX on EKS via Flux (GitOps)

This repository contains the complete Infrastructure-as-Code (Terraform) and Kubernetes manifests (Flux) required to deploy a scalable, production-grade Open edX instance on AWS EKS. It automates the transition from **Tutor** local configuration to a **GitOps** production workflow.

---

## 🏗️ Architecture & Workflow

This deployment pipeline follows a strict GitOps workflow to ensure consistency and security:

1. **Configure Locally (Tutor):** You define your settings (passwords, features, plugins) locally using `tutor config save`.
2. **Sync & Sanitize:** The automated script (`sync-flux-clean.sh`) reads your local Tutor environment, renders the Kubernetes manifests, removes local-only tools (like Caddy), and injects production secrets.
3. **Commit to Git:** The sanitized manifests and encrypted secrets are committed to the `apps/openedx/base` directory.
4. **Flux Sync:** The Flux controller on EKS detects the commit, decrypts the secrets using **AWS KMS + SOPS**, and applies the state to the cluster.
5. **DNS Automation:** A helper script maps the dynamic AWS Load Balancer hostname to your Route 53 domain records.

---

## 📂 Repository Structure

* **`apps/openedx/base/`**: Auto-generated manifests (Deployments, Services, Jobs). **Do not edit these manually**; they are overwritten by the sync script.
* **`apps/openedx/overlays/dev/`**: Environment-specific configurations (Secrets, Ingress, HPA).
* **`clusters/eks-uzi-01/`**: Flux cluster definitions and source controllers.
* **`scripts/`**: Automation tools for syncing and DNS.
* **`terraform/`**: Infrastructure definitions (VPC, EKS, RDS, Elasticache).

---

## 🔐 Setup: SOPS & Secrets

We use **Mozilla SOPS** backed by **AWS KMS** to encrypt sensitive data. This allows us to safely commit `secrets.yaml` to the repository.

### 1. Prerequisites

* **SOPS** (v3.7+) installed locally.
* **AWS CLI** configured with a profile that has access to the KMS key.

### 2. Encryption Configuration

The `.sops.yaml` file at the root ensures the correct KMS key is used automatically.

```yaml
creation_rules:
  - path_regex: apps/.*(secrets|configmaps).yaml$
    kms: 'arn:aws:kms:eu-central-1:ACCOUNT_ID:key/KMS_KEY_ID'
    encrypted_regex: '^(data|stringData)$'

```

### 3. Managing Secrets

You rarely need to run these commands manually, as the sync script handles generation, but for reference:

* **Encrypt a file:**
```bash
sops --encrypt --in-place apps/openedx/overlays/dev/secrets.yaml

```


* **Edit a file (Decrpyt -> Edit -> Encrypt):**
```bash
sops apps/openedx/overlays/dev/secrets.yaml

```



---

## 🛠️ Scripts Usage Guide

### 🔄 1. Sync Tutor to GitOps (`sync-flux-clean.sh`)

This is your **primary deployment tool**. Run this whenever you change `config.yml` in Tutor.

**What it does:**

* Renders Kubernetes manifests from Tutor.
* Strips random hash suffixes from ConfigMaps to prevent unnecessary pod rollouts.
* Rewires Deployments to use the encrypted `openedx-secrets` instead of plain ConfigMaps.
* Preserves static files (Ingress, PVCs, Namespaces) to prevent overwriting custom changes.

**Command:**

```bash
# ./scripts/sync-flux-clean.sh <environment_name>
./scripts/sync-flux-clean.sh dev

```

**Post-Run Requirements:**
The script generates a *decrypted* secret file. You must encrypt and push it:

```bash
sops --encrypt --in-place apps/openedx/overlays/dev/secrets.yaml
git add .
git commit -m "chore: update openedx configuration"
git push

```

### 🌐 2. DNS Automation (`update-dns.sh`)

Since AWS Load Balancers have dynamic hostnames, this script updates Route 53 to point your domains to the active Ingress Controller.

**Command:**

```bash
# ./scripts/update-dns.sh <base_domain> <env_prefix> <aws_region>
./scripts/update-dns.sh copebit-training.net openedx eu-central-1

```

**Updates the following records:**

* `openedx.copebit-training.net` (LMS)
* `studio.openedx.copebit-training.net` (CMS)
* `*.openedx.copebit-training.net` (MFEs/Previews)

---

## 🐞 Troubleshooting

| Issue | Cause | Fix |
| --- | --- | --- |
| **Ingress 404 Not Found** | Nginx does not recognize the Ingress resource class. | Ensure your Ingress has `ingressClassName: ingress-nginx`. |
| **Pods in `CrashLoopBackOff**` | Configuration/Secret change. Pods don't auto-reload env vars. | Run `kubectl delete pods -n openedx --all` to force a restart. |
| **Database `Unknown Host**` | `MYSQL_HOST` in `config.yml` contains a port (e.g., `:3306`). | Remove the port from `MYSQL_HOST` in Tutor config and re-sync. |
| **Database `Unknown database**` | The `mysql-job` failed initially and never created the DB. | Run `kubectl delete jobs -n openedx --all` to trigger Flux to re-run them. |
