# Case API Documentation

## Quick Test

From a terminal, run the cURL command to get a token:
```bash
curl -X POST https://orgfarm-a51b70979a-dev-ed.develop.my.salesforce.com/services/oauth2/token \
  -d "grant_type=client_credentials" \
  -d "client_id=3MVG9dAEux2v1sLuy170GPtyOCbTfBgnAXW3LCAJVAgj.jzsG8Oi7dARHjQw8c.UAeQ4RwIz7kXCBf23e64Sz" \
  -d "client_secret=F8DCF6DE97647A5476D084FFBCB63D3C8B636EA08707B99B8CBB00F75F888465"
```

Use that token to create a case:
## REPLACE [PUT YOUR TOKEN HERE] WITH VALUE RETURNED FROM STEP 1!
```bash
curl -X POST https://orgfarm-a51b70979a-dev-ed.develop.my.salesforce.com/services/apexrest/create-case/ \
  -H "Authorization: Bearer [PUT_YOUR_TOKEN_HERE]" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Test case from API",
    "description": "Testing if this works",
    "status": "New",
    "origin": "web",
    "name": "API Tester",
    "phone": "555-1234",
    "email": "test@test.com"
  }'
```

## Field mapping

- `subject` > Case.Subject
- `description` > Case.Description  
- `status` > Case.Status (use "New")
- `origin` > Case.Origin (must be "web" or "mobile")
- `name` > Case.SuppliedName
- `phone` > Case.SuppliedPhone
- `email` > Case.SuppliedEmail

## Errors

If origin isn't "web" or "mobile", you'll get a 500 error.

If you see an error, go to Gear Icon > Developer Console > Query Editor, and run SOQL query to see what occurred

`SELECT Id, Status_Code__c, Request_Body__c, Response_Body__c, Endpoint__c, Error_Message__c, Timestamp__c FROM API_Log__c WHERE Error_Message__c != null ORDER BY CreatedDate DESC`