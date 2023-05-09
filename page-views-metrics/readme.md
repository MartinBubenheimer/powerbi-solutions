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
- Write files to a data lake
- Query only a limited date range of usage data
