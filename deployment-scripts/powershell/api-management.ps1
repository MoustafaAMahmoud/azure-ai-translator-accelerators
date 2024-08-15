# api-management.ps1
# This script sets up an Azure API Management instance, creates an API, and configures operations with policies.

# Running Example:

# .\api-management.ps1 `
#     -ResourceGroupName "ai-translator-accelerator-rg-12345" `
#     -ApiManagementName "translator-apim-930826" `
#     -Location "uksouth" `
#     -PublisherEmail "your-email@example.com" `
#     -PublisherName "Your Company Name" `
#     -FunctionAppName "translation-service-upload-function"
function Create-APIManagement {
# Parameters for the script
param(
    [Parameter(Mandatory = $true)]
    [String]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [String]
    $ApiManagementName,
    [Parameter(Mandatory = $true)]
    [String]
    $Location,
    [Parameter(Mandatory = $true)]
    [String]
    $PublisherEmail,
    [Parameter(Mandatory = $true)]
    [String]
    $PublisherName,
    [Parameter(Mandatory = $true)]
    [String]
    $FunctionAppName
)
# ------------------------------------------------------
# 1. Variable Initialization
# ------------------------------------------------------
$RESOURCE_GROUP_NAME = $ResourceGroupName
$APIM_NAME = $ApiManagementName
$APIM_LOCATION = $Location
$APIM_PUBLISHER_EMAIL = $PublisherEmail
$APIM_PUBLISHER_NAME = $PublisherName
$FUNCTION_APP_NAME = $FunctionAppName
$API_NAME = "translation-service-api"
$APIM_SKU = "Developer"  # Can be changed to other SKUs as needed

# Print variables for verification
Write-Output "Variables: `n"
Write-Output "Resource Group: $RESOURCE_GROUP_NAME `n"
Write-Output "APIM Name: $APIM_NAME `n"
Write-Output "Location: $APIM_LOCATION `n"
Write-Output "Publisher Email: $APIM_PUBLISHER_EMAIL `n"
Write-Output "Publisher Name: $APIM_PUBLISHER_NAME `n"
Write-Output "Function App Name: $FUNCTION_APP_NAME `n"
Write-Output "API Name: $API_NAME"
Write-Output "APIM SKU: $APIM_SKU"

# ------------------------------------------------------
# 2. API Management Instance Provisioning
# ------------------------------------------------------
Write-Output "Checking if API Management instance exists... `n"
$existing_apim = az apim show --name $APIM_NAME --resource-group $RESOURCE_GROUP_NAME --query "name" --output tsv 2>$null
if ($existing_apim -eq $APIM_NAME) {
    Write-Output "API Management instance '$APIM_NAME' already exists. Moving to the next step. `n"
} else {
    Write-Output "Creating API Management instance... `n"
    az apim create `
        --resource-group $RESOURCE_GROUP_NAME `
        --name $APIM_NAME `
        --location $APIM_LOCATION `
        --sku-name $APIM_SKU `
        --publisher-email $APIM_PUBLISHER_EMAIL `
        --publisher-name $APIM_PUBLISHER_NAME
}
#stv2
# ------------------------------------------------------
# 3. Function App Base URI Retrieval
# ------------------------------------------------------
Write-Output "Getting Function App Base URI... `n"
$DEFAULT_HOST_NAME = az functionapp show `
    --resource-group $RESOURCE_GROUP_NAME `
    --name $FUNCTION_APP_NAME `
    --query "defaultHostName" `
    --output tsv

$FUNCTION_APP_BASE_URI = "https://${DEFAULT_HOST_NAME}/api"

Write-Output "Function App Base URI: $FUNCTION_APP_BASE_URI `n"


# ------------------------------------------------------
# 4. API Creation in API Management
# ------------------------------------------------------
Write-Output "Checking if API already exists in API Management... `n"
$existing_api = az apim api show --api-id $API_NAME --resource-group $RESOURCE_GROUP_NAME --service-name $APIM_NAME --query "name" --output tsv 2>$null
if ($existing_api -eq $API_NAME) {
    Write-Output "API '$API_NAME' already exists in API Management. Moving to the next step. `n"
} else {
    Write-Output "Creating API in API Management... `n"
    az apim api create `
        --resource-group $RESOURCE_GROUP_NAME `
        --service-name $APIM_NAME `
        --api-id $API_NAME `
        --display-name "Translation Service API" `
        --path "translation-service" `
        --service-url $FUNCTION_APP_BASE_URI `
        --protocols "https" `
        --description "This is the Translation Service API"
}


# ------------------------------------------------------
# 5. API Operations Creation
# ------------------------------------------------------
$operations = @(
    @{id="get_all_logs"; method="GET"; urlTemplate="/get_all_logs"; displayName="Get All Logs"},
    @{id="get_all_prompts"; method="GET"; urlTemplate="/get_all_prompts"; displayName="Get All Prompts"},
    @{id="get_logs_by_date"; method="GET"; urlTemplate="/get_logs_by_date"; displayName="Get Logs By Date"},
    @{id="upload_file"; method="POST"; urlTemplate="/upload_file"; displayName="Upload File"}
)

foreach ($op in $operations) {
  Write-Output "Checking if operation '$($op.id)' exists... `n"
  $existing_operation = az apim api operation show --operation-id $op.id --api-id $API_NAME --resource-group $RESOURCE_GROUP_NAME --service-name $APIM_NAME --query "name" --output tsv 2>$null
  if ($existing_operation -eq $op.id) {
      Write-Output "Operation '$($op.id)' already exists. Skipping creation. `n"
  } else {
      Write-Output "Creating operation: $($op.displayName) `n"
      az apim api operation create `
          --resource-group $RESOURCE_GROUP_NAME `
          --service-name $APIM_NAME `
          --api-id $API_NAME `
          --operation-id $op.id `
          --display-name $op.displayName `
          --method $op.method `
          --url-template $op.urlTemplate
  }
}

# ------------------------------------------------------
# 6. Function App Key Retrieval
# ------------------------------------------------------
Write-Output "Getting Function App key... `n"
$FUNCTION_KEY = az functionapp keys list `
    --resource-group $RESOURCE_GROUP_NAME `
    --name $FUNCTION_APP_NAME `
    --query "functionKeys.default" `
    --output tsv
Write-Output "Function Key: $FUNCTION_KEY `n"

# ------------------------------------------------------
# 7. API Policy Creation and Deployment
# ------------------------------------------------------
$ApiManagementPolicyPath = ".\api-policy.xml"
$policyXml = @"
<policies>
  <inbound>
    <base />
      <cors allow-credentials='false'>
        <allowed-origins>
          <origin>*</origin>
        </allowed-origins>
        <allowed-methods>
          <method>GET</method>
          <method>POST</method>
        </allowed-methods>
      </cors>
  </inbound>
  <backend>
    <base/>
  </backend>
  <outbound>
    <base/>
  </outbound>
  <on-error>
    <base/>
  </on-error>
</policies>
"@

# Write the initial policy XML to the file
$policyXml | Out-File -FilePath $ApiManagementPolicyPath -Encoding UTF8

# Get the full path of the policy file
$FullApiManagementPolicyPath = (Get-Item $ApiManagementPolicyPath).FullName

# Load the policy XML from the file
$policy = [xml](Get-Content $FullApiManagementPolicyPath)

# Create and add the set-query-parameter element to the inbound section
# Create a new element for the set-query-parameter
$setQueryParameterElement = $policy.CreateElement("set-query-parameter")
$setQueryParameterElement.SetAttribute("name", "code")
$setQueryParameterElement.SetAttribute("exists-action", "override")

# Create a value element and add it to the set-query-parameter element
$valueElement = $policy.CreateElement("value")
$valueElement.InnerText = $FUNCTION_KEY
$setQueryParameterElement.AppendChild($valueElement) > $null

# Append the set-query-parameter element to the inbound section
$policy.policies.inbound.AppendChild($setQueryParameterElement) > $null

# Print the modified XML policy to the console
Write-Output "Modified Policy XML: `n"
$policy.OuterXml

# Save the modified XML back to the file using the full path
$policy.Save($FullApiManagementPolicyPath)

# ------------------------------------------------------
[string]$PolicyAsString = Get-Content $ApiManagementPolicyPath

# ------------------------------------------------------
# 8. Policy Deployment for Each Operation
# ------------------------------------------------------
foreach ($op in $operations) {
    Write-Output "Updating : $($op.id)"
    $APIM_OPERATION_ID = $op.id
    Write-Output "Preparing Resources for: $($op.displayName)"
    [PSCustomObject]$POLICY_RESOURCE = @{
        type = "Microsoft.ApiManagement/service/apis/operations/policies"
        apiVersion = "2022-08-01"
        name = "${APIM_NAME}/${API_NAME}/${APIM_OPERATION_ID}/policy"
        properties = @{
            format = "xml"
            value = $PolicyAsString
        }
    }

    $TEMPLATE = @{
       '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0"
        resources = @($POLICY_RESOURCE)
    }
    Write-Output "Finished Preparing the resources for the operation: $($op.displayName)"

    New-Item -Path ".\azure" -ItemType Directory -Force
    Write-Output "Saving policy deployment template for operation: $($op.displayName) `n"
    $TEMPLATE | ConvertTo-Json -Depth 10 | Out-File ".\azure\apimPolicyDeploy_${APIM_OPERATION_ID}.json"
    Write-Output "Policy deployment template saved for operation: $($op.displayName) `n"

    Write-Output "Deploying policy for operation: $($op.displayName)"
    az deployment group create `
        --name "apim-op-${APIM_OPERATION_ID}-policy-deploy" `
        --resource-group $RESOURCE_GROUP_NAME `
        --template-file ".\azure\apimPolicyDeploy_${APIM_OPERATION_ID}.json"
    Write-Output "Policy deployed for operation: $($op.displayName) `n"
}

# ------------------------------------------------------
# 9. Completion Message
# ------------------------------------------------------
Write-Output "API Management setup complete.`n"
Write-Output "API Management Name: $APIM_NAME `n"
Write-Output "API Management URL: https://$APIM_NAME.azure-api.net `n"

Write-Output "API Management setup complete. `n"
return @{
    Name = $APIM_NAME
    Url = "https://$APIM_NAME.azure-api.net"
}
}