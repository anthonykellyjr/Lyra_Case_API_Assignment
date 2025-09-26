# As I am using a Windows machine, I've created a Powershell version of the script for PC, and bash shell script for Mac/Linux.
# Run from project root directory

Write-Host "Creating API Log fields..." -ForegroundColor Green

# Create fields directory if it doesn't exist, checks automatically
$fieldsPath = "force-app\main\default\objects\API_Log__c\fields"
if (!(Test-Path $fieldsPath)) {
    New-Item -ItemType Directory -Force -Path $fieldsPath
}

# Request Body field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Request_Body__c</fullName>
    <externalId>false</externalId>
    <label>Request Body</label>
    <length>131072</length>
    <trackTrending>false</trackTrending>
    <type>LongTextArea</type>
    <visibleLines>10</visibleLines>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Request_Body__c.field-meta.xml" -Encoding UTF8

# Response Body field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Response_Body__c</fullName>
    <externalId>false</externalId>
    <label>Response Body</label>
    <length>131072</length>
    <trackTrending>false</trackTrending>
    <type>LongTextArea</type>
    <visibleLines>10</visibleLines>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Response_Body__c.field-meta.xml" -Encoding UTF8

# Status Code field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Status_Code__c</fullName>
    <externalId>false</externalId>
    <label>Status Code</label>
    <precision>3</precision>
    <required>false</required>
    <scale>0</scale>
    <trackTrending>false</trackTrending>
    <type>Number</type>
    <unique>false</unique>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Status_Code__c.field-meta.xml" -Encoding UTF8

# Error Message field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Error_Message__c</fullName>
    <externalId>false</externalId>
    <label>Error Message</label>
    <length>131072</length>
    <trackTrending>false</trackTrending>
    <type>LongTextArea</type>
    <visibleLines>5</visibleLines>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Error_Message__c.field-meta.xml" -Encoding UTF8

# Related Case & account lookup fields (can add more object as needed)
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Related_Case__c</fullName>
    <deleteConstraint>SetNull</deleteConstraint>
    <externalId>false</externalId>
    <label>Related Case</label>
    <referenceTo>Case</referenceTo>
    <relationshipLabel>API Logs</relationshipLabel>
    <relationshipName>API_Logs</relationshipName>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Lookup</type>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Related_Case__c.field-meta.xml" -Encoding UTF8

@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Related_Account__c</fullName>
    <deleteConstraint>SetNull</deleteConstraint>
    <externalId>false</externalId>
    <label>Related Account</label>
    <referenceTo>Account</referenceTo>
    <relationshipLabel>API Logs</relationshipLabel>
    <relationshipName>API_Logs_Account</relationshipName>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Lookup</type>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Related_Account__c.field-meta.xml" -Encoding UTF8

# Timestamp field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Timestamp__c</fullName>
    <externalId>false</externalId>
    <label>Timestamp</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>DateTime</type>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Timestamp__c.field-meta.xml" -Encoding UTF8

# Endpoint field
@'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Endpoint__c</fullName>
    <externalId>false</externalId>
    <label>Endpoint</label>
    <length>255</length>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>Text</type>
    <unique>false</unique>
</CustomField>
'@ | Out-File -FilePath "$fieldsPath\Endpoint__c.field-meta.xml" -Encoding UTF8

Write-Host "`nAll API Log fields successfully created" -ForegroundColor Green
Write-Host "`nFiles created:" -ForegroundColor Yellow
Get-ChildItem $fieldsPath

Write-Host "`deploy with:" -ForegroundColor Yellow
Write-Host "sf force start deploy --sourcepath force-app/main/default/objects/API_Log__c" -ForegroundColor Cyan