@isTest
private class CaseCreationApiController_Test {
    
    @isTest
    static void testCreateCaseSuccessWeb() {
        // Prepare a request for a successful case submitted via the web portal.
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Cannot view my therapy session schedule';
        caseReq.description = 'I cannot confirm my appointment time for Thursday, & I really need to talk about my secret ident-- I mean, my job.';
        caseReq.status = 'New';
        caseReq.origin = 'web'; 
        caseReq.name = 'Peter Parker';
        caseReq.phone = '415-555-9012';
        caseReq.email = 'pparker@dailybugle.com'; // Photographer, The Daily Bugle, vigilante by night
        
        // Mock REST Req
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        // Verify successful creation (HTTP 201).
        System.assertEquals(true, result.success, 'The API should report successful case creation.');
        System.assertNotEquals(null, result.caseId, 'A valid Case ID must be returned in the response.');
        System.assertEquals(201, response.statusCode, 'HTTP status code must be 201 (Created).');
        
        // Verify the created case data in the database.
        Case createdCase = [SELECT Id, Subject, Origin, SuppliedName 
                            FROM Case WHERE Id = :result.caseId];
        System.assertEquals('cannot view my therapy session schedule', createdCase.Subject.toLowerCase(), 'The case subject should be accurately transferred.');
        System.assertEquals('web', createdCase.Origin.toLowerCase(), 'Origin should correctly be captured as "web".');
        System.assertEquals('peter parker', createdCase.SuppliedName.toLowerCase(), 'The supplied name must match the test data.');
        
        // Check that the API log captured the transaction.
        API_Log__c log = [SELECT Status_Code__c, Endpoint__c, Related_Case__c 
                          FROM API_Log__c LIMIT 1];
        System.assertEquals(201, log.Status_Code__c, 'Log status code should be 201 for a success.');
        System.assertEquals(createdCase.Id, log.Related_Case__c, 'The API log must link to the new Case record.');
    }
    
    @isTest
    static void testCreateCaseSuccessMobile() {
        // Test a successful request submitted from the mobile application.
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Push notifications failing after latest update';
        caseReq.description = 'I am not getting reminders for my coaching sessions on my iPhone 14 Pro.';
        caseReq.status = 'Working'; 
        caseReq.origin = 'mobile';
        caseReq.name = 'Traci Chapman';
        caseReq.phone = '650-555-3344';
        caseReq.email = 'tchapman@facebook.com'; // Music Supervisor, Facebook
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success, 'Mobile case creation should be successful.');
        System.assertEquals(201, response.statusCode, 'Status code should be 201.');
        
        Case createdCase = [SELECT Origin, Status FROM Case WHERE Id = :result.caseId];
        System.assertEquals('mobile', createdCase.Origin, 'Origin must be correctly set to mobile.');
        System.assertEquals('Working', createdCase.Status, 'The status should be accurately set to "Working".');
    }
    
    @isTest
    static void testInvalidOriginError() {
        // Set up a request that deliberately uses an invalid/unsupported origin.
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Attempt to bypass validation';
        caseReq.status = 'New';
        caseReq.origin = 'partner';  // Invalid origin for this API
        caseReq.name = 'Dirk Diggler'; // Actor, United Talent Management
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        // Assertions for the expected failure.
        System.assertEquals(false, result.success, 'The API must fail when an invalid origin is supplied.');
        System.assertEquals(500, response.statusCode, 'Expected HTTP 500 status code for a server-side exception.');
        System.assert(result.message.toLowerCase().contains('only web and mobile'), 'Error message must clearly state the origin requirement.');
        
        // Verify the API log captured the failure correctly.
        API_Log__c log = [SELECT Status_Code__c, Error_Message__c FROM API_Log__c LIMIT 1];
        System.assertEquals(500, log.Status_Code__c, 'Log status code must be 500 for an error.');
        System.assert(log.Error_Message__c != null, 'Log Error Message must be captured in this field.');
    }
    
    @isTest
    static void testMinimalFieldsSubmitted() {
        // Test case creation using only the essential required fields.
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Core functionality check';
        caseReq.status = 'New';
        caseReq.origin = 'web';
        // Note: name, phone, email, and description are purposefully left null.
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success, 'The API should handle minimal data successfully.');
        System.assertEquals(201, response.statusCode, 'Status code should be 201.');
        
        // Verify the optional fields are inserted as null.
        Case createdCase = [SELECT SuppliedName, SuppliedPhone, SuppliedEmail, Description 
                            FROM Case WHERE Id = :result.caseId];
        System.assertEquals(null, createdCase.SuppliedName, 'SuppliedName must be null if not provided.');
        System.assertEquals(null, createdCase.SuppliedPhone, 'SuppliedPhone must be null if not provided.');
        System.assertEquals(null, createdCase.SuppliedEmail, 'SuppliedEmail must be null if not provided.');
        System.assertEquals(null, createdCase.Description, 'Description must be null if not provided.');
    }
    
    @isTest
    static void testLargeDescriptionPayload() {
        // Stress test the description field long text field.
        CaseCreationApiController.CaseRequest caseReq = new CaseCreationApiController.CaseRequest();
        caseReq.subject = 'Detailed feedback on provider search filter';
        caseReq.description = 'I tried adjusting the filters for in-person visits to a 10-mile radius, but the list kept showing providers 50+ miles away. This detailed bug report is to ensure the character limit is robust. '.repeat(40);
        caseReq.status = 'New';
        caseReq.origin = 'web';
        caseReq.name = 'Leia Skywalker';
        caseReq.email = 'leiaskywalker@forceuniversity.edu'; // Professor, The Force University
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(caseReq));
        RestContext.request = request;
        RestContext.response = response;
        
        Test.startTest();
        CaseCreationApiController.CaseResponse result = CaseCreationApiController.createCase();
        Test.stopTest();
        
        System.assertEquals(true, result.success, 'Large data payloads should not cause the API to fail.');
        System.assertEquals(201, response.statusCode, 'Status code should be 201.');
        
        // Confirm the large text was successfully persisted.
        Case createdCase = [SELECT Description FROM Case WHERE Id = :result.caseId];
        System.assert(createdCase.Description.length() > 100, 'The full description should be inserted successfully.');
    }
}