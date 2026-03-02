/**
 * @description: Generic class intended for test data setup
 */
@isTest public class TestDataUtils {
  /**
   * @description: Create Test Users
   * @param: Count
   * @return: List of Users based on the count specified
   **/
  public
  static List<User> getUsers(Integer count) {
    // clang-format off
    Profile adminProfile = [
        SELECT Id
        FROM Profile
        WHERE
         Name = 'System Administrator'
    ];
    // clang-format on
    List<User> lstUsers = new List<User>();
    for (Integer index = 1; index <= count; index++) {
      lstUsers.add(new User(FirstName = 'Test',
          LastName = 'User' + index,
          ProfileId = adminProfile.Id,
          alias = 'user' + index,
          emailencodingkey = 'UTF-8',
          languagelocalekey = 'en_US',
          localesidkey = 'en_US',
          timezonesidkey = 'America/Los_Angeles',
          isActive=true,
          Username = 'Flosumtestuser' + index + '@testmember.com',
          Email = 'test' + index + '@test.com'));
    }  // End for
    return lstUsers;
  }  // End getUsers method

  /**
   * @description: Create Test Users
   * @param: Count
   * @param: profile
   * @return: List of Users based on the count and profile specified
   **/
  public
  static List<User> getUsers(Integer count, String profile) {
    // clang-format off
    Profile profileInfo = [
        SELECT Id
        FROM Profile
        WHERE
         Name =:profile
    ];
    // clang-format on
    List<User> lstUsers = new List<User>();
    for (Integer index = 1; index <= count; index++) {
      lstUsers.add(new User(FirstName = 'Test',
          LastName = 'User' + index,
          ProfileId = profileInfo.Id,
          alias = 'user' + index,
          emailencodingkey = 'UTF-8',
          languagelocalekey = 'en_US',
          localesidkey = 'en_US',
          timezonesidkey = 'America/Los_Angeles',
          Username = 'testuser' + index + '@testmember.com',
          Email = 'test' + index + '@test.com',
          IsActive=true));
    }  // End for
    return lstUsers;
  }  // End getUsers method

  /**
   * @description: Create Repository
   * @param: Count
   * @return: List of Repository based on the count specified
   **/
  public
  static List<Flosum__Repository__c> getRepositories(integer count) {
    List<Flosum__Repository__c> listOfFlosumRepository = new List<Flosum__Repository__c>();
    for (integer index = 1; index <= count; index++) {
      listOfFlosumRepository.add(
          new Flosum__Repository__c(Name = 'Pragathi', Flosum__Repository_Type__c = 'Vlocity'));
    }
    return listOfFlosumRepository;
  }

  /**
   * @description: Assign Permission to the  Repository
   * @param: repository Id
   * @param: userId
   * @return: Flosum__Repository_Permission__c record
   **/
  public
  static Flosum__Repository_Permission__c repoPermission(id repositoryId, Id userId) {
    Flosum__Repository_Permission__c repoPermission = new Flosum__Repository_Permission__c(
        Flosum__Repository__c = repositoryId, Flosum__User__c = userId);
    return repoPermission;
  }
  /**
   * @description: Create Org Record
   * @param: Count
   * @return: Snapshot Record based on the  count specified
   **/
  public
  static Flosum__Organisation__c getOrgs() {
    Flosum__Organisation__c orgRecord = new Flosum__Organisation__c(Name = 'Dev',
        Flosum__Username__c = 'test.flosum@google.com.dev',
        Flosum__Organisation_Type__c = 'Sandbox');
    return orgRecord;
  }

  /**
   * @description: Create Snapshot
   * @param: Count
   * @return: Snapshot Record based on the  count specified
   **/
  public
  static List<Flosum__Snapshot__c> getSnapshots(Id orgId, Integer count) {
    List<Flosum__Snapshot__c> listOfSnapshot = new List<Flosum__Snapshot__c>();
    for (Integer index = 1; index <= count; index++) {
      Flosum__Snapshot__c snapshotRecord = new Flosum__Snapshot__c(Name = 'Sample Snapshot' + index,
          Flosum__Is_Completed__c = True,
          Flosum__Organisation__c = orgId);
      listOfSnapshot.add(snapshotRecord);
    }
    return listOfSnapshot;
  }

