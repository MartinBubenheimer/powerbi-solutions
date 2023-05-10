# Install-Module -Name MicrosoftPowerBIMgmt
# Install-Module -Name SqlServer
$ErrorActionPreference = "Stop"
$RetrieveDate = Get-Date
$datestring = $RetrieveDate.ToString('yyyyMMdd')
$PageViewsFilePathTemplate = 'C:\Temp\PowerBiPageViews_'
$PagesFilePathTemplate = 'C:\Temp\PowerBiPages_'

# Power BI REST API login
# The login identity determins the tenant that is being queried.
$environment = Login-PowerBI # Add: Read credential of Service Principal from Key Vault

# Get all workspaces from Power BI
$workspaces = Get-PowerBIWorkspace

Logout-PowerBI

# XMLA Login
$cred = Get-Credential # Add: Read credential of Service Principal from Key Vault

# Loop over all workspaces
foreach($workspacename in $workspaces.Name)
{
    # Per each workspace: Read Report page views from Usage Metrics Report dataset and write to CSV file
    try {
        # Load a specific day by an offset from the loading date, change query to:
        # EVALUATE CALCULATETABLE('Report page views','Report page views'[Date]=TODAY()-1)
        [xml]$data = Invoke-ASCmd -Credential $cred -Query "EVALUATE 'Report page views'" -Server "powerbi://api.powerbi.com/v1.0/myorg/$workspacename" -Database "Usage Metrics Report"
        [int]$rowcount = $data.return.root.row.Count
        if ( $rowcount -gt 0 ) 
        {
            foreach($row in $data.return.root.row)
            {
                [array]$pageviews += New-Object psobject -Property @{
                    UserId               = $row.'Report_x0020_page_x0020_views_x005B_UserId_x005D_'
                    ReportId             = $row.'Report_x0020_page_x0020_views_x005B_ReportId_x005D_'
                    Date                 = $row.'Report_x0020_page_x0020_views_x005B_Date_x005D_'
                    Timestamp            = $row.'Report_x0020_page_x0020_views_x005B_Timestamp_x005D_'
                    Client               = $row.'Report_x0020_page_x0020_views_x005B_Client_x005D_'
                    DeviceBrowserVersion = $row.'Report_x0020_page_x0020_views_x005B_DeviceBrowserVersion_x005D_'
                    DeviceOSVersion      = $row.'Report_x0020_page_x0020_views_x005B_DeviceOSVersion_x005D_'
                    WorkspaceId          = $row.'Report_x0020_page_x0020_views_x005B_WorkspaceId_x005D_'
                    SectionId            = $row.'Report_x0020_page_x0020_views_x005B_SectionId_x005D_'
                    TenantId             = $row.'Report_x0020_page_x0020_views_x005B_TenantId_x005D_'
                    UserKey              = $row.'Report_x0020_page_x0020_views_x005B_UserKey_x005D_'
                }
            }
            $PageViewsSchema = $pageviews | `
            Select-Object `
            UserId,ReportId,Date,Timestamp,Client,DeviceBrowserVersion,DeviceOSVersion,WorkspaceId,SectionId,TenantId,UserKey, `
            @{Name="RetrieveDate";Expression={$RetrieveDate}}
            
            $WorkspaceFileName = $workspacename -replace '\W','_'
            $PageViewsFilePath = $PageViewsFilePathTemplate + $WorkspaceFileName + '_' + $datestring + '.csv'
            $PageViewsSchema | Export-Csv -NoTypeInformation -Path $PageViewsFilePath # Replace destination with an authenticated datalake location, might require additional module installations: https://www.powershellgallery.com/
            "Created file $PageViewsFilePath"
        }
        else
        {
            # Skip workspace if usage metrics report dataset is empty, e.g. because Usage Report Metrics are just newly created or workspace has not been used for too many days
            Write-Warning "Usage Metrics Report dataset is empty for workspace $workspacename. User might not be allowed to access dataset, or Usage Metrics Report has not been created, or workspace is stale for too many days." # -ForegroundColor Yellow
        }
    }
    catch [System.IO.IOException]
    {
        Write-Host "ERROR: Cannot write file $PageViewsFilePath. Check if file is open in an application that keeps a write lock and close file." -ForegroundColor Red
        continue
    }
    catch
    {
        # Skip workspace if usage metrics report are not set up or access is denied to authenticated identity
        Write-Warning "Cannot read Usage Metrics Report dataset from workspace $workspacename. User might not be allowed to access workspace, or workspace is not Premium, or Usage Metrics Report has not been created." # -ForegroundColor Yellow
        continue
    }

    # Per each workspace: Read Report pages from Usage Metrics Report dataset and write to CSV file
    try {
        # Load a specific day by an offset from the loading date, change query to:
        # EVALUATE CALCULATETABLE('Report page views','Report page views'[Date]=TODAY()-1)
        [xml]$data = Invoke-ASCmd -Credential $cred -Query "EVALUATE 'Report pages'" -Server "powerbi://api.powerbi.com/v1.0/myorg/$workspacename" -Database "Usage Metrics Report"
        [int]$rowcount = $data.return.root.row.Count
        if ( $rowcount -gt 0 ) 
        {
            foreach($row in $data.return.root.row)
            {
                [array]$pages += New-Object psobject -Property @{
                    ReportId             = $row.'Report_x0020_pages_x005B_ReportId_x005D_'
                    SectionId            = $row.'Report_x0020_pages_x005B_SectionId_x005D_'
                    SectionName          = $row.'Report_x0020_pages_x005B_SectionName_x005D_'
                }
            }
            $PagesSchema = $pages | `
            Select-Object `
            ReportId,SectionId,SectionName, `
            @{Name="RetrieveDate";Expression={$RetrieveDate}}
            
            $WorkspaceFileName = $workspacename -replace '\W','_'
            $PagesFilePath = $PagesFilePathTemplate + $WorkspaceFileName + '_' + $datestring + '.csv'
            $PagesSchema | Export-Csv -NoTypeInformation -Path $PagesFilePath # Replace destination with an authenticated datalake location, might require additional module installations: https://www.powershellgallery.com/
            "Created file $PagesFilePath"
        }
        else
        {
            # Skip workspace if usage metrics report dataset is empty, e.g. because Usage Report Metrics are just newly created or workspace has not been used for too many days
            Write-Warning "Usage Metrics Report dataset is empty for workspace $workspacename. User might not be allowed to access dataset, or Usage Metrics Report has not been created, or workspace is stale for too many days." # -ForegroundColor Yellow
        }
    }
    catch [System.IO.IOException]
    {
        Write-Host "ERROR: Cannot write file $PagesFilePath. Check if file is open in an application that keeps a write lock and close file." -ForegroundColor Red
        continue
    }
    catch
    {
        # Skip workspace if usage metrics report are not set up or access is denied to authenticated identity
        Write-Warning "Cannot read Usage Metrics Report dataset from workspace $workspacename. User might not be allowed to access workspace, or workspace is not Premium, or Usage Metrics Report has not been created." # -ForegroundColor Yellow
        continue
    }
 }
