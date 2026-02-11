#!/bin/bash
set -e

# Usage: ./scripts/sync-flux.sh <env> <cluster_name>
ENV=${1:-dev}
CLUSTER=${2:-eks-uzi-01}
REPO_ROOT=$(git rev-parse --show-toplevel)

# Path Configuration
TUTOR_ENV_ROOT="/home/uzair/.local/share/tutor/env"
TUTOR_ENV_K8S="$TUTOR_ENV_ROOT/k8s"
TUTOR_ENV_APPS="$TUTOR_ENV_ROOT/apps/openedx/config"

# Target Directories
OPENEDX_BASE_DIR="$REPO_ROOT/apps/openedx/base"
OPENEDX_OVERLAY_DIR="$REPO_ROOT/apps/openedx/overlays/$ENV"

echo "📍 Syncing Flux manifests for Environment: [$ENV]"

# 1. Prerequisites Check
if ! command -v yq &>/dev/null; then
    echo "❌ Error: 'yq' (v4+) is required. Please install it."
    exit 1
fi

# 2. Process Services & Deployments (Sanitization)
echo "📦 Sanitizing Manifests..."
# Remove Caddy service and deployments
yq 'select(.metadata.name != "caddy")' "$TUTOR_ENV_K8S/services.yml" >"$OPENEDX_BASE_DIR/services.yml"
yq 'select(.metadata.name != "caddy")' "$TUTOR_ENV_K8S/deployments.yml" >"$OPENEDX_BASE_DIR/deployments.yml"

# Force MFE to ClusterIP (Ingress Requirement) [cite: 79, 80]
yq -i 'with(select(.metadata.name == "mfe"); .spec.type = "ClusterIP")' "$OPENEDX_BASE_DIR/services.yml"

# 3. Update Base Manifests
echo "📄 Updating Base Manifests..."
cp "$TUTOR_ENV_K8S/jobs.yml" "$OPENEDX_BASE_DIR/jobs.yml"
cp "$TUTOR_ENV_K8S/namespace.yml" "$OPENEDX_BASE_DIR/namespace.yml"
cp "$TUTOR_ENV_K8S/volumes.yml" "$OPENEDX_BASE_DIR/volumes.yml"

# 4. Generate Base ConfigMaps
if command -v kubectl &>/dev/null; then
    echo "📄 Generating Base ConfigMaps..."
    # Render from Tutor and strip existing SOPS headers if present to prevent double-encryption errors
    kubectl kustomize "$TUTOR_ENV_ROOT" | yq 'select(.kind == "ConfigMap")' >"$OPENEDX_BASE_DIR/configmaps.yml"
fi

# 5. Generate Secrets (Overlay)
# FIXED: Indentation for JSON and Forced Strings for Env Vars
echo "🔐 Generating secrets.yaml..."

# Format JSON blocks with 4-space indentation to fit YAML block scalar
LMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/lms.env.yml" | sed 's/^/    /')
CMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/cms.env.yml" | sed 's/^/    /')

# Extract Env Vars and force ALL values to strings using yq to avoid Flux validation errors [cite: 78]
ENV_VARS_YAML=$(yq 'with_entries(select(.key | test("^(MYSQL_|REDIS_|ELASTICSEARCH_|MONGODB_|HJ_)"))) | .[] |= ( . |  "" + .)' ~/.local/share/tutor/config.yml | sed 's/^/  /')

cat <<EOF >"$OPENEDX_OVERLAY_DIR/secrets.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: openedx-settings
  namespace: openedx
type: Opaque
stringData:
  # --- JSON Configuration Files ---
  lms.env.json: |
$LMS_JSON
  cms.env.json: |
$CMS_JSON
  # --- Environment Variables ---
$ENV_VARS_YAML
EOF

# 6. Update Flux Sync Path in Cluster Config
CLUSTER_SYNC_FILE="$REPO_ROOT/clusters/$CLUSTER/openedx-sync.yaml"
if [ -f "$CLUSTER_SYNC_FILE" ]; then
    sed -i.bak "s|path: ./apps/openedx/overlays/.*|path: ./apps/openedx/overlays/$ENV|g" "$CLUSTER_SYNC_FILE" && rm "$CLUSTER_SYNC_FILE.bak"
    echo "🔄 Updated Flux sync path for cluster [$CLUSTER]"
fi

echo "✅ Manifest sync complete. No static files (HPA/Patch/Kustomize) were overwritten."
echo "⚠️  Action Required: Reset and re-encrypt sensitive files."
echo "   1. sed -i '/^sops:/,\$d' $OPENEDX_BASE_DIR/configmaps.yml"
echo "   2. sops --encrypt --in-place $OPENEDX_BASE_DIR/configmaps.yml"
echo "   3. sops --encrypt --in-place $OPENEDX_OVERLAY_DIR/secrets.yaml"
