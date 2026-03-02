# Скелет объекта RecordType__c

Эта папка содержит **только структуру** (метаданные), без данных record types:

- **CustomObject** `RecordType__c` — объект с полями Picklist1__c … Picklist50__c (все ссылаются на Global Value Set)
- **GlobalValueSet** `RecordTypeValueSet` — глобальный список значений для пиклистов

Папки `recordTypes` здесь нет — типы записей деплоятся отдельно, батчами (см. скрипты в `scripts/`).

## Двухфазный деплой

1. **Фаза 1 — скелет:** задеплоить эту папку в org (объект + GVS).
2. **Фаза 2 — данные:** задеплоить record types батчами (пиклист-значения по типам записей).

```bash
# из корня репозитория
./scripts/deploy_1_skeleton.sh          # один раз
./scripts/deploy_2_recordtypes_batches.sh   # затем батчи record types
```
