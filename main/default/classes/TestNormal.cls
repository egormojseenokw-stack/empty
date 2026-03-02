public with sharing class TestNormal
{
    public List<SelectOption> leftOptionList{get;set;}
    public List<SelectOption> rightOptionList{get;set;}
    
    public TestNormal(){
        rightOptionList = new List<SelectOption>();
        leftOptionList = new List<SelectOption>();
        //listReviewerUsers();
        //insertAuth();
        checkAppSettingsCunstructor();
        
    }
    
    public void checkAppSettingsCunstructor(){     
        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
            Flosum__Quick_Retrieval_Settings__c.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                Flosum__Quick_Retrieval_Settings__c.Flosum__Enabled__c.getDescribe(),
                Flosum__Quick_Retrieval_Settings__c.Flosum__Named_Credential__c.getDescribe()
            }
        });
    }
    
    public void checkErrors(){
    
        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
            NamedCredential.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                NamedCredential.MasterLabel.getDescribe(),
                NamedCredential.DeveloperName.getDescribe(),
                NamedCredential.Endpoint.getDescribe()
            }
        });
        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
            Flosum__Quick_Retrieval_Settings__c.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                Flosum__Quick_Retrieval_Settings__c.Flosum__Enabled__c.getDescribe(),
                Flosum__Quick_Retrieval_Settings__c.Flosum__Named_Credential__c.getDescribe()
            }
        });
        
        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
            Flosum__Namespace_Setting__c.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                Flosum__Namespace_Setting__c.Flosum__Namespace_Prifix__c.getDescribe(),
                Flosum__Namespace_Setting__c.Flosum__Is_Selected__c.getDescribe()
            }
        });
    }
    
    public void listReviewerUsers(){
        Set<Id> permissionSetIds = new Set<Id>();
        String apiName = 'Approve_or_Reject_Pull_Request';
        String strNameSpace = 'Flosum';

        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
                SetupEntityAccess.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                        SetupEntityAccess.ParentId.getDescribe(),
                        SetupEntityAccess.SetupEntityId.getDescribe()
                },
                CustomPermission.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                        CustomPermission.DeveloperName.getDescribe(),
                        CustomPermission.NameSpacePrefix.getDescribe()
                }
        });
        for (SetupEntityAccess access : [
            SELECT ParentId 
            FROM SetupEntityAccess 
            WHERE SetupEntityId IN (
                SELECT Id 
                FROM CustomPermission 
                WHERE DeveloperName = :apiName AND NameSpacePrefix = :strNameSpace
            )
        ]) {
            permissionSetIds.add(access.ParentId);
        }

        DatabaseUtils.checkObjectsAndFieldsAccessibility(new Map<Schema.DescribeSObjectResult, List<Schema.DescribeFieldResult>>{
                User.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                        User.Name.getDescribe(),
                        User.Username.getDescribe(),
                        User.Username.getDescribe()
                },
                PermissionSetAssignment.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                        PermissionSetAssignment.AssigneeId.getDescribe(),
                        PermissionSetAssignment.PermissionSetId.getDescribe()
                }/*,
                UserPackageLicense.getSObjectType().getDescribe() => new List<Schema.DescribeFieldResult>{
                        UserPackageLicense.UserId.getDescribe()
                }*/
        });
        if(strNameSpace != ''){
            for(User ur:[SELECT Id,Name,Username FROM User WHERE Id !=:UserInfo.getUserId() AND 
                        Id IN (
                        SELECT AssigneeId FROM PermissionSetAssignment
                        WHERE PermissionSetId IN :permissionSetIds
                    ) AND ID IN (
                                   SELECT UserId 
                                   FROM UserPackageLicense 
                                   WHERE (PackageLicense.NamespacePrefix = :strNameSpace)
                               )  LIMIT 1000])
            {
                leftOptionList.add(new Selectoption(ur.id,ur.Name));
            }
        }
        else{
            for(User ur:[SELECT Id,Name,Username FROM User WHERE Id !=:UserInfo.getUserId() AND 
                        Id IN (
                        SELECT AssigneeId FROM PermissionSetAssignment
                        WHERE PermissionSetId IN :permissionSetIds
                    )  LIMIT 1000])
            {
                leftOptionList.add(new Selectoption(ur.id,ur.Name));
            }
        }
    }
    
    public void insertAuth(){
        List<sObject> orgLi = new List<sObject>();
        
        Flosum__Organisation__c orgRecord = new Flosum__Organisation__c();
        orgRecord.Name = 'organizationRecord.Name';
        orgRecord.Flosum__Username__c = 'OrgUserName';
        orgRecord.Flosum__Organisation_Type__c = 'organizationRecord.Organisation_Type__c'; 
        orgRecord.Flosum__HostName__c = 'IUrl';
        orgRecord.Flosum__User_Full_Name__c = 'UserFullName';
        orgRecord.Flosum__Organisation_ID__c = 'OrganisationId';
        orgLi.add(orgRecord);

        Flosum__AuthorizationDetails__c detail = new Flosum__AuthorizationDetails__c();
        detail.Flosum__AccessToken__c = 'AToken';
        detail.Flosum__RefreshToken__c = 'RToken';
        detail.Flosum__AuthorisedUser__c = 'OrgUserName';
        detail.Name= 'OrganisationId';
        detail.Flosum__InstanceURL__c= 'IUrl';
        detail.Flosum__Connected_App_Type__c = 'selectedAuthType';
        orgLi.add(detail);
        
        if(orgLi.size() > 0)
        {
            //insert orgLi;
            Database.SaveResult[] resLi = DatabaseUtils.insertRecords(
                    orgLi,
                    new List<Schema.DescribeFieldResult>{
                            Flosum__Organisation__c.Name.getDescribe(),
                            Flosum__Organisation__c.Flosum__Username__c.getDescribe(),
                            Flosum__Organisation__c.Flosum__Organisation_Type__c.getDescribe(),
                            Flosum__Organisation__c.Flosum__HostName__c.getDescribe(),
                            Flosum__Organisation__c.Flosum__User_Full_Name__c.getDescribe(),
                            Flosum__Organisation__c.Flosum__Organisation_ID__c.getDescribe()
                    }
            );
            System.debug(resLi);
            //DatabaseUtils.updateRecords(orgLi,new List<Schema.DescribeFieldResult>{});
            DatabaseUtils.deleteRecords(orgLi);
        }
    }
}