#!/bin/bash
# Фаза 1: деплой скелета RecordType__c (объект + Global Value Set, без record types).

set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
ORG="${1:-testEmpty}"

echo "Deploying skeleton (object + GVS) to org: $ORG"
sf project deploy start \
  --source-dir "$REPO/deploy-skeleton/force-app" \
  --target-org "$ORG" \
  --concise

echo "Skeleton deployed. Run deploy_2_recordtypes_batches.sh to deploy record types in batches."
