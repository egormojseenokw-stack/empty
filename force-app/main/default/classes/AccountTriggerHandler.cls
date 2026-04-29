public with sharing class AccountTriggerHandler {

    public static final String HANDLER_NAME = 'AccountTriggerHandler_v2';

    public enum TestStatus {
        CREATED,
        ERROR
    }

    public class Result {
        public Integer createdTests;
        public Boolean hasErrors;
    }

    public static Result beforeInsert(List<Account> newAccounts) {

        Result r = new Result();
        r.createdTests = 0;
        r.hasErrors = false;

        List<Test__c> testsToInsert = new List<Test__c>();

        for (Account acc : newAccounts) {
            if (String.isBlank(acc.Name)) {
                acc.addError('Account Name is required');
                r.hasErrors = true;
                continue;
            }

            Test__c t = new Test__c(
                Name = 'Auto for ' + acc.Name
            );

            testsToInsert.add(t);
        }

        if (!testsToInsert.isEmpty()) {
            insert testsToInsert;
            r.createdTests = testsToInsert.size();
        }

        return r;
    }
}