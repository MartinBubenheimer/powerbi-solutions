<#
    .DESCRIPTION
        Refersh Power Bi tables using the Managed Identity

    .NOTES
        AUTHOR: Martin Bubenheimer
        LASTEDIT: 2022-04-20
#>

# Setup:
# Remark: Managed Identity can only access Key Vault and other Azure resources, but not Power BI API since this is not a Azure Resource
# - install module "SqlServer" from gallery
# - assign "Contributor" role to managed identity (has the same name as the Automation Account) in Access Control (IAM) section
# - in Key Vault, assign "Key Vault Secrets User" role to the managed identiy of the Azure Automation Account
# - Create App registration with service principal that has privileges Power BI Read and Power BI ReadWrite
# - Create secret for service principal
# - Create key vault in the same resource group as the Automation Account
# - Add secret of service principal to Key Vault
# - in Key Vault add Contributor role to Managed Identity of Automation Account
# - in Key Vault add Access Policy granting get secret privilege to Managed Identity of Automation Account
# - if Power BI access for Service Principals is limited to Security Groups, add service privilege to appropriate security group

# Configuration:
$Table1 = 'DimCustomer' # First Table to be refreshed
$Table2 = 'DimProduct' # Second Table to be refreshed

$TenantID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' # Power BI tenant, from Azure Active Directory page: https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview
$Workspace = 'powerbi://api.powerbi.com/v1.0/myorg/AutomationTest' # Power BI Workspace URL
$Database = 'Import-Datamodel' # Power BI dataset
$VaultName = 'kv-pbi-resource-local' # Key vault containing a service principal's secret, not needed with managed identity
$SecretName = 'PbiServicePrincipal' # Secret handle in key vault
$AppID = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' # App ID information can be looked up at the service principal user in the Power BI workspace access configuration

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

# Get secret from key vault for service principal
$SecretFromKeyVault = Get-AzKeyVaultSecret `
		-VaultName $VaultName `
		-Name $SecretName
$CredObj = New-Object System.Management.Automation.PSCredential($AppID,$SecretFromKeyVault.SecretValue)

# Refresh Power BI tables:
Invoke-ProcessTable -TableName $Table1 -RefreshType Full -Server $Workspace -DatabaseName $Database -Credential $CredObj -ServicePrincipal -TenantId $TenantID
Invoke-ProcessTable -TableName $Table2 -RefreshType Full -Server $Workspace -DatabaseName $Database -Credential $CredObj -ServicePrincipal -TenantId $TenantID
