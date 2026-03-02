public inherited sharing class DatabaseUtils {
    public static final String accessViolationException = 'Access Violation Exception';

    private static final Boolean IsGuestUser = (UserInfo.getUserType() == 'Guest');

    public static void checkObjectsAndFieldsAccessibility(Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>> fieldsByObjects) {
        DatabaseUtils.NotAcessibleFieldsByObjectWrapper notAccessibleObjectsAndFields = DatabaseUtils.hasNotAccessibleFieldsAndObjects(fieldsByObjects);
        System.debug(notAccessibleObjectsAndFields);
        if (!notAccessibleObjectsAndFields.notAccessibleFieldsPerObject.isEmpty()) {
            throw new DatabaseUtilsException(accessViolationException, DatabaseUtilsException.ExceptionType.FIELD_ACCESS_VIOLATION, DatabaseUtilsException.ExceptionReason.NO_READ,
                    notAccessibleObjectsAndFields.getNotAccessibleObjectsAndFields(), ''
            );

        }
    }

    public static List<Schema.DescribeFieldResult> getDescribeFieldResultsForObject(SObject obj) {
        Map<String, Object> populatedFieldsMap = obj.getPopulatedFieldsAsMap();
        List<Schema.DescribeFieldResult> result = new List<Schema.DescribeFieldResult>();
        for (String fieldName : populatedFieldsMap.keySet()) {
            if (fieldName != 'Id') {
                Schema.DescribeFieldResult dfs = obj.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
                result.add(dfs);
            }
        }
        return result;
    }

    public static Database.SaveResult[] insertRecord(SObject obj) {
        return DatabaseUtils.insertRecord(obj, getDescribeFieldResultsForObject(obj));
    }

    public static Database.SaveResult[] insertRecord(SObject obj, Schema.DescribeFieldResult[] fields) {
        return DatabaseUtils.insertRecords(new List<SObject>{
                obj
        }, fields);
    }

    public static Database.SaveResult[] insertRecordsForOneSObjectType(SObject[] objs) {
        return DatabaseUtils.insertRecords(objs, getDescribeFieldResultsForObject(objs[0]));
    }

    public static Database.SaveResult[] insertRecords(SObject[] objs, Schema.DescribeFieldResult[] fields) {
        String notCreateableFLS = DatabaseUtils.hasNotCreateableFields(fields);
        System.debug('notCreateableFLS-'+notCreateableFLS );
        String notCreateableObjects = DatabaseUtils.hasNotCreateableObjects(objs);
        System.debug('notCreateableObjects -'+notCreateableObjects );
        if (notCreateableFLS != null || notCreateableObjects != null) {
            DatabaseUtilsException.ExceptionType exType;

            if (notCreateableObjects != null) {
                exType = DatabaseUtilsException.ExceptionType.OBJECT_ACCESS_VIOLATION;
            } else if (notCreateableFLS != null) {
                notCreateableObjects = objs[0].getSObjectType().getDescribe().getName();
                exType = DatabaseUtilsException.ExceptionType.FIELD_ACCESS_VIOLATION;
            }

            throw new DatabaseUtilsException(
                    accessViolationException,
                    exType,
                    DatabaseUtilsException.ExceptionReason.NO_CREATE,
                    notCreateableObjects,
                    notCreateableFLS
            );

        }

        return Database.insert(objs);
    }

    public static Database.SaveResult[] insertInsertableRecords(SObject[] objs, Schema.DescribeFieldResult[] fields) {
        String notCreateableFLS = DatabaseUtils.hasNotCreateableFields(fields);
        String notCreateableObjects = DatabaseUtils.hasNotCreateableObjects(objs);

        if (notCreateableFLS != null || notCreateableObjects != null) {
            DatabaseUtilsException.ExceptionType exType;

            if (notCreateableObjects != null) {
                exType = DatabaseUtilsException.ExceptionType.OBJECT_ACCESS_VIOLATION;
            } else if (notCreateableFLS != null) {
                notCreateableObjects = objs[0].getSObjectType().getDescribe().getName();
                exType = DatabaseUtilsException.ExceptionType.FIELD_ACCESS_VIOLATION;
            }

            throw new DatabaseUtilsException(
                    accessViolationException,
                    exType,
                    DatabaseUtilsException.ExceptionReason.NO_CREATE,
                    notCreateableObjects,
                    notCreateableFLS
            );

        }

        return Database.insert(objs, false);
    }


    public static Database.SaveResult[] updateRecord(SObject obj, Schema.DescribeFieldResult[] fields) {
        return DatabaseUtils.updateRecords(new List<SObject>{
                obj
        }, fields);
    }

    public static Database.SaveResult[] updateRecordsForOneSObjectType(SObject[] objs) {
        return DatabaseUtils.updateRecords(objs, getDescribeFieldResultsForObject(objs[0]));
    }

    public static Database.SaveResult[] updateRecords(SObject[] objs, Schema.DescribeFieldResult[] fields) {
        String notUpdateableFLS = (DatabaseUtils.IsGuestUser && !objs[0].getSObjectType().getDescribe().isCustom()) ?
                DatabaseUtils.hasNotCreateableFields(fields) :
                DatabaseUtils.hasNotUpdateableFields(fields);
        String notUpdateableSObjects = DatabaseUtils.hasNotUpdateableObjects(objs);

        if (notUpdateableFLS != null || notUpdateableSObjects != null) {
            DatabaseUtilsException.ExceptionType exType;

            if (notUpdateableSObjects != null) {
                exType = DatabaseUtilsException.ExceptionType.OBJECT_ACCESS_VIOLATION;
            } else if (notUpdateableFLS != null) {
                exType = DatabaseUtilsException.ExceptionType.FIELD_ACCESS_VIOLATION;
            }

            throw new DatabaseUtilsException(
                    accessViolationException,
                    exType,
                    DatabaseUtilsException.ExceptionReason.NO_UPDATE,
                    notUpdateableSObjects,
                    notUpdateableFLS
            );

        }

        return Database.update(objs);
    }

    public static Database.SaveResult[] upsertRecord(SObject obj, Schema.DescribeFieldResult[] fields) {
        return DatabaseUtils.upsertRecords(new List<SObject>{
                obj
        }, fields);
    }

    public static Database.SaveResult[] upsertRecords(SObject[] objs, Schema.DescribeFieldResult[] fields) {
        List<SObject> objectsForUpdate = new List<SObject>();
        List<SObject> objectsForInsert = new List<SObject>();

        for (SObject item : objs) {
            if (item.get('Id') != null) {
                objectsForUpdate.add(item);
            } else {
                objectsForInsert.add(item);
            }
        }
        Database.SaveResult[] saveResult = new Database.SaveResult[]{
        };

        if (!objectsForInsert.isEmpty()) {
            saveResult.addAll(DatabaseUtils.insertRecords(objectsForInsert, fields));
        }

        if (!objectsForUpdate.isEmpty()) {
            saveResult.addAll(DatabaseUtils.updateRecords(objectsForUpdate, fields));
        }

        return saveResult;
    }

    public static Database.DeleteResult[] deleteRecord(SObject obj) {
        return DatabaseUtils.deleteRecords(new List<SObject>{
                obj
        });
    }

    public static Database.DeleteResult[] deleteRecords(SObject[] objs) {
        String notDeletableSObjects = DatabaseUtils.hasNotDeletableObjects(objs);

        if (notDeletableSObjects != null) {

            throw new DatabaseUtilsException(
                    accessViolationException,
                    DatabaseUtilsException.ExceptionType.OBJECT_ACCESS_VIOLATION,
                    DatabaseUtilsException.ExceptionReason.NO_DELETE,
                    notDeletableSObjects,
                    null
            );
        }

        return Database.delete(objs); // False Positive 1
    }

    private static String hasNotCreateableFields(Schema.DescribeFieldResult[] fields) {
        String result = null;
        List<String> notCreateableFields = new List<String>();

        for (Schema.DescribeFieldResult field : fields) {
            if (field.getName() == 'Id') {
                continue;
            }

            if (!field.isCreateable()) {
                System.debug('field.getName()-'+field.getName());
                System.debug('field.isCreateable()-'+field.isCreateable());
                System.debug('field.isUpdateable()-'+field.isUpdateable());
                System.debug('field.isAccessible()-'+field.isAccessible());
                
                notCreateableFields.add(field.getName());
            }
        }
        if (!notCreateableFields.isEmpty()) {
            result = String.join(notCreateableFields, ', ');
        }

        return result;
    }

    private static String hasNotUpdateableFields(Schema.DescribeFieldResult[] fields) {
        String result = null;
        List<String> notUpdateableFields = new List<String>();

        for (Schema.DescribeFieldResult field : fields) {
            if (field.getName() == 'Id') {
                continue;
            }

            if (!field.isUpdateable()) {
                notUpdateableFields.add(field.getName());
            }
        }
        if (!notUpdateableFields.isEmpty()) {
            result = String.join(notUpdateableFields, ', ');
        }
        return result;
    }

    private static String hasNotCreateableObjects(sObject[] objs) {
        System.debug('objs-'+objs);
        String result = null;
        List<String> notCreateableObjects = new List<String>();
        Set<String> proceededObjects = new Set<String>();

        for (SObject obj : objs) {
            if (proceededObjects.contains(obj.getSObjectType().getDescribe().getName())) {
                continue;
            }

            if ((!obj.getSObjectType().getDescribe().isCreateable()) && (!obj.getSObjectType().getDescribe().isCustomSetting())) {
                System.debug('obj.getSObjectType().getDescribe().getName()--'+obj.getSObjectType().getDescribe().getName());
                System.debug('obj.getSObjectType().getDescribe().isCreateable()--'+obj.getSObjectType().getDescribe().isCreateable());
                notCreateableObjects.add(obj.getSObjectType().getDescribe().getName());
            }

            proceededObjects.add(obj.getSObjectType().getDescribe().getName());
        }
        if (!notCreateableObjects.isEmpty()) {
            result = String.join(notCreateableObjects, ', ');
        }
        return result;
    }

    private static String hasNotUpdateableObjects(sObject[] objs) {
        String result = null;
        List<String> notUpdateableObjects = new List<String>();
        Set<String> proceededObjects = new Set<String>();

        for (SObject obj : objs) {
            if (proceededObjects.contains(obj.getSObjectType().getDescribe().getName())) {
                continue;
            }

            if ((!obj.getSObjectType().getDescribe().isCustomSetting()) && (!obj.getSObjectType().getDescribe().isUpdateable())) {
                notUpdateableObjects.add(obj.getSObjectType().getDescribe().getName());
            }

            proceededObjects.add(obj.getSObjectType().getDescribe().getName());
        }
        if (!notUpdateableObjects.isEmpty()) {
            result = String.join(notUpdateableObjects, ', ');
        }
        return result;
    }

    private static String hasNotDeletableObjects(SObject[] objs) {
        String result = null;
        List<String> notDeletableObjects = new List<String>();
        Set<String> proceededObjects = new Set<String>();

        for (SObject obj : objs) {
            if (proceededObjects.contains(obj.getSObjectType().getDescribe().getName())) {
                continue;
            }

            if ((!obj.getSObjectType().getDescribe().isCustomSetting()) && (!obj.getSObjectType().getDescribe().isAccessible() || !obj.getSObjectType().getDescribe().isDeletable())) {
                notDeletableObjects.add(obj.getSObjectType().getDescribe().getName());
            }

            proceededObjects.add(obj.getSObjectType().getDescribe().getName());
        }
        if (!notDeletableObjects.isEmpty()) {
            result = String.join(notDeletableObjects, ', ');
        }
        return result;
    }

    private static DatabaseUtils.NotAcessibleFieldsByObjectWrapper hasNotAccessibleFieldsAndObjects(Map<Schema.DescribeSObjectResult, Schema.DescribeFieldResult[]> fieldsByObject) {
        DatabaseUtils.NotAcessibleFieldsByObjectWrapper result = new DatabaseUtils.NotAcessibleFieldsByObjectWrapper();

        for (Schema.DescribeSObjectResult obj : fieldsByObject.keySet()) {
            if (!obj.isAccessible()) {
                result.addSObjectError(obj);
            }

            if (!fieldsByObject.isEmpty()) {
                for (Schema.DescribeFieldResult field : fieldsByObject.get(obj)) {
                    if (!field.isAccessible()) {
                        result.addFieldError(obj, field);
                    }
                }
            } else {
                for (Schema.SObjectField field : obj.fields.getMap().values()) {
                    if (!field.getDescribe().isAccessible()) {
                        result.addFieldError(obj, field.getDescribe());
                    }
                }
            }

        }
        return result;
    }

    private class NotAcessibleFieldsByObjectWrapper {
        public Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>> notAccessibleFieldsPerObject { get; set; }

        public NotAcessibleFieldsByObjectWrapper() {
            this.notAccessibleFieldsPerObject = new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>();
        }

        public void addFieldError(Schema.DescribeSObjectResult sobjcectDescribe, Schema.DescribeFieldResult fieldDescribe) {
            List<Schema.DescribeFieldResult> notAccessibleFields = new List<Schema.DescribeFieldResult>();

            if (this.notAccessibleFieldsPerObject.containsKey(sobjcectDescribe)) {
                notAccessibleFields = this.notAccessibleFieldsPerObject.get(sobjcectDescribe);
            }

            notAccessibleFields.add(fieldDescribe);

            this.notAccessibleFieldsPerObject.put(sobjcectDescribe, notAccessibleFields);
        }

        public void addSObjectError(Schema.DescribeSObjectResult sobjcectDescribe) {
            if (!this.notAccessibleFieldsPerObject.containsKey(sobjcectDescribe)) {
                this.notAccessibleFieldsPerObject.put(sobjcectDescribe, new List<Schema.DescribeFieldResult>());
            }
        }

        public String getNotAccessibleObjectsAndFields() {
            Set<String> objectErrors = new Set<String>();

            for (Schema.DescribeSObjectResult objectDescribe : this.notAccessibleFieldsPerObject.keySet()) {
                String objectError = objectDescribe.getName();
                Set<String> notAccessibleFields = new Set<String>();

                for (Schema.DescribeFieldResult fieldDescribe : this.notAccessibleFieldsPerObject.get(objectDescribe)) {
                    notAccessibleFields.add(fieldDescribe.getName());
                }

                objectError += ' => ' + String.join(new List<String>(notAccessibleFields), ' , ');
                objectErrors.add(objectError);
            }

            return String.join(new List<String>(objectErrors), '; \n');
        }
    }

    public static Object getQueryFieldValue(String queryField, SObject obj) {
        List<String> fields = queryField.split('\\.');
        SObject targetSObject = obj;
        Object result;

        for (String field : fields) {
            if (targetSObject == null) {
                break;
            }

            if (field.endsWithIgnoreCase('__r')) {
                targetSObject = targetSObject.getSObject(field);
            } else {
                try {
                    targetSObject = targetSObject.getSObject(field);
                } catch (Exception e) {
                    result = targetSObject.get(field);
                }
            }
        }

        return result;
    }

    public static Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>> getFieldDescribeForSoqlByQueryFields(List<String> queryFields, Schema.DescribeSObjectResult targetSObject) {
        Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>> result = new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>();
        for (String queryField : queryFields) {
            Schema.DescribeSObjectResult targetTmp = targetSObject;
            List<String> queryFieldParts = queryField.split('\\.');

            for (String field : queryFieldParts) {

                String fieldTmp = field;

                if (field.endsWithIgnoreCase('__r')) {
                    fieldTmp = field.substringBeforeLast('__r') + '__c';
                }

                Set<Schema.DescribeFieldResult> fieldsDescribe = new Set<Schema.DescribeFieldResult>();

                if (result.containsKey(targetTmp)) {
                    fieldsDescribe = new Set<Schema.DescribeFieldResult>(result.get(targetTmp));
                }

                fieldsDescribe.add(targetTmp.fields.getMap().get(fieldTmp).getDescribe());
                result.put(targetTmp, new List<Schema.DescribeFieldResult>(fieldsDescribe));

                if (!targetTmp.fields.getMap().get(fieldTmp).getDescribe().getReferenceTo().isEmpty()) {
                    targetTmp = targetTmp.fields.getMap().get(fieldTmp).getDescribe().getReferenceTo().get(0).getDescribe();
                }
            }

        }

        return result;
    }
}