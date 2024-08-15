# Main orchestration script

# Import required assemblies
Add-Type -AssemblyName System.Web

# Source other scripts
. .\variables.ps1
. .\logging.ps1
. .\resource-group.ps1
. .\storage.ps1
. .\cosmos-db.ps1
. .\openai.ps1
. .\translation.ps1
. .\function-apps.ps1
. .\static-web-app.ps1
. .\api-management.ps1

# Main execution flow
try {
    Write-Log "Starting Azure AI Translator Accelerator deployment script..."


    # # # Set Azure subscription
    Write-Log "Setting Azure subscription to $subscriptionId"
    Set-AzureSubscription -subscriptionId $subscriptionId

    # Create or update resource group    
    Write-Log "Creating or updating resource group $resourceGroupName in location $location"
    $resourceGroup = Create-ResourceGroup -resourceGroupName $resourceGroupName -location $location
    Write-Log "Resource group created: $($resourceGroup | ConvertTo-Json -Depth 3)"

    # Create storage account and container    
    Write-Log "Creating storage account $storageAccountName and container $storageContainerName in resource group $resourceGroupName"
    $storageDetails = Create-StorageResources -resourceGroupName $resourceGroupName -location $location -storageAccountName $storageAccountName -storageContainerName $storageContainerName
    Write-Log "Storage details: $($storageDetails | ConvertTo-Json -Depth 3)"

    # Create Cosmos DB with PostgreSQL API
    Write-Log "Creating Cosmos DB with PostgreSQL API in resource group $resourceGroupName"
    $cosmosDbDetails = Create-CosmosDBPostgresCluster -resourceGroupName $resourceGroupName -location $location -CosmosDBName $CosmosDBName
    Write-Log "Cosmos DB details: $($cosmosDbDetails | ConvertTo-Json -Depth 3)"

    # Create OpenAI service
    Write-Log "Creating OpenAI service $openAIServiceName in resource group $resourceGroupName"
    $openAIService = Create-OpenAIService -resourceGroupName $resourceGroupName -location $location -openAIServiceName $openAIServiceName -openAISku $openAISku -chatCompletionsModelName $chatCompletionsModelName -chatCompletionsDeploymentName $chatCompletionsDeploymentName
    Write-Log "OpenAI service details: $($openAIService | ConvertTo-Json -Depth 3)"
    
    # Create Translation service
    Write-Log "Creating Translation service in resource group $resourceGroupName"
    $translationService = Create-TranslationService -resourceGroupName $resourceGroupName -location $location -translationSku $translationSku -translationServiceName $translationServiceName -customDomain $customDomain
    Write-Log "Translation service details: $($translationService | ConvertTo-Json -Depth 3)"

    # # Deploy Function Apps    
    Write-Log "Deploying Function Apps in resource group $resourceGroupName"
    Deploy-FunctionApps -resourceGroupName $resourceGroupName -location $location -appServicePlanName $appServicePlanName -storageAccountName $storageAccountName -storageDetails $storageDetails -cosmosDbDetails $cosmosDbDetails -openAIService $openAIService -translationService $translationService


    # Create API Management
    Write-Log "Creating API Management in resource group $resourceGroupName $ApiManagementName $location $PublisherEmail $PublisherName $resourceGroupName $functionAppNameUpload"
    $apimDetails = Create-APIManagement -ResourceGroupName $resourceGroupName -ApiManagementName $ApiManagementName -Location $location -PublisherEmail $PublisherEmail -PublisherName $PublisherName -FunctionAppName $functionAppNameUpload

    Write-Output "API Management created successfully."
    Write-Output "API Management Name: $($apimDetails.Name)"
    Write-Output "API Management URL: $($apimDetails.Url)"

    # # Deploy Static Web App
    Write-Log "Deploying Static Web App $staticWebAppName in resource group $resourceGroupName"
    Deploy-StaticWebApp -resourceGroupName $resourceGroupName -staticWebAppName $staticWebAppName -staticSitesRegion $staticSitesRegion -repositoryUrl $repositoryUrl -branchName $branchName -webAppFolder $webAppFolder -accessToken $accessToken 

    # Final summary
    Write-Summary -resourceGroup $resourceGroup -storageDetails $storageDetails -cosmosDbDetails $cosmosDbDetails -openAIService $openAIService -translationService $translationService

    Write-Log "Azure AI Translator Accelerator deployment completed successfully."
}
catch {
    Handle-Error $_.Exception.Message
}
