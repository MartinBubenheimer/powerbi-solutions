# Page View Metrics
Solution to create page level usage statistics in Power BI.
## Preconditions
Requires Premium workspaces, either by capacity or by user (PPU license).
## Setup
Per workspace, create a build-in Usage Metrics Report for any of the reports in the workspace.
When creating a new workspace, you first need to add a report, e.g. add a template report promoting the CD of your organisation, then create a Usage Metrics Report and then you can hand over the workspace to its users.
## Script
The PageViewsXmlaQuery.ps1 PowerShell script reads the page views from the Usage Metrics Report datasets in each workspace and stores one file per workspace and day.
Check the comments to adjust the script to meet your needs, e.g.
- Authenticate using a service principal
- Write files to a data lake or a different location
- Query only a limited date range of usage data
To run the script as-is, you need to have a folder C:\Temp on your machine and you need to have write-access to it. In this case the script copies all page views data that is currently avaiable and accessible to the authenticated identity into CSV files on your local drive.
Be aware that usage metrics data is only available in the dataset with a delay of up to a few days.
