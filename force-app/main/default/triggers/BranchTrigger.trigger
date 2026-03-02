trigger BranchTrigger on Flosum__Branch__c (after insert) {
    if(Trigger.IsInsert && Trigger.IsAfter) {
        //default group Label for Admin users.
        String defaultGroupName = 'Admins';
        //default permission set with custom permissions related to branch.
        String defaultPermissionSetName = 'Flosum.Release_Manager';
        
        List<Flosum__Branch_Permission__c> branchPermissionList = new List<Flosum__Branch_Permission__c>();
        List<Group> groupList = [SELECT Id,Name FROM Group WHERE Name=:defaultGroupName];
        if(!groupList.isEmpty()) {
            for(Flosum__Branch__c newBr : Trigger.New) {
                Flosum__Branch_Permission__c branchP = new Flosum__Branch_Permission__c();
                branchP.Flosum__Permissions__c = defaultPermissionSetName;
                branchP.Flosum__Group_Name__c = groupList[0].Name;
                branchP.Flosum__Group_ID__c = groupList[0].Id;
                branchP.Flosum__Branch__c = newBr.Id;
                branchPermissionList.add(branchP);
            }
        }
        if(!branchPermissionList.isEmpty()) {
            insert branchPermissionList;
        }
    }
}