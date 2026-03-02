public with sharing class AccessCheck {
    Set<Id> permissionSetIds = new Set<Id>();
    String apiName = 'Approve_or_Reject_Pull_Request';
    String strNameSpace = 'Flosum';
    public AccessCheck() {
        method1();
        method2();
    }
    
    public void method1() {
    }
    
    public void method2() {
        System.debug([SELECT AssigneeId FROM PermissionSetAssignment]);
        System.debug([SELECT PackageLicenseId FROM UserPackageLicense]);
        System.debug([SELECT Id FROM PackageLicense]);
        System.debug([SELECT ParentId FROM SetupEntityAccess]);
        System.debug([SELECT Id FROM CustomPermission]);
        System.debug([SELECT Id FROM AsyncApexJob]);
        System.debug([SELECT Id FROM ApexClass]);
        System.debug([SELECT Name, TableEnumOrId FROM ApexTrigger]);
        System.debug([SELECT id FROM CronTrigger]);
        System.debug([SELECT OrganizationType, IsSandbox FROM Organization]);
        System.debug([SELECT Id, DeveloperName FROM CustomNotificationType]);
        System.debug([SELECT Id, Name FROM StaticResource]);
        System.debug([SELECT Id FROM PermissionSet]);
        System.debug([SELECT Id, DeveloperName FROM Group]);
        System.debug([SELECT Id, GroupId, UserOrGroupId FROM GroupMember]);
        String APP_NAMESPACE_PREFIX = 'Flosum';
        List<NamedCredential> licensedUsers = [
           SELECT DeveloperName FROM NamedCredential
        ];
        System.debug(licensedUsers);
    }
}