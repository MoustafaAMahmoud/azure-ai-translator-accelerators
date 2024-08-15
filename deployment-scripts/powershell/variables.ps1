# Variables

# Function to generate a random 5-character string
function Get-RandomString {
    -join ((97..122) | Get-Random -Count 5 | ForEach-Object { [char]$_ })
}

$randomString = Get-RandomString

$subscriptionId = ""
$resourceGroupName = "ai-translator-accelerator-rg-$randomString"
$location = "uksouth"
$storageAccountName = "azaitranslator$randomString" # Must be between 3 and 24 characters, only lower-case letters and numbers
$appServicePlanName = "azure-ai-translator-plan-$randomString"
$functionAppNameUpload = "ai-translator-upload-func-$randomString"
$functionAppNameTranslate = "ai-translator-translate-func-$randomString"
$functionAppNameWatermark = "ai-translator-watermark-func-$randomString"
$storageContainerName = "documents"
$translationSku = "S1"
$CosmosDBName = "translateservice$uniqueString"
# Translation Service variables
$translationServiceName = "ai-trans-service-$randomString"
$customDomain = "ai-translator-$randomString"

# OpenAI specific variables
$openAIServiceName = "az-openai-service-$randomString" #$randomString
$openAISku = "S0"
$chatCompletionsModelName = "gpt-35-turbo" # Adjust as needed
$chatCompletionsDeploymentName = "az-chat-$randomString"

# Static Web App variables
$repositoryUrl = "https://github.com/GITHUB_USER/azure-ai-translator-accelerators"
$branchName = "main"
$webAppFolder = "document-translate-web"
$accessToken = "" # Replace this with your GitHub access token
$staticWebAppName = "ai-translator-static-webapp-$randomString"
$staticSitesRegion = "westeurope" # Adjust as needed

# APIM variables
$ApiManagementName = "translator-apim-$randomString"
$PublisherEmail = "your-email@example.com"
$PublisherName = "Your Company Name"