trigger DeploymentApprovalTrigger on Flosum__Deployment_Approval__c (before insert) {
  if(Trigger.isBefore && Trigger.IsInsert)
  {
    Map<String,String> orgNameIdMap = new Map<String,String>();
    for(Flosum__Organisation__c org : [SELECT Id,Name FROM Flosum__Organisation__c])
    {
      orgNameIdMap.put(org.Id,org.Name);
    }
    for(Flosum__Deployment_Approval__c aprroval : Trigger.New)
    {
      String orgName = orgNameIdMap.get(aprroval.Flosum__Org__c);
      if(orgName == 'Production')
      {
        aprroval.addError('You can not deploy to this organization.');
      }
    }
  }
}