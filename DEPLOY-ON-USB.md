# Что перенести на флешку для деплоя на другом орге

Скрипты ожидают, что запускаются из **корня** этой папки (родитель каталога `scripts/`).
Структура должна быть такой:

```
<корень на флешке>/
├── scripts/
│   ├── deploy_1_skeleton.sh      # фаза 1: скелет (объект + GVS)
│   ├── deploy_2_recordtypes_batches.sh   # фаза 2: record types батчами
│   └── deploy_recordtype_batches.sh      # опционально: всё одним скриптом
├── force-app/
│   └── main/
│       └── default/
│           └── objects/
│               └── RecordType__c/
│                   ├── RecordType__c.object-meta.xml
│                   └── recordTypes/
│                       ├── RTType301.recordType-meta.xml
│                       ├── RTType302.recordType-meta.xml
│                       └── ... (все 200 файлов)
└── deploy-skeleton/
    └── force-app/
        └── main/
            └── default/
                ├── objects/
                │   └── RecordType__c/
                │       └── RecordType__c.object-meta.xml
                └── globalValueSets/
                    └── RecordTypeValueSet.globalValueSet-meta.xml
```

## Минимальный набор для флешки

| Что | Путь |
|-----|------|
| Скрипты | `scripts/deploy_1_skeleton.sh`, `scripts/deploy_2_recordtypes_batches.sh` |
| Объект (для батчей) | `force-app/main/default/objects/RecordType__c/RecordType__c.object-meta.xml` |
| Record types (200 файлов) | `force-app/main/default/objects/RecordType__c/recordTypes/*.recordType-meta.xml` |
| Скелет (фаза 1) | `deploy-skeleton/force-app/` (объект + `globalValueSets/RecordTypeValueSet.globalValueSet-meta.xml`) |

## На другом компьютере

1. Скопировать всю папку с флешки (сохранить структуру).
2. В терминале: `cd /путь/к/скопированной/папке`
3. Подключить org: `sf org login web --alias myNewOrg` (или использовать уже авторизованную).
4. Фаза 1 (один раз): `./scripts/deploy_1_skeleton.sh myNewOrg`
5. Фаза 2: `./scripts/deploy_2_recordtypes_batches.sh myNewOrg`
   - Только последние 50: `./scripts/deploy_2_recordtypes_batches.sh myNewOrg 150`

На той машине должны быть установлены: **sf CLI** и **jq** (для async-деплоя).

## Размер

- `recordTypes/` — ~553 MB (200 × ~2.9 MB).
- Остальное — несколько мегабайт.
- Итого: ориентировочно **~560 MB**.
