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

function New-HighDensityWebApp {
    param( [string]$ResourceGroupName, 
           [string]$AppServicePlanName, 
           [string]$WebAppName,
           [int]$NumberOfWorkers,
           [string]$ArchivePath)

    New-AzWebApp -ResourceGroupName $ResourceGroup -AppServicePlan $AppServicePlan `
        -Name $WebAppName
    
    Publish-AzWebApp -ArchivePath $ArchivePath -ResourceGroupName $ResourceGroup -Name $WebAppName -Force
    
    # Get the app we want to configure to use "PerSiteScaling"
    $newapp = Get-AzWebApp -ResourceGroupName $ResourceGroup -Name $WebAppName

    # Modify the NumberOfWorkers setting to the desired value.
    $newapp.SiteConfig.NumberOfWorkers = $NumberOfWorkers
    $newapp.SiteConfig.AppSettings.Add( [Microsoft.Azure.Management.WebSites.Models.NameValuePair]::new("AppName",$WebAppName))
    $newapp.SiteConfig.AppSettings.Add( [Microsoft.Azure.Management.WebSites.Models.NameValuePair]::new("NumberOfWorkers",$NumberOfWorkers))

    # Post updated app back to azure
    Set-AzWebApp $newapp
}

$ArchivePath = "publish.zip"
New-HighDensityWebApp -ResourceGroupName $ResourceGroup -AppServicePlanName $AppServicePlan `
                      -WebAppName "mheath-hd-1" -NumberOfWorkers 1 -ArchivePath $ArchivePath
New-HighDensityWebApp -ResourceGroupName $ResourceGroup -AppServicePlanName $AppServicePlan `
                    -WebAppName "mheath-hd-2" -NumberOfWorkers 2 -ArchivePath $ArchivePath
New-HighDensityWebApp -ResourceGroupName $ResourceGroup -AppServicePlanName $AppServicePlan `
                    -WebAppName "mheath-hd-3" -NumberOfWorkers 3 -ArchivePath $ArchivePath
# can we set number of workers higher? - yes, although it seems that we could end up with the four spread across just two of the nodes
New-HighDensityWebApp -ResourceGroupName $ResourceGroup -AppServicePlanName $AppServicePlan `
                    -WebAppName "mheath-hd-4" -NumberOfWorkers 4 -ArchivePath $ArchivePath

(iwr "https://mheath-hd-1.azurewebsites.net/").content
(iwr "https://mheath-hd-3.azurewebsites.net/").content

(iwr "https://mheath-hd-4.azurewebsites.net/").content

Remove-AzResourceGroup -Name $ResourceGroup -Force -AsJob