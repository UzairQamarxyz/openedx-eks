#!/bin/bash
set -e

# Usage: ./scripts/update-dns.sh <base_domain> <env_prefix> <aws_region>
# Example: ./scripts/update-dns.sh uzair.copebit-training.net openedx eu-central-1

export AWS_PAGER="" # Disable AWS CLI paging for cleaner output
BASE_DOMAIN="${1:-uzair.copebit-training.net}"
ENV_PREFIX="${2:-openedx}"
REGION="${3:-eu-central-1}"

INGRESS_NAMESPACE="ingress-nginx"
INGRESS_SERVICE="ingress-nginx-controller"

# Construct the target Hostnames based on your request
LMS_HOST="$ENV_PREFIX.$BASE_DOMAIN"        # e.g., openedx.uzair.copebit-training.net
CMS_HOST="studio.$ENV_PREFIX.$BASE_DOMAIN" # e.g., studio.openedx.uzair.copebit-training.net
WILDCARD_HOST="*.$ENV_PREFIX.$BASE_DOMAIN" # e.g., *.openedx.uzair.copebit-training.net (Covers MFEs/Previews)

echo "📍 updating DNS for Environment: [$ENV_PREFIX] in Zone: [$BASE_DOMAIN]"
echo "   - LMS: $LMS_HOST"
echo "   - CMS: $CMS_HOST"

# 1. Fetch Load Balancer Hostname
echo "🔍 Fetching Load Balancer Hostname from Kubernetes..."
LB_HOSTNAME=""
while [ -z "$LB_HOSTNAME" ]; do
    LB_HOSTNAME=$(kubectl get svc -n "$INGRESS_NAMESPACE" "$INGRESS_SERVICE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
    if [ -z "$LB_HOSTNAME" ]; then
        echo "   ⏳ Waiting for Load Balancer to be assigned..."
        sleep 5
    fi
done
echo "✅ Found Load Balancer: $LB_HOSTNAME"

# 2. Find Hosted Zone ID
echo "🔍 Finding Hosted Zone ID..."
# Ensure trailing dot for precise matching
ZONE_ID=$(aws route53 list-hosted-zones-by-name \
    --dns-name "$BASE_DOMAIN." \
    --region "$REGION" \
    --query "HostedZones[?Name=='$BASE_DOMAIN.'].Id" \
    --output text)

if [ "$ZONE_ID" == "None" ] || [ -z "$ZONE_ID" ]; then
    echo "❌ Error: Hosted Zone for $BASE_DOMAIN not found in Route 53."
    exit 1
fi
echo "✅ Found Zone ID: $ZONE_ID"

# 3. Prepare DNS Update Batch
echo "📝 Preparing DNS update batch..."
cat <<EOF >dns-change-batch.json
{
  "Comment": "Update Open edX LMS and CMS records",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$LMS_HOST",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "$LB_HOSTNAME" }]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$CMS_HOST",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "$LB_HOSTNAME" }]
      }
    },
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$WILDCARD_HOST",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [{ "Value": "$LB_HOSTNAME" }]
      }
    }
  ]
}
EOF

# 4. Execute Update
echo "🚀 Updating Route 53 Records..."
aws route53 change-resource-record-sets \
    --hosted-zone-id "$ZONE_ID" \
    --change-batch file://dns-change-batch.json \
    --region "$REGION"

rm dns-change-batch.json
echo "✅ DNS Records Updated!"
