@isTest
private class CaseCreationApiController_Test {
    
    
    static void newRestContext(CaseCreationApiController.CaseRequest caseReq) {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
    }
    
    // Test case submission from web context
    @isTest
    static void testCreateCaseSuccessWeb() {
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Cannot view my therapy session schedule';
        caseReq.description = 'I cannot confirm my appointment time for Thursday, & I really need to talk about my secret ident-- I mean, my job.';
        caseReq.status = 'New';
        caseReq.origin = 'web'; 
        caseReq.name = 'Peter Parker';
        caseReq.phone = '415-555-9012';
        caseReq.email = 'pparker@dailybugle.com';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        // Should succeed with 201
        System.assertEquals(true, result.success);
        System.assertNotEquals(null, result.caseId);
        System.assertEquals(201, RestContext.response.statusCode);
        
        // Check the case was created properly
        Case createdCase = [SELECT Id, Subject, Origin, SuppliedName 
                            FROM Case WHERE Id = :result.caseId];
        System.assertEquals('cannot view my therapy session schedule', createdCase.Subject.toLowerCase());
        System.assertEquals('web', createdCase.Origin.toLowerCase());
        System.assertEquals('peter parker', createdCase.SuppliedName.toLowerCase());
        
        // Verify logging worked
        API_Log__c log = [SELECT Status_Code__c, Endpoint__c, Related_Case__c 
                          FROM API_Log__c LIMIT 1];
        System.assertEquals(201, log.Status_Code__c);
        System.assertEquals(createdCase.Id, log.Related_Case__c);
    }
    
    @isTest
    static void testCreateCaseSuccessMobile() {
        // Mobile app submission
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Push notifications failing after latest update';
        caseReq.description = 'I am not getting reminders for my coaching sessions on my iPhone 14 Pro.';
        caseReq.status = 'Working'; 
        caseReq.origin = 'mobile';
        caseReq.name = 'Traci Chapman';
        caseReq.phone = '650-555-3344';
        caseReq.email = 'tchapman@facebook.com';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assertEquals(201, RestContext.response.statusCode);
        
        Case createdCase = [SELECT Origin, Status FROM Case WHERE Id = :result.caseId];
        System.assertEquals('mobile', createdCase.Origin);
        System.assertEquals('Working', createdCase.Status);
    }
    
    @isTest
    static void testInvalidOriginError() {
        // Invalid origin should throw 400, not 500
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Attempt to bypass validation';
        caseReq.status = 'New';
        caseReq.origin = 'partner';  // Invalid
        caseReq.name = 'Dirk Diggler';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        // Should fail with 400 for validation error
        System.assertEquals(false, result.success);
        System.assertEquals(400, RestContext.response.statusCode);
        System.assert(result.message.toLowerCase().contains('only web and mobile'));
        
        // Check error was logged
        API_Log__c log = [SELECT Status_Code__c, Error_Message__c FROM API_Log__c LIMIT 1];
        System.assertEquals(400, log.Status_Code__c);
        System.assert(log.Error_Message__c != null);
    }
    
    @isTest
    static void testMissingFieldsWithDefaults() {
        // Missing subject and status should get defaults and warnings
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.origin = 'web';
        caseReq.name = 'Anonymous User';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success); // succeeded with warnings
        System.assertEquals(201, RestContext.response.statusCode);
        
        // Default subject & status should have been set
        Case createdCase = [SELECT Subject, Status FROM Case WHERE Id = :result.caseId];
        System.assertEquals('Case created via API', createdCase.Subject);
        System.assertEquals('New', createdCase.Status);
        
        // Warnings should have logged, despite success
        API_Log__c log = [SELECT Error_Message__c FROM API_Log__c LIMIT 1];
        System.assert(log.Error_Message__c.contains('Warnings:'));
        System.assert(log.Error_Message__c.contains('Subject was empty'));
        System.assert(log.Error_Message__c.contains('Status was empty'));
    }
    
    @isTest
    static void testLargeDescriptionPayload() {

        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Detailed feedback on provider search filter';
        caseReq.description = 'I tried adjusting the filters for in-person visits to a 10-mile radius, but the list kept showing providers 50+ miles away. This detailed bug report is to ensure the character limit is enough to log a thorough case report. '.repeat(40);
        caseReq.status = 'New';
        caseReq.origin = 'web';
        caseReq.name = 'Leia Skywalker';
        caseReq.email = 'leiaskywalker@forceuniversity.edu';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success);
        System.assertEquals(201, RestContext.response.statusCode);
        
        // Make sure the long text saved
        Case createdCase = [SELECT Description FROM Case WHERE Id = :result.caseId];
        System.assert(createdCase.Description.length() > 100);
    }

    // Force DML exception on case using invalid status (if picklist were enforced)
    @isTest
    static void testDMLException() {
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Test DML Error';
        caseReq.status = 'InvalidStatus123';
        caseReq.origin = 'web';
        
        newRestContext(caseReq);
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        // DML Errors caught
        if (!result.success && result.message.contains('Database error')) {
            System.assertEquals(500, RestContext.response.statusCode);
            API_Log__c log = [SELECT Status_Code__c, Error_Message__c FROM API_Log__c LIMIT 1];
            System.assertEquals(500, log.Status_Code__c);
        }
    }

    // Test malformed request body deserialization mapping attempt
    @isTest
    static void testJSONDeserializationError() {
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf('{"invalid json}'); // Malformed JSON
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(false, result.success);
        System.assertEquals(500, RestContext.response.statusCode);
        System.assert(result.message.contains('Unexpected error'));
        
        API_Log__c log = [SELECT Status_Code__c FROM API_Log__c LIMIT 1];
        System.assertEquals(500, log.Status_Code__c);
    }
}