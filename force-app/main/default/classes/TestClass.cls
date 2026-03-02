@isTest
private class TestClass {
    
    @testSetup static void dataSetup() {
        // Get test Admin profile user form testDataUtils class to runn as admin
        List<User> adminUser = TestDataUtils.getUsers(1);    // Run as system admin user
        System.runAs(adminUser[0]) {
          // Create Repository
          List<Flosum__Repository__c> repositoryRecordList = TestDataUtils.getRepositories(1);
          insert repositoryRecordList;
          // Assign License to repository
          Flosum__Repository_Permission__c repositoryPermissionRecord =
              TestDataUtils.repoPermission(repositoryRecordList[0].id, adminUser[0].id);
          insert repositoryPermissionRecord;
          // Create a Branch Record
          List<Flosum__Branch__c> listBranchDetails = TestDataUtils.getBranches(1);
          listBranchDetails[0].Flosum__Repository__c = repositoryRecordList[0].id;
          insert listBranchDetails;
          // Create Manual Step
          List<Flosum__Manual_Step__c> listManualStep = TestDataUtils.getManualStep(1);
          listManualStep[0].Name = 'System.Label.SCA_Manual_Step_Record_Name';
          listManualStep[0].Flosum__Sequence__c = 1;
          listManualStep[0].Flosum__Type__c = 'pre';
          insert listManualStep;
          // Create Components and attach it to Branch
          List<Flosum__Component__c> branchComponentList = new List<Flosum__Component__c>();
          branchComponentList.addAll(TestDataUtils.getComponents(1, 'ApexClass'));
          branchComponentList.addAll(TestDataUtils.getComponents(1, 'ApexTrigger'));
          branchComponentList.addAll(TestDataUtils.getComponents(1, 'Flow'));
          for (integer i = 0; i < branchComponentList.size(); i++) {
            branchComponentList[i].Flosum__Branch__c = listBranchDetails[0].id;
          }
          insert branchComponentList;
          // Create a Peer Review Record
          List<Flosum__Pull_Request__c> peerReviewDetailsList =
              TestDataUtils.getPeerReviews(listBranchDetails[0].id, 2);
          insert peerReviewDetailsList;
        }  // end of run as System Admin
    }
    
      /**
   * @description: Cover afterInsertAndUndelete method coverage
   */
  @isTest static void afterInsertAndUndeleteTest() {
    // clang-format off
    List<User> adminUser = TestDataUtils.getUsers(4);
    insert adminUser[2];
    insert adminUser[3];
      
    // clang-format on
    // Run as test system admin user
    System.runAs(adminUser[1]) {
    // clang-format off
          List<Flosum__Branch__c> branchDetailsList = [
              SELECT
               id,
               Name
              FROM Flosum__Branch__c
          ];
          List<Flosum__Pull_Request__c> peerReviewList = [
              SELECT
               id
              FROM Flosum__Pull_Request__c
              LIMIT 1
          ];
      // clang-format on
      List<Flosum__Pull_Request_Reviewer__c> peerReviewerList =
          TestDataUtils.getPeerReviewers(peerReviewList[0].id, adminUser[2].id, 'Pending', 1);
      peerReviewerList.addAll(
          TestDataUtils.getPeerReviewers(peerReviewList[0].id, adminUser[3].id, 'Pending', 1));
      Test.startTest();
      insert peerReviewerList;
      // delete to Cover the delete method in PeerReviewerTriggerHandler
      delete peerReviewerList[0];
      // undelete to Cover the undelete method in PeerReviewerTriggerHandler
      undelete peerReviewerList[0];
      delete peerReviewerList;
      Test.stopTest();
      List<Flosum__Pull_Request_Reviewer__c> listPeerReviewerList = [
        SELECT id
        FROM Flosum__Pull_Request_Reviewer__c
      ];
      System.assertEquals(
          listPeerReviewerList.size(), 0, 'There should be 0 Peer Reviewer  Record');
      
    } // end of run as System Admin
  }   // end afterInsertAndUndeleteTest

  /**
   * @description: Cover afterUpdate method coverage
   */
  @isTest static void afterUpdateTest() {
    // clang-format off
    List<User> adminUser = TestDataUtils.getUsers(4);
    insert adminUser[2];
    insert adminUser[3];
    // clang-format on
    // Run as test system admin user
    System.runAs(adminUser[1]) {
    // clang-format off
          List<Flosum__Branch__c> branchDetailsList = [
              SELECT
               id,
               Name
              FROM Flosum__Branch__c
          ];
          List<Flosum__Pull_Request__c> peerReviewList = [
              SELECT
               id
              FROM Flosum__Pull_Request__c
          ];
      // clang-format on
      List<Flosum__Pull_Request_Reviewer__c> peerReviewerList =
          TestDataUtils.getPeerReviewers(peerReviewList[0].id, adminUser[2].id, 'Pending', 1);
      peerReviewerList.addAll(
          TestDataUtils.getPeerReviewers(peerReviewList[0].id, adminUser[3].id, 'Pending', 1));
      Test.startTest();
      insert peerReviewerList;
      peerReviewerList[0].Flosum__Pull_Request__c = peerReviewList[1].id;
      update peerReviewerList[0];
      peerReviewerList[0].Flosum__Status__c = 'Approved';
      update peerReviewerList[0];
      Test.stopTest();
      List<Flosum__Pull_Request_Reviewer__c> updatedPeerReviewerList1 = [
        SELECT id
        FROM Flosum__Pull_Request_Reviewer__c
        WHERE
         Flosum__Pull_Request__c =:peerReviewList[0].id
      ];
      List<Flosum__Pull_Request_Reviewer__c> updatedPeerReviewerList2 = [
        SELECT id
        FROM Flosum__Pull_Request_Reviewer__c
        WHERE Flosum__Pull_Request__c =:peerReviewList[1].id
      ];
      System.assertEquals(updatedPeerReviewerList1.size(),
          1,
          'There should be 1 Peer Reviewer for peerReviewList[0] Record');
      System.assertEquals(updatedPeerReviewerList2.size(),
          1,
          'There should be 1 Peer Reviewer for peerReviewList[1] Record');
    } // end of run as System Admin
  }   // end afterUpdateTest
}