# Using the Az module
# https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.4.0

# Get signed in
Connect-AzAccount

# see available subscriptions
Get-AzSubscription

# check we've got the right one slected
Get-AzContext

# choose a subscription
Set-AzContext -SubscriptionName "MVP"

# see all commands
Get-Command *Az* -Module Az.Resources

# To enable compatibility mode
# Enable-AzureRmAlias

# see all resource groups
Get-AzResourceGroup | select ResourceGroupName

# create a resource group
$ResourceGroup = "HighDensityTest"
$Location = "westeurope"
New-AzResourceGroup -Name $ResourceGroup -Location $Location

# Create a new high density app service plan
# https://docs.microsoft.com/en-us/azure/app-service/manage-scale-per-app
$AppServicePlan = "HighDensityTest"
New-AzAppServicePlan -ResourceGroupName $ResourceGroup -Name $AppServicePlan `
                            -Location $Location `
                            -Tier Standard -WorkerSize Small `
                            -NumberofWorkers 3 -PerSiteScaling $true

# Enable per-app scaling for the App Service Plan using the "PerSiteScaling" parameter.
# Set-AzAppServicePlan -ResourceGroupName $ResourceGroup -Name $AppServicePlan -PerSiteScaling $true

$WebApp1 = "mheath-hd-1"
New-AzWebApp -ResourceGroupName $ResourceGroup -AppServicePlan $AppServicePlan `
    -Name $WebApp1

$ArchivePath = "webapp1.zip"
Publish-AzWebApp -ArchivePath $ArchivePath -ResourceGroupName $ResourceGroup -Name $WebApp1

# Get the app we want to configure to use "PerSiteScaling"
$newapp = Get-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebApp1

# Modify the NumberOfWorkers setting to the desired value.
$newapp.SiteConfig.NumberOfWorkers = 2

# Post updated app back to azure
Set-AzWebApp $newapp

Remove-AzResourceGroup -Name $ResourceGroup -Force -AsJob