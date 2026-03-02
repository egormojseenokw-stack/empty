#!/bin/bash
# Фаза 2: деплой record types батчами.
# Использует асинхронный деплой (--async) + опрос статуса, чтобы не упираться в таймаут
# и уменьшить число API-запросов за счёт более крупных батчей (лимит Metadata API ~39 MB сжатый пакет).

set -e
REPO="$(cd "$(dirname "$0")/.." && pwd)"
ORG="${1:-testEmpty}"
# Второй аргумент: пропустить первые N (деплоить только с (N+1)-го по последний). Пример: 150 = деплоить только последние 50.
START_OFFSET="${2:-0}"
DEPLOY_DIR=/tmp/rt-data-deploy
# ~2.9 MB на файл; 39 MB сжатый лимит → до ~35 файлов в батче (с запасом)
BATCH_SIZE=35
SRC_OBJ="$REPO/force-app/main/default/objects/RecordType__c"
DEST="$DEPLOY_DIR/force-app/main/default/objects/RecordType__c"

rm -rf "$DEPLOY_DIR"
mkdir -p "$DEST/recordTypes"

cp "$SRC_OBJ/RecordType__c.object-meta.xml" "$DEST/"

RT_FILES=("$SRC_OBJ/recordTypes/"*.recordType-meta.xml)
TOTAL=${#RT_FILES[@]}
DEPLOY_COUNT=$((TOTAL - START_OFFSET))
BATCHES=$(( (DEPLOY_COUNT + BATCH_SIZE - 1) / BATCH_SIZE ))

if [ "$DEPLOY_COUNT" -le 0 ]; then
  echo "Nothing to deploy (START_OFFSET=$START_OFFSET >= TOTAL=$TOTAL)."
  exit 0
fi

echo "Deploying record types $((START_OFFSET+1))-$TOTAL (last $DEPLOY_COUNT files) to $ORG in $BATCHES batches (up to $BATCH_SIZE per batch, async)."

for ((b=3; b<BATCHES; b++)); do
  start=$((START_OFFSET + b * BATCH_SIZE))
  end=$((start + BATCH_SIZE))
  [ $end -gt $TOTAL ] && end=$TOTAL
  echo "--- Batch $((b+1))/$BATCHES (record types $((start+1))-$end) ---"
  rm -f "$DEST/recordTypes"/*
  for ((i=start; i<end; i++)); do
    cp "${RT_FILES[$i]}" "$DEST/recordTypes/"
  done

  # Асинхронный деплой: один запрос на запуск, затем опрос статуса (меньше нагрузка и нет таймаута клиента)
  JOB_ID=$(sf project deploy start \
    --source-dir "$DEPLOY_DIR/force-app" \
    --target-org "$ORG" \
    --async \
    --concise \
    --json 2>/dev/null | jq -r '.result.id // empty')
  if [ -z "$JOB_ID" ]; then
    echo "Deploy start failed (no job id). Retrying without --async..."
    if ! sf project deploy start --source-dir "$DEPLOY_DIR/force-app" --target-org "$ORG" --concise; then
      echo "Deploy failed at batch $((b+1))"
      exit 1
    fi
  else
    echo "Job ID: $JOB_ID — waiting for completion..."
    while true; do
      STATUS=$(sf project deploy report --job-id "$JOB_ID" --target-org "$ORG" --json 2>/dev/null | jq -r '.result.status // "Unknown"')
      case "$STATUS" in
        Succeeded)
          echo "Batch $((b+1)) done."
          break
          ;;
        Failed|Canceled)
          echo "Deploy failed at batch $((b+1)): $STATUS"
          sf project deploy report --job-id "$JOB_ID" --target-org "$ORG" 2>/dev/null || true
          exit 1
          ;;
        InProgress|Pending)
          echo "  ... $STATUS ($(date +%H:%M:%S))"
          sleep 30
          ;;
        *)
          echo "  ... $STATUS ($(date +%H:%M:%S))"
          sleep 30
          ;;
      esac
    done
  fi
done

echo "All record type batches deployed successfully."
