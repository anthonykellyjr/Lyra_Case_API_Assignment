/**
 * REST API controller for creating support cases from external web and mobile applications.
 * Handles incoming case creation requests and logs all API interactions for debugging.
 * Tested by CaseCreationApiController_Test.cls. This is for the purpose of Lyra Sr SF Dev take home assignment.
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
            
            // Missing data (subject, status) will be assigned default values, but warning will be added to API Log
            List<String> warnings = new List<String>();
            
            // Assign a default value if subject or status are missing, but also create new line w/ warning in API log
             if (String.isBlank(caseReq.subject)) {
                caseReq.subject = 'Case created via API';
                warnings.add('Subject was empty, defaulted to: Case created via API');
            }
           
            if (String.isBlank(caseReq.status)) {
                caseReq.status = 'New';
                warnings.add('Status was empty, defaulted to: New');
            }
            
            // Validate origin - this one we still enforce
            if (caseReq.origin != 'web' && caseReq.origin != 'mobile') {
                throw new CaseCreationException('Only web and mobile origins are supported', 400);
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
            
            // Insert the case
            insert newCase;
            
            // Requery to get auto-generated fields like CaseNumber
            Case createdCase = [SELECT Id, CaseNumber, Subject, Status, Origin 
                               FROM Case WHERE Id = :newCase.Id LIMIT 1];
            
            // Construct the successful response payload
            caseResponse.success = true;
            caseResponse.caseId = createdCase.Id;
            caseResponse.caseNumber = createdCase.CaseNumber;
            caseResponse.message = 'Case created successfully';
            response.statusCode = 201;
            
            apiLog.Status_Code__c = 201;
            apiLog.Related_Case__c = createdCase.Id;
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
            
            // Concatenate warnings, separated by new line
            if (!warnings.isEmpty()) {
                apiLog.Error_Message__c = 'Warnings:\n' + String.join(warnings, '\n');
            }
            
        } catch (CaseCreationException caseEx) {
            // Handle validation errors with or without warnings
            caseResponse.success = false;
            caseResponse.message = caseEx.getMessage();
            response.statusCode = caseEx.statusCode;
            
            apiLog.Status_Code__c = caseEx.statusCode;
            apiLog.Error_Message__c = caseEx.getMessage();
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
            
        } catch (DMLException dmlEx) {
            // Handle caught DML exceptions
            caseResponse.success = false;
            caseResponse.message = 'Database error: ' + dmlEx.getDmlMessage(0);
            response.statusCode = 500;
            
            apiLog.Status_Code__c = 500;
            apiLog.Error_Message__c = dmlEx.getMessage() + '\n' + dmlEx.getStackTraceString();
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
            
        } catch (Exception ex) {
            // Handle any other unexpected errors
            caseResponse.success = false;
            caseResponse.message = 'Unexpected error: ' + ex.getMessage();
            response.statusCode = 500;
            
            apiLog.Status_Code__c = 500;
            apiLog.Error_Message__c = ex.getMessage() + '\n' + ex.getStackTraceString();
            apiLog.Response_Body__c = JSON.serialize(caseResponse);
        }
        
        // Insert log
        try {
            insert apiLog;
        } catch (Exception logEx) {
            System.debug('Failed to create API log: ' + logEx.getMessage()); // fail gracefully & don't block rest of transaction
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
    public class CaseCreationException extends Exception {
        public Integer statusCode { get; set; }
        
        public CaseCreationException(String message, Integer code) {
            this(message);
            this.statusCode = code;
        }
    }
}