@ isTest
private class FlosumDeploymentApprovalTriggerTest{
    public static testMethod void deploymentApprovalTestMethod() {
        Flosum__Organisation__c org = new Flosum__Organisation__c();
        org.Name = 'test';
        org.Flosum__Username__c = 'test@testOrg.com';
        insert org;

        Flosum__Snapshot__c Snap = new Flosum__Snapshot__c();
        snap.Name = 'test snap';
        snap.Flosum__Organisation__c = org.Id;
        snap.Flosum__Is_Completed__c = true;
        snap.Flosum__Last_Modified_In_Days__c = 14;
        insert snap;

        Flosum__Repository__c rep = new Flosum__Repository__c();
        rep.Name = 'repTest';
        insert rep;

        Flosum__Repository_Permission__c repPerm = new Flosum__Repository_Permission__c();
        repPerm.Flosum__Repository__c = rep.Id;
        repPerm.Flosum__User__c = UserInfo.getUserId();
        insert repPerm;

        Flosum__Branch__c br = new Flosum__Branch__c();
        br.Flosum__Branch_Name__c = 'Branch 1';
        br.Flosum__Repository__c = rep.Id;
        insert br;
        
        Flosum__Deployment_Approval__c depApproval = new Flosum__Deployment_Approval__c();
        depApproval.Flosum__Org__c = org.Id;
        insert depApproval;

        System.assertNotEquals(null, org.Id);
    }
}