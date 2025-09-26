/**
 * REST API controller for creating support cases from external web and mobile applications.
 * Handles incoming case creation requests and logs all API interactions for debugging.
 * Tested by CaseCreationAPIController_Test.cls. This is for the purpose of Lyra Sr SF Dev take home assignment.
 * @author Anthony Kelly
 * @date September 2025
 */
@RestResource(urlMapping='/create-case/*')
global with sharing class CaseCreationApiController {
    
    /**
     * Handles the HTTP POST request to create a new Case.
     * Validates the request origin and logs the transaction details to API_Log__c (successes and failures).
     * @return CaseResponse - Contains success status, case ID, case number, and any messages.
     * @author Anthony Kelly
     * @date September 2025
     */
    @HttpPost
    global static CaseResponse createCase() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        CaseResponse caseResponse = new CaseResponse();
        API_Log__c apiLog = new API_Log__c();
        
        try {
            // Start capturing request details for the API log
            String requestBody = request.requestBody.toString();
            apiLog.Endpoint__c = '/create-case';
            apiLog.Request_Body__c = requestBody;
            apiLog.Timestamp__c = DateTime.now();
            
            // Deserialize the JSON request body into the wrapper class
            CaseRequest caseReq = (CaseRequest) JSON.deserialize(requestBody, CaseRequest.class);
            
            // Enforce allowed origins for external case creation
            if (caseReq.origin != 'web' && caseReq.origin != 'mobile') {
                throw new CaseCreationException('Only web and mobile origins are supported');
            }
            
            // Map the request data to the new Case SObject
            Case newCase = new Case();
            newCase.Subject = caseReq.subject;
            newCase.Description = caseReq.description;
            newCase.Status = caseReq.status;
            newCase.Origin = caseReq.origin;
            newCase.SuppliedName = caseReq.name;
            newCase.SuppliedPhone = caseReq.phone;
            newCase.SuppliedEmail = caseReq.email;
            
            insert newCase;
            
            // Fetch necessary details (like CaseNumber) from the newly created record
            Case createdCase = [SELECT Id, CaseNumber, Subject, Status, Origin 
                               FROM Case WHERE Id = :newCase.Id LIMIT 1];
            
            // Construct the successful response payload
            caseResponse.success = true;
            caseResponse.caseId = createdCase.Id;
            caseResponse.caseNumber = createdCase.CaseNumber;
            caseResponse.message = 'Case created successfully';
            response.statusCode = 201; // HTTP 201 Created
            
            // Log the successful outcome
            apiLog.Status_Code__c = 201;
            apiLog.Related_Case__c = createdCase.Id; 
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
            
        } catch (Exception ex) {
            // Standard exception handling block
            caseResponse.success = false;
            caseResponse.message = ex.getMessage();
            response.statusCode = 500;
            
            // Log the exception details
            apiLog.Status_Code__c = 500;
            apiLog.Error_Message__c = ex.getMessage() + '\n' + ex.getStackTraceString();
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
        }
        
        // Attempt to insert the log record outside the main try/catch to ensure
        // logging doesn't prevent a response from being returned.
        try {
            insert apiLog;
        } catch (Exception logEx) {
            // If logging fails, gracefully exit without blocking the user response
            System.debug('Failed to create API log: ' + logEx.getMessage());
        }
        
        return caseResponse;
    }
    
    // Request wrapper for mapping incoming POST reqs to Case fields via JSON
    global class CaseRequest {
        global String subject;
        global String description;
        global String status;
        global String origin;
        global String name;
        global String phone;
        global String email;
    }
    
    // Response handler data wrapper
    global class CaseResponse {
        global Boolean success;
        global String caseId;
        global String caseNumber;
        global String message;
    }
    
    // Custom exception type for this particular endpoint
    public class CaseCreationException extends Exception {}
}