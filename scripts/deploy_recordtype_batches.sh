#!/bin/bash
# Deploy RecordType__c in batches to avoid CLI string size limit.
# Alternative: use two-phase deploy (skeleton then data):
#   ./scripts/deploy_1_skeleton.sh && ./scripts/deploy_2_recordtypes_batches.sh
#
# This script does object + GVS + all record type batches in one run.

set -e
REPO=/home/egor/testSFP
DEPLOY_DIR=/tmp/rt-batch-deploy
ORG="${1:-testEmpty}"
BATCH_SIZE=25
SRC_OBJ="$REPO/force-app/main/default/objects/RecordType__c"
SRC_GVS="$REPO/force-app/main/default/globalValueSets"
DEST="$DEPLOY_DIR/force-app/main/default"

rm -rf "$DEPLOY_DIR"
mkdir -p "$DEST/objects/RecordType__c/recordTypes"
mkdir -p "$DEST/globalValueSets"

cp "$SRC_OBJ/RecordType__c.object-meta.xml" "$DEST/objects/RecordType__c/"
cp "$SRC_GVS/RecordTypeValueSet.globalValueSet-meta.xml" "$DEST/globalValueSets/" 2>/dev/null || true

RT_FILES=("$SRC_OBJ/recordTypes/"*.recordType-meta.xml)
TOTAL=${#RT_FILES[@]}
BATCHES=$(( (TOTAL + BATCH_SIZE - 1) / BATCH_SIZE ))

echo "Total record types: $TOTAL. Batch size: $BATCH_SIZE. Batches: $BATCHES"

for ((b=0; b<BATCHES; b++)); do
  start=$((b * BATCH_SIZE))
  end=$((start + BATCH_SIZE))
  [ $end -gt $TOTAL ] && end=$TOTAL
  echo "--- Batch $((b+1))/$BATCHES (record types $((start+1))-$end) ---"
  rm -rf "$DEST/objects/RecordType__c/recordTypes"/*
  for ((i=start; i<end; i++)); do
    cp "${RT_FILES[$i]}" "$DEST/objects/RecordType__c/recordTypes/"
  done
  if ! sf project deploy start --source-dir "$DEPLOY_DIR/force-app" --target-org "$ORG" --concise; then
    echo "Deploy failed at batch $((b+1))"
    exit 1
  fi
done

echo "All batches deployed successfully."
