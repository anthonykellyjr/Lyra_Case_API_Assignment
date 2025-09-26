# Powershell script using cURL to test authentication and case creation
$clientId = "3MVG9dAEux2v1sLuy170GPtyOCbTfBgnAXW3LCAJVAgj.jzsG8Oi7dARHjQw8c.UAeQ4RwIz7kXCBf23e64Sz"
$clientSecret = "F8DCF6DE97647A5476D084FFBCB63D3C8B636EA08707B99B8CBB00F75F888465"
$loginUrl = "https://orgfarm-a51b70979a-dev-ed.develop.my.salesforce.com/services/oauth2/token"

Write-Host "Testing Case API with Connected App..." -ForegroundColor Yellow

$tokenBody = @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
}

$tokenResponse = Invoke-RestMethod -Uri $loginUrl -Method POST -Body $tokenBody -ContentType "application/x-www-form-urlencoded"

if ($tokenResponse.access_token) {
    Write-Host "OAuth succeeded, creating case..." -ForegroundColor Green
    
    $caseData = @{
        subject = "API Integration Test"
        description = "Testing case creation via Connected App"
        status = "New"
        origin = "web"
        name = "Case Integration Test"
        phone = "555-0001"
        email = "tester@lyra.dev"
    } | ConvertTo-Json

    $headers = @{
        "Authorization" = "Bearer $($tokenResponse.access_token)"
        "Content-Type" = "application/json"
    }

    $case = Invoke-RestMethod -Uri "$($tokenResponse.instance_url)/services/apexrest/create-case/" -Method POST -Headers $headers -Body $caseData
    
    Write-Host "`nCase created successfully!" -ForegroundColor Green
    Write-Host "Case Number: $($case.caseNumber)"
    Write-Host "Case ID: $($case.caseId)"
} else {
    Write-Host "Auth failed:" -ForegroundColor Red
    $tokenResponse
}