trigger AccountTrigger on Account (before insert) {

    System.debug(
        'Handler in use: ' + AccountTriggerHandler.HANDLER_NAME
    );

    AccountTriggerHandler.Result result =
        AccountTriggerHandler.beforeInsert(Trigger.new);

    // Явная логика на основе результата класса
    if (result.hasErrors) {
        System.debug('Trigger detected handler errors');
    }

    System.debug(
        'Created Test__c records: ' + result.createdTests
    );
}