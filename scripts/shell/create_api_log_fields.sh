#!/bin/bash

# A generic API log object to capture req/response/error for auditing and debugging events

# Uncomment to create fields dir if not already existing
# mkdir -p force-app/main/default/objects/API_Log__c/fields

# Request Body capture field
cat > force-app/main/default/objects/API_Log__c/fields/Request_Body__c.field-meta.xml << 'EOF'
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
EOF

# Resposne Body capture field
cat > force-app/main/default/objects/API_Log__c/fields/Response_Body__c.field-meta.xml << 'EOF'
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
EOF

# API response status code capture field
cat > force-app/main/default/objects/API_Log__c/fields/Status_Code__c.field-meta.xml << 'EOF'
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
EOF

# Generic Erro Message capture field (long text)
cat > force-app/main/default/objects/API_Log__c/fields/Error_Message__c.field-meta.xml << 'EOF'
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
EOF

# Related case & account lookup fields (can add more objects if needed)
cat > force-app/main/default/objects/API_Log__c/fields/Related_Case__c.field-meta.xml << 'EOF'
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
EOF

cat > force-app/main/default/objects/API_Log__c/fields/Related_Account__c.field-meta.xml << 'EOF'
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
EOF
# Timestamp capture field of API log creation
cat > force-app/main/default/objects/API_Log__c/fields/Timestamp__c.field-meta.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Timestamp__c</fullName>
    <externalId>false</externalId>
    <label>Timestamp</label>
    <required>false</required>
    <trackTrending>false</trackTrending>
    <type>DateTime</type>
</CustomField>
EOF

# Capture request endpoint
cat > force-app/main/default/objects/API_Log__c/fields/Endpoint__c.field-meta.xml << 'EOF'
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
EOF

echo "API Log capture fields successfully created."
echo ""
echo "Files created:"
ls -la force-app/main/default/objects/API_Log__c/fields/
echo ""
echo "Now deploy with:"
echo "sfdx force:source:deploy --sourcepath force-app/main/default/objects/API_Log__c"