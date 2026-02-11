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

# We respect your specific tree structure here:
OPENEDX_BASE_DIR="$REPO_ROOT/apps/openedx/base"
OPENEDX_OVERLAY_DIR="$REPO_ROOT/apps/openedx/overlays/$ENV"

echo "📍 Syncing Flux manifests for Environment: [$ENV]"

# 1. Prerequisites Check
if ! command -v yq &>/dev/null; then
    echo "❌ Error: 'yq' (v4+) is required. Please install it."
    exit 1
fi

mkdir -p "$OPENEDX_BASE_DIR"
mkdir -p "$OPENEDX_OVERLAY_DIR"

# 2. Process Services & Deployments (Sanitization)
echo "📦 Sanitizing Manifests..."
# Remove Caddy service
yq 'select(.metadata.name != "caddy")' "$TUTOR_ENV_K8S/services.yml" >"$OPENEDX_BASE_DIR/services.yml"
# Force MFE to ClusterIP (Ingress Requirement)
yq -i 'with(select(.metadata.name == "mfe"); .spec.type = "ClusterIP")' "$OPENEDX_BASE_DIR/services.yml"

# Remove Caddy deployment
if [ -f "$TUTOR_ENV_K8S/deployments.yml" ]; then
    yq 'select(.metadata.name != "caddy")' "$TUTOR_ENV_K8S/deployments.yml" >"$OPENEDX_BASE_DIR/deployments.yml"
else
    echo "⚠️ deployments.yml not found, skipping."
fi

# 3. Process Standard Manifests
cp "$TUTOR_ENV_K8S/jobs.yml" "$OPENEDX_BASE_DIR/jobs.yml"
cp "$TUTOR_ENV_K8S/namespace.yml" "$OPENEDX_BASE_DIR/namespace.yml"
cp "$TUTOR_ENV_K8S/volumes.yml" "$OPENEDX_BASE_DIR/volumes.yml"

# 4. Generate ConfigMaps (Base)
if command -v kubectl &>/dev/null; then
    echo "📄 Generating Base ConfigMaps..."
    kubectl kustomize "$TUTOR_ENV_ROOT" | yq 'select(.kind == "ConfigMap")' >"$OPENEDX_BASE_DIR/configmaps.yml"
fi

# 5. Generate Secrets (Overlay)
echo "🔐 Generating secrets.yaml..."
# Indent JSON by 4 spaces for YAML block scalar
LMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/lms.env.yml" | sed 's/^/    /')
CMS_JSON=$(yq -o=json '.' "$TUTOR_ENV_APPS/cms.env.yml" | sed 's/^/    /')
# Extract Env Vars properly formatted as YAML key-values
ENV_VARS_YAML=$(yq 'with_entries(select(.key | test("^(MYSQL_|REDIS_|ELASTICSEARCH_|MONGODB_|HJ_)")))' ~/.local/share/tutor/config.yml | sed 's/^/  /')

cat <<EOF >"$OPENEDX_OVERLAY_DIR/secrets.yaml"
apiVersion: v1
kind: Secret
metadata:
  name: openedx-settings
  namespace: openedx
type: Opaque
stringData:
  lms.env.json: |
$LMS_JSON
  cms.env.json: |
$CMS_JSON
  # Env Vars
$ENV_VARS_YAML
EOF

echo "⚠️  Action Required: Encrypt the secrets file!"
echo "   Run: sops --encrypt --in-place $OPENEDX_OVERLAY_DIR/secrets.yaml"

# 6. Create Volume Patch (Overlay)
cat <<EOF >"$OPENEDX_OVERLAY_DIR/volume-patch.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lms
spec:
  template:
    spec:
      containers:
        - name: lms
          envFrom:
            - secretRef:
                name: openedx-settings
        - name: cms
          envFrom:
            - secretRef:
                name: openedx-settings
      volumes:
        - name: config
          secret:
            secretName: openedx-settings
            items:
              - key: lms.env.json
                path: lms.env.json
              - key: cms.env.json
                path: cms.env.json
EOF

# 7. Ingress Handling (Overlay)
if [ -f "$TUTOR_ENV_K8S/ingress.yml" ]; then
    cp "$TUTOR_ENV_K8S/ingress.yml" "$OPENEDX_OVERLAY_DIR/ingress.yaml"
fi

# 8. Base Kustomization
cat <<EOF >"$OPENEDX_BASE_DIR/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - namespace.yml
  - deployments.yml
  - services.yml
  - jobs.yml
  - volumes.yml
  - configmaps.yml
EOF

# 9. Generate HPA Manifest (Hyperscale Readiness)
# We place this INSIDE the overlay folder because scaling is environment-specific.
echo "⚖️  Generating HPA Manifest in Overlay..."
cat <<EOF >"$OPENEDX_OVERLAY_DIR/hpa.yaml"
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: lms-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lms
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cms-hpa
  namespace: openedx
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cms
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 75
EOF

# 10. Overlay Kustomization
# Dynamically builds the resource list based on what exists
RESOURCES="
  - ../../base
  - secrets.yaml
  - hpa.yaml
"
# Add ingress only if it exists
if [ -f "$OPENEDX_OVERLAY_DIR/ingress.yaml" ]; then
    RESOURCES="$RESOURCES
  - ingress.yaml"
fi

cat <<EOF >"$OPENEDX_OVERLAY_DIR/kustomization.yaml"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:$RESOURCES
patches:
  - path: volume-patch.yaml
    target:
      kind: Deployment
EOF

# 11. Update Flux Sync Path
CLUSTER_SYNC_FILE="$REPO_ROOT/clusters/$CLUSTER/openedx-sync.yaml"
if [ -f "$CLUSTER_SYNC_FILE" ]; then
    sed -i.bak "s|path: ./apps/openedx/overlays/.*|path: ./apps/openedx/overlays/$ENV|g" "$CLUSTER_SYNC_FILE" && rm "$CLUSTER_SYNC_FILE.bak"
fi

echo "✅ Flux repository fully synchronized."