  /**
   * @description: Create Components
   * @param: Count
   * @param: Component Type
   * @param: Branch Id
   * @return: List of Components based on the count,Component Type and Branch specified
   **/
  public
  static List<Flosum__Component__c> getComponents(Integer count, String componentType) {
    List<Flosum__Component__c> listOfcomponents = new List<Flosum__Component__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfcomponents.add(new Flosum__Component__c(
          Flosum__Component_Name__c = 'Sample Component' + index,
          Flosum__Component_Type__c = ComponentType,
          RecordTypeId = Schema.SObjectType.Flosum__Component__c.getRecordTypeInfosByDeveloperName()
                             .get('Branch')
                             .getRecordTypeId()));
    }
    return listOfcomponents;
  }

  /**
   * @description: Create Component History Record
   * @param: Component Id
   * @return: Components History
   **/
  public
  static Flosum__Component_History__c getComponentHistory(Id idFlosumComponent) {
    Flosum__Component_History__c componentHistoryRecord = new Flosum__Component_History__c();
    componentHistoryRecord.Flosum__Component__c = idFlosumComponent;
    componentHistoryRecord.Flosum__Version__c = Decimal.valueof('1');
    return componentHistoryRecord;
  }    
  /**
   * @description: Create Metadata Items
   * @param: Count
   * @param: Component Type
   * @param: Snapshot Id
   * @return: List of MetadataItems based on the count,SnapshotId and RecordType specified
   **/
  public
  static List<Flosum__Metadata_Item__c> getComponents(Id snapshotid, Integer count, Id recordType) {
    List<Flosum__Metadata_Item__c> listOfMetadata = new List<Flosum__Metadata_Item__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfMetadata.add(new Flosum__Metadata_Item__c(Flosum__Label__c = 'Item' + index,
          Flosum__Name__c = 'Item' + index,
          RecordTypeId = recordType));
    }
    return listOfMetadata;
  }

  /**
   * @description: Create Branch Record
   * @param: Count
   * @return: List of MetadataItems based on the count,SnapshotId and RecordType specified
   **/
  public
  static List<Flosum__Branch__c> getBranches(Integer count) {
    List<Flosum__Branch__c> listOfBranch = new List<Flosum__Branch__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfBranch.add(new Flosum__Branch__c(Flosum__Branch_Name__c = 'feature/W-123456' + index));
    }
    return listOfBranch;
  }

  /**
   * @description: Create ReviewHistory
   * @param: Count
   * @return: List of ReviewHistory based on the count
   **/
  /*public
  static List<SCA_Review_History__c> getReviewHistory(Integer count) {
    List<SCA_Review_History__c> listOfReviewHistory = new List<SCA_Review_History__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfReviewHistory.add(new SCA_Review_History__c());
    }
    return listOfReviewHistory;
  }*/

  /**
   * @description: Create Attachment
   * @param: Count
   * @return: List of Attachments based on the count
   **/
  public
  static List<Attachment> getAttachment(Integer count) {
    List<Attachment> attachmentsList = new List<Attachment>();
    for (Integer index = 1; index <= count; index++) {
      attachmentsList.add(new Attachment());
    }
    return attachmentsList;
  }

  /**
   * @description: Create ReviewHistory
   * @param: Count
   * @return: List of ReviewHistory based on the count
   **/
  /*public
  static List<SCA_Violations__c> getViolationRecords(Integer count) {
    List<SCA_Violations__c> violationRecordsList = new List<SCA_Violations__c>();
    for (Integer index = 1; index <= count; index++) {
      violationRecordsList.add(new SCA_Violations__c());
    }
    return ViolationRecordsList;
  }*/

  /**
   * @description: Create Deployment Approval Record
   * @param: processType , testClassParam
   * @return: Deployment Approval record
   **/
  public
  static Flosum__Deployment_Approval__c getDeploymentApprovaslRec(
      String processType, String testClassParam) {
    Flosum__Deployment_Approval__c deploymentApprovalRec = new Flosum__Deployment_Approval__c(
        Flosum__Run_Test_Param__c = testClassParam, Flosum__Process_Type__c = processType);
    return deploymentApprovalRec;
  }

  /**
   * @description: Create Peer Review Record
   * @param: branchId , count
   * @return: List of PeerReviews based on the count and branchId specified
   **/
  public
  static List<Flosum__Pull_Request__c> getPeerReviews(Id branchId, Integer count) {
    List<Flosum__Pull_Request__c> listOfPeerReviews = new List<Flosum__Pull_Request__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfPeerReviews.add(
          new Flosum__Pull_Request__c(Name = 'Sample Name ' + index, Flosum__Branch__c = branchId));
    }
    return listOfPeerReviews;
  }

  /**
   * @description: Create RelatedManualStep Record
   * @param: Count
   * @return: List of RelatedManualStep based on the count
   **/
  public
  static List<Flosum__Related_Manual_Step__c> getRelatedManualStep(Integer count) {
    List<Flosum__Related_Manual_Step__c> listRelatedManualStep =
        new List<Flosum__Related_Manual_Step__c>();
    for (Integer index = 1; index <= count; index++) {
      listRelatedManualStep.add(new Flosum__Related_Manual_Step__c());
    }
    return listRelatedManualStep;
  }
  /**
   * @description: Create ManualStep Record
   * @param: Count
   * @return: List of ManualStep based on the count
   **/
  public
  static List<Flosum__Manual_Step__c> getManualStep(Integer count) {
    List<Flosum__Manual_Step__c> listManualStep = new List<Flosum__Manual_Step__c>();
    for (Integer index = 1; index <= count; index++) {
      listManualStep.add(new Flosum__Manual_Step__c());
    }
    return listManualStep;
  }

  /**
   * @description: Create Peer Reviewer Records
   * @param: peerReviewId, userId, status, count
   * @return: List of PeerReviewers based on the peerReviewId, userId, status and count specified
   **/
  public
  static List<Flosum__Pull_Request_Reviewer__c> getPeerReviewers(
      Id peerReviewId, Id userId, String status, Integer count) {
    List<Flosum__Pull_Request_Reviewer__c> listOfPeerReviewers =
        new List<Flosum__Pull_Request_Reviewer__c>();
    for (Integer index = 1; index <= count; index++) {
      listOfPeerReviewers.add(
          new Flosum__Pull_Request_Reviewer__c(Flosum__Pull_Request__c = peerReviewId,
              Flosum__User__c = userId,
              Flosum__Status__c = status));
    }
    return listOfPeerReviewers;
  }
}