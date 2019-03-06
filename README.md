### Per-App Scaling with Azure App Service
This demo shows how to create a new Azure App Service Plan with per-app scaling enabled, and publish multiple web apps to it, each with a customizable number of workers.

To build the sample web app, run `dotnet publish` and zip up the published output folder.

The example PowerShell script containing the deployment commands is `HighDensity.ps1`, and uses the Azure PowerShell Az module.

Full details of how this works can be found at [markheath.net/post/per-app-scaling-app-service](https://markheath.net/post/per-app-scaling-app-service)