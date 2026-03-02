public with sharing class RepositoryPurge implements Database.batchable<sobject> {
    /*
    //Use the following code to trigger this batch:
    String repoId = '<repository record Id>';
    Integer versionHistoryDeleteLimit = 10;// it will not delete latest 10 versions.
    Database.executeBatch(new RepositoryPurge(repoId, versionHistoryDeleteLimit), 2);
    */
    public String repoId;
    public Integer versionHistoryDeleteLimit = 10;
    String batchQuery = 'SELECT Id FROM Flosum__Component__c WHERE Flosum__Repository__c=:repoId AND Flosum__Version__c >:versionHistoryDeleteLimit';
    
    public RepositoryPurge(String repoId, Integer versionHistoryDeleteLimit) {
        this.repoId = repoId;
        this.versionHistoryDeleteLimit = versionHistoryDeleteLimit;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(batchQuery);
    }

    public void execute(Database.BatchableContext info, List<sObject> scope) {
        List<Flosum__Component__c> compList = (List<Flosum__Component__c>) scope;
        Set<String> historySet = new Set<String>();
        Set<String> compIdSet = new Set<String>();
        for(Flosum__Component__c comp : compList) {
            compIdSet.add(comp.Id);
        }
        for(Flosum__Component__c comp : [
            SELECT Id, 
            (Select Id,Flosum__Version__c FROM Flosum__Components__r ORDER BY Flosum__Version__c DESC) 
            FROM Flosum__Component__c 
            WHERE Id IN:compIdSet
        ]) {
            if(comp.Flosum__Components__r.size() > versionHistoryDeleteLimit) {
                for(Integer index=versionHistoryDeleteLimit; index < comp.Flosum__Components__r.size(); index++) {
                    Flosum__Component_History__c his = comp.Flosum__Components__r[index];
                    historySet.add(his.Id);
                }
            }
        }
        if(!historySet.isEmpty()) {
            List<Flosum__Commit_Manifest__c> commitManiList = [
                SELECT Id
                FROM Flosum__Commit_Manifest__c
                WHERE Flosum__Component_History__c IN :historySet
            ];

            if (!commitManiList.isEmpty()) {
                delete commitManiList;
            }

            List<Flosum__Build_Manifest__c> buildManiList = [
                SELECT Id
                FROM Flosum__Build_Manifest__c
                WHERE Flosum__Component_History__c IN :historySet
            ];

            if (!buildManiList.isEmpty()) {
                delete buildManiList;
            }

            List<Flosum__Component_History__c> hisList = [SELECT Id FROM Flosum__Component_History__c WHERE Id IN :historySet];
            if (!hisList.isEmpty()) {
                delete hisList;
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
    }
}