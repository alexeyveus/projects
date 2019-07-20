##########################################################
#  Script to import an API and add it to a Product in api Management 
#  Adding the Imported api to a product is necessary, so that it can be called by a subscription
########################################################### 

#Write-Host "Logging in...";
#Connect-AzureRmAccount

#Azure specific details
$subscriptionId = "****************************"

# Api Management service specific details
$apimServiceName = "dev-api-management-service"
$resourceGroupName = "rg-APIM-dev"
$location = "West Europe"

# Api Specific Details
$swaggerUrl = "https://raw.githubusercontent.com/*****/devops/master/openAPI/scrips_api-Swagger20.json?token=************************"
$apiPath = "newapi/v1"
#$apiID = "new Scrips API"

# Set the context to the subscription Id where the cluster will be created
Select-AzureRmSubscription -SubscriptionId $subscriptionId

# Create the API Management context
$context = New-AzureRmApiManagementContext -ResourceGroupName $resourceGroupName -ServiceName $apimServiceName

Get-AzureRmApiManagementApi -Context $context

# import api from Url
$api = Import-AzureRmApiManagementApi -Context $context -SpecificationUrl $swaggerUrl -SpecificationFormat Swagger -Path $apiPath #-ApiId $apiID

$productName = "New Scrips API Product"
$productDescription = "Product giving access to new API"
$productState = "Published"

# Create a Product to publish the Imported Api. This creates a product with a limit of 10 Subscriptions
$product = New-AzureRmApiManagementProduct -Context $context -Title $productName -Description $productDescription -State $productState -SubscriptionsLimit 10 

# Add the api to the published Product, so that it can be called in developer portal console
Add-AzureRmApiManagementApiToProduct -Context $context -ProductId $product.ProductId -ApiId $api.ApiId
