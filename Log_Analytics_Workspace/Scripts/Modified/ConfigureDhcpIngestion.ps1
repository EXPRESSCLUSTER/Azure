<#
.SYNOPSIS
    This sample script is designed to Create a custom table and the corresponding DCE and DCR to allow for custom log ingestion through the Azure Monitor Agent (AMA).

.DESCRIPTION
    This script will ease the custom log ingestion  by creating the following components:
    - Custom table
    - Data Collection Endpoint (DCE)
    - Data Collection Endpoint (DCE)

    Before running the script the following files, which MUST be located in the same folder as this script, must be customized:
    - TableSchema.json: This file will contain the final schema for the custom table.
    - PROD-DCE-DCR-Template: This file contains the template for the DCE and DCR used for ingestion.

.REQUIREMENTS
    The following PowerShell modules are required:
    - AZ.ACCOUNTS
    - AZ.RESOURCES

.NOTES
    AUTHOR:   Bruno Gabrielli
    LASTEDIT: June 12th, 2023
   
    - VERSION: 1.0 // June 12th, 2023
        - First version

#>

# Forcing use of TLS protocol
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Clear all existing context
Clear-AzContext -force

# Requesting the Azure AD Tenant Id to authenticate against
$azTenantId = Read-Host -Prompt "Enter the Azure Active Directory tenant Id"

# Logging-in
Connect-AzAccount -WarningAction Ignore -TenantId $azTenantId | Out-Null
$Subscription = Get-AzSubscription -WarningAction Ignore | Where-Object {$_.State -eq "Enabled"} | Out-GridView -OutputMode Single -Title "Select your subscription"

if (![string]::IsNullOrWhiteSpace($($Subscription.Id)))
{
    # Selecting the subscription on which operate
    Set-AzContext -WarningAction Ignore -Subscription $Subscription | Out-Null

    # Setting variables through customer inputs
    [string]$subscriptionId = $Subscription.Id
    [string]$resourceGroup = Read-Host "Enter the resource group containing the Log Analytics workspace that will contain the custom table"
    [string]$workspace = Read-Host "Enter the Log Analytics workspace name that will contain the custom table"
    [string]$tableName = Read-Host "Enter the custom table name"
    [string]$azMonDceName = Read-Host "Enter the name of the Data Collection Endpoint (DCE)"
    [string]$azMonDcrName = Read-Host "Enter the name of the Data Collection Rule (DCR)"
    [string]$templateFile = Read-Host "Enter the template file name used to deploy DCR and DCE"

    If ([string]::IsNullOrWhiteSpace($resourceGroup))
    {
        do {
            [string]$resourceGroup = Read-Host "No value has been entered. Enter the resource group containing the Log Analytics workspace that will contain the custom table"
        } while ([string]::IsNullOrWhiteSpace($resourceGroup))
    }

    If ([string]::IsNullOrWhiteSpace($workspace))
    {
        do {
            [string]$workspace = Read-Host "No value has been entered. Enter the Log Analytics workspace name that will contain the custom table"
        } while ([string]::IsNullOrWhiteSpace($workspace))
    }

    If ([string]::IsNullOrWhiteSpace($tableName))
    {
        do {
            [string]$tableName = Read-Host "No value has been entered. Enter the custom table name"
        } while ([string]::IsNullOrWhiteSpace($tableName))
    }
    else
    {
        if(!$tableName.EndsWith('_CL', 3))
        {
            $tableName = $tableName+"_CL"
        }
    }

    If ([string]::IsNullOrWhiteSpace($azMonDceName))
    {
        do {
            [string]$azMonDceName = Read-Host "No value has been previously entered. Enter the name of the Data Collection Endpoint (DCE)"
        } while ([string]::IsNullOrWhiteSpace($azMonDceName))
    }

    If ([string]::IsNullOrWhiteSpace($azMonDcrName))
    {
        do {
            [string]$azMonDcrName = Read-Host "No value has been previously entered. Enter the name of the Data Collection Rule (DCR)"
        } while ([string]::IsNullOrWhiteSpace($azMonDcrName))
    }

    If ([string]::IsNullOrWhiteSpace($templateFile))
    {
        do {
            [string]$templateFile = Read-Host "No value has been entered. Enter the template file name used to deploy DCR and DCE"
        } while ([string]::IsNullOrWhiteSpace($templateFile))
    }

    # Creating parameter object
    $paramObj = @{
        logAnalyticsWorkspaceName = $workspace
        AzTableName = $tableName
        azMonDCE = $azMonDceName
        azMonDCR = $azMonDcrName
    }

    # Creating table schema ## CUSTOMIZE THE SCHEMA in the JSON file
    [string]$tableDefinition = get-content ".\TableSchema.json"
    $tableDefinition= $tableDefinition.Replace('_tableName_',$tableName)

    $urlPath = "/subscriptions/$subscriptionId/resourcegroups/$resourceGroup/providers/microsoft.operationalinsights/workspaces/$workspace/tables/"+$tableName+"?api-version=2021-12-01-preview"

    Write-Host "`n`tCreating Log Analytics table ==$tableName== ..." -ForegroundColor Cyan
    $response = (Invoke-AzRestMethod -Path $urlPath -Method PUT -payload $tableDefinition)

    if($response.StatusCode -lt 300)
    {
        Write-Host "`t`tLog Analytics table ==$tableName== created succesfully" -ForegroundColor Green
        
        # Creating DCE and DCR
        Write-Host "`n`tCreating Azure Monitor DCE and DCR for data ingestion ..." -ForegroundColor Cyan
        $CustomLogDeployment = (New-AzResourceGroupDeployment -Name "CustomLog-Deployment" -ResourceGroupName $resourceGroup -TemplateFile $templateFile -TemplateParameterObject $paramObj -ErrorAction Stop)
        if($CustomLogDeployment.ProvisioningState -eq "Succeeded")
        {
            Write-Host "`t`tAzure Monitor DCE and DCR created succesfully" -ForegroundColor Green

        }
    }
    else 
    {
        Write-Host "`t`tAn error during the Log Analytics table creation for table ==$tableName== occurred. `n`t`tThe status code of the request is ==$($response.StatusCode)==. `n`t`tDetailed error description is: ==$($response.Content)==" -ForegroundColor Red
    }
}
else {
    Write-Host "`nNo subscription has been selected. Re-run the script an select 1 subscription from the list." -ForegroundColor Yellow
}