# Lyra Sr SF Dev Case Creation API Take Home Assignment

## Login Credentials

Username: `lyra.tester@lyra.dev`  
Password: `LyraTesterDev1!`  
Org URL: https://orgfarm-a51b70979a-dev-ed.develop.my.salesforce.com

## What's Implemented

- REST API endpoint at `/services/apexrest/create-case/`
- Connected App with Client Credentials OAuth flow
- 97% test coverage
- API logging to custom object (API_Log__c)

## Testing the API
## IMPORTANT! The Connected App is set to run as 
The Connected App credentials are:
- Consumer Key: `3MVG9dAEux2v1sLuy170GPtyOCbTfBgnAXW3LCAJVAgj.jzsG8Oi7dARHjQw8c.UAeQ4RwIz7kXCBf23e64Sz`
- Consumer Secret: `F8DCF6DE97647A5476D084FFBCB63D3C8B636EA08707B99B8CBB00F75F888465`

API documentation with examples is in `/docs`.

## Verification

After logging in, you can:
- View the code under Setup > Apex Classes > CaseCreationApiController
- Check test coverage under Setup > Apex Test Execution
- See created cases under the Cases tab
- Review API logs by going to Gear Icon > Developer Console > Query Editor: `SELECT Id, Status_Code__c, Request_Body__c, Response_Body__c, Endpoint__c, Error_Message__c, Timestamp__c FROM API_Log__c ORDER BY CreatedDate DESC`

Anthony Kelly, September 2025.