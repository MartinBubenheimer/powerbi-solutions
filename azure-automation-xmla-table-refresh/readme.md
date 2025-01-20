## DESCRIPTION

Refersh Power Bi tables using the Managed Identity

## NOTES

AUTHOR: Martin Bubenheimer

LASTEDIT: 2022-04-20

## Setup

Remark: Managed Identity can only access Key Vault and other Azure resources, but not Power BI API since this is not a Azure Resource
- install module "SqlServer" from gallery
- assign "Contributor" role to managed identity (has the same name as the Automation Account) in Access Control (IAM) section
- in Key Vault, assign "Key Vault Secrets User" role to the managed identiy of the Azure Automation Account
- Create App registration with service principal that has privileges Power BI Read and Power BI ReadWrite
- Create secret for service principal
- Create key vault in the same resource group as the Automation Account
- Add secret of service principal to Key Vault
- in Key Vault add Contributor role to Managed Identity of Automation Account
- in Key Vault add Access Policy granting get secret privilege to Managed Identity of Automation Account
- if Power BI access for Service Principals is limited to Security Groups, add service privilege to appropriate security group
