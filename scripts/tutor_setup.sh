#!/bin/bash
set -e

# Usage: ./scripts/sync-flux-clean.sh <env>
ENV=${1:-dev}
REPO_ROOT=$(git rev-parse --show-toplevel)
TUTOR_ENV_ROOT="/home/uzair/.local/share/tutor/env"
TUTOR_ENV_APPS="$TUTOR_ENV_ROOT/apps/openedx/config"

BASE_DIR="$REPO_ROOT/apps/openedx/base"
OVERLAY_DIR="$REPO_ROOT/apps/openedx/overlays/$ENV"

echo "🧹 Starting Clean Sync for [$ENV]..."

# 1. Render FULL Manifests from Tutor
echo "📄 Rendering Tutor manifests..."
kubectl kustomize "$TUTOR_ENV_ROOT" >"$BASE_DIR/all-rendered.yaml"

# 2. Global Hash Stripping
echo "✂️  Stripping random suffixes..."
sed -i -E 's/-[a-z0-9]{10}//g' "$BASE_DIR/all-rendered.yaml"

# 3. Extract and Organize Files
echo "📂 Splitting manifests..."

# ALWAYS Update: Dynamic Resources
yq 'select(.kind == "ConfigMap") | .metadata.namespace = "openedx"' "$BASE_DIR/all-rendered.yaml" >"$BASE_DIR/configmaps.yml"
yq 'select(.kind == "Deployment" and .metadata.name != "caddy") | .metadata.namespace = "openedx"' "$BASE_DIR/all-rendered.yaml" >"$BASE_DIR/deployments.yml"
yq 'select(.kind == "Service" and .metadata.name != "caddy") | .metadata.namespace = "openedx"' "$BASE_DIR/all-rendered.yaml" >"$BASE_DIR/services.yml"
yq -i 'with(select(.metadata.name == "mfe"); .spec.type = "ClusterIP")' "$BASE_DIR/services.yml"

# ALWAYS Update Jobs
yq 'select(.kind == "Job") | .metadata.namespace = "openedx"' "$BASE_DIR/all-rendered.yaml" >"$BASE_DIR/jobs.yml"

# CONDITIONAL Update: Static Resources
if [ ! -f "$BASE_DIR/volumes.yml" ]; then
    yq 'select(.kind == "PersistentVolumeClaim") | .metadata.namespace = "openedx"' "$BASE_DIR/all-rendered.yaml" >"$BASE_DIR/volumes.yml"
fi
if [ ! -f "$BASE_DIR/namespace.yml" ]; then
    echo "apiVersion: v1
kind: Namespace
metadata:
  name: openedx
  labels:
    app.kubernetes.io/component: namespace" >"$BASE_DIR/namespace.yml"
fi

rm "$BASE_DIR/all-rendered.yaml"

# 4. Inject Secrets (Env Vars ONLY)
echo "🔌 Injecting 'openedx-secrets' as envFrom..."

# We ONLY inject envFrom. We do NOT replace the volumes.
SECRET_REF='{"secretRef": {"name": "openedx-secrets"}}'

# Inject into Deployments
yq -i ".spec.template.spec.containers[].envFrom += [$SECRET_REF]" "$BASE_DIR/deployments.yml"

# Inject into Jobs
yq -i ".spec.template.spec.containers[].envFrom += [$SECRET_REF]" "$BASE_DIR/jobs.yml"

# 5. Generate Secrets (Overlay)
echo "🔐 Generating openedx-secrets.yaml..."

# Capture variables
LMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/lms.env.yml")
CMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/cms.env.yml")
# Extract only specific env vars safely
ENV_VARS=$(yq 'with_entries(select(.key | test("^(MYSQL_|REDIS_|ELASTICSEARCH_|MONGODB_|HJ_)"))) | .[] |= ( . |  "" + .)' ~/.local/share/tutor/config.yml)

# FIXED: Use environment variables to pass JSON to yq (avoids quoting errors)
LMS_JSON="$LMS_JSON" CMS_JSON="$CMS_JSON" yq eval -n '
  .apiVersion = "v1" |
  .kind = "Secret" |
  .metadata.name = "openedx-secrets" |
  .metadata.namespace = "openedx" |
  .type = "Opaque" |
  .stringData."lms.env.json" = env(LMS_JSON) |
  .stringData."cms.env.json" = env(CMS_JSON)
' >"$OVERLAY_DIR/secrets.yaml"

# Merge the scalar environment variables
echo "$ENV_VARS" >env_temp.yaml
yq eval-all 'select(fileIndex==0).stringData += select(fileIndex==1) | select(fileIndex==0)' "$OVERLAY_DIR/secrets.yaml" env_temp.yaml >secrets_final.yaml
mv secrets_final.yaml "$OVERLAY_DIR/secrets.yaml"
rm env_temp.yaml

# 6. Kustomization Files
if [ ! -f "$BASE_DIR/kustomization.yaml" ]; then
    cat <<EOF >"$BASE_DIR/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: openedx
resources:
  - namespace.yml
  - deployments.yml
  - services.yml
  - jobs.yml
  - volumes.yml
  - configmaps.yml
EOF
fi

if [ ! -f "$OVERLAY_DIR/kustomization.yaml" ]; then
    cat <<EOF >"$OVERLAY_DIR/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../base
  - secrets.yaml
  - hpa.yaml
  - ingress.yaml
namespace: openedx
EOF
fi

echo "✅ DONE. Secrets generated safely. Deployments updated correctly."
echo "👉 Action Required:"
echo "   sops --encrypt --in-place $BASE_DIR/configmaps.yml"
echo "   sops --encrypt --in-place $OVERLAY_DIR/secrets.yaml"
