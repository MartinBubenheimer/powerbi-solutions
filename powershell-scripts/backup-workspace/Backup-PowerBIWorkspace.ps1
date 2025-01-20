# PowerShell script to back up Power BI workspace content

# Download Copy-PowerBIReportContentToBlankPBIXFile.ps1 from:
# https://github.com/JamesDBartlett3/PowerBits/blob/main/PowerShell/Scripts/Copy-PowerBIReportContentToBlankPBIXFile.ps1

param (
    [string]$Workspace,
    [string]$WorkspaceId,
    [string]$OutPath,
    [switch]$Force,
    [switch]$Zip
)

$targetWorkspaceId = "c3f3371a-b18e-44e7-8667-e9ca9d57fc81"
$blankReportUrl = "https://github.com/MartinBubenheimer/powerbi-solutions/raw/refs/heads/main/helper-files/BlankPbixFile.pbix"

# Ensure Power BI cmdlets are installed
if (!(Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable)) {
    Install-Module -Name MicrosoftPowerBIMgmt -Force -Scope CurrentUser
}

Import-Module MicrosoftPowerBIMgmt

# Validate inputs
if (-not $OutPath) {
    Write-Error "You must specify OutPath."
    exit 1
}

if (-not $Workspace -and -not $WorkspaceId) {
    Write-Error "You must specify either Workspace or WorkspaceId."
    exit 1
}

if ($Workspace -and $WorkspaceId) {
    $workspaceFromName = Get-PowerBIWorkspace -Name $Workspace
    if ($workspaceFromName.Id -ne $WorkspaceId) {
        Write-Error "Workspace name and WorkspaceId do not match. Exiting."
        exit 1
    }
}

# Interactive login
Connect-PowerBIServiceAccount

# Get workspace details
if ($WorkspaceId) {
    $workspaceDetails = Get-PowerBIWorkspace -Id $WorkspaceId # -Scope Organization # use -Scope Organization only with ServicePrincipal with admin consent
} else {
    $workspaceDetails = Get-PowerBIWorkspace -Name $Workspace # -Scope Organization # use -Scope Organization only with ServicePrincipal with admin consent
}

if (-not $workspaceDetails) {
    Write-Error "Workspace not found. Exiting."
    exit 1
}

# Ensure output path exists
$workspaceFolder = Join-Path -Path $OutPath -ChildPath $workspaceDetails.Name
if (-not (Test-Path -Path $workspaceFolder)) {
    New-Item -ItemType Directory -Path $workspaceFolder | Out-Null
}

# Backup assets
$workspaceId = $workspaceDetails.Id
Write-Host "Backing up content from workspace: $($workspaceDetails.Name)"

$exportFailuresList = @()

# Function to export dataset using REST API via Invoke-PowerBIRestMethod
function Export-Dataset {
    param (
        [string]$DatasetId,
        [string]$ExportPath
    )

    # REST API URL for dataset export
    $apiUrl = "/v1.0/myorg/datasets/$DatasetId/export"

    # Call the Power BI REST API using the existing session
    Invoke-PowerBIRestMethod -Url $apiUrl -Method Get -OutFile $ExportPath
}

# Export datasets (semantic models)

# Datasets that still have their reports in the workspace are included in the report exports.
# Datasets that don't have their original report in the workspace anymore cannot be downloaded from an official REST API.
# Approach could be to analyze the web UI traffic to understand how the web UI does such exports because it's possible there.
# Be aware that at the web UI this is a three step process:
# 1. Initiate the download of the semantic models
# 2. Monitor whether the download is ready (you need to investigate whether this is a polling or push mechanism)
# 3. Download the file
# An algorithm for this script to identify the semantic models that need to be downloaded separately:
# List all datasets in the workspace
# List all reports in the workspace
# For all reports that have same name as a semantic model, an are bound to this semantic model, they are likely to be downloaded together 
# when downloading the report.
# Download all remaining semantic models separately.
# This is not a 100% solution. Reports could be renamed independantly from the semantic model, then the download of the report from REST API 
# will still include semantic model, and a report could be deleted and a same name report could have been created in the web browser, then the
# semantic model would not be included in the download of the report, but that's an identifyable situation, because such report cannot be downloaded 
# by default. So with this approach, you might end up having downloaded reports including semantic model plus the semantic model seperately.

# Export reports
$reportList = Get-PowerBIReport -WorkspaceId $workspaceId # -Scope Organization # use -Scope Organization only with ServicePrincipal with admin consent

foreach ($reportItem in $reportList) {
    try {
        # Determine file extension based on report type

        $fileExtension = if (-not $reportItem.DatasetId) { ".rdl" } else { ".pbix" }
        $exportFilePath = Join-Path -Path $workspaceFolder -ChildPath "$($reportItem.Name)$fileExtension"
        
        if ($Force -and (Test-Path $exportFilePath)) {
            Remove-Item -Path $exportFilePath -Force
            Write-Host "Removed existing file: $exportFilePath"
        }
        if (-not (Test-Path $exportFilePath)) {
            Write-Host "Trying to export report $($reportItem.Name), ID $($reportItem.Id)"

            # Use Invoke-PowerBIRestMethod and the Export REST API to choose between downloading a file with dataset or live connection.
            # https://learn.microsoft.com/en-us/rest/api/power-bi/reports/export-report-in-group
            # This could be especially interesting for web created reports, see last export step.

            Export-PowerBIReport -Id $reportItem.Id -OutFile $exportFilePath -WorkspaceId $workspaceId
            Write-Host "Exported report: $($reportItem.Name)$fileExtension"
        } else {
            Write-Host "Skipped report because file already exists: $($reportItem.Name)$fileExtension"
        }
    } catch {
        $exportFailuresList += [PSCustomObject]@{
            ReportName = $reportItem.Name
            ReportId = $reportItem.Id
            WorkspaceId = $workspaceId
        }
        Write-Warning "Failed to export report: $($reportItem.Name). Adding to retry list."
    }
}

# Export dataflows
$dataflowList = Get-PowerBIDataflow -WorkspaceId $workspaceId
foreach ($dataflowItem in $dataflowList) {
    try {
        $exportFilePath = Join-Path -Path $workspaceFolder -ChildPath "$($dataflowItem.Name).json"
        if ($Force -or -not (Test-Path $exportFilePath)) {
            Export-PowerBIDataflow -Id $dataflowItem.Id -OutFile $exportFilePath -WorkspaceId $workspaceId
            Write-Host "Exported dataflow: $($dataflowItem.Name)"
        } else {
            Write-Host "File already exists, skipping: $exportFilePath"
        }
    } catch {
        $exportFailuresList += "Failed to export dataflow: $($dataflowItem.Name). $_"
    }
}

# Retry exporting reports created in the web browser
$retryFailuresList = $exportFailuresList | Where-Object { $_.ReportId -ne $null }
foreach ($failure in $retryFailuresList) {
    $retryExportFilePath = Join-Path -Path $workspaceFolder -ChildPath "$($failure.ReportName).pbix"
    Write-Host "Retrying export for web-created report: $($failure.ReportName)"
    & "$(Split-Path -Path $MyInvocation.MyCommand.Definition)\Copy-PowerBIReportContentToBlankPBIXFile.ps1" `
        -SourceWorkspaceId $failure.WorkspaceId `
        -SourceReportId $failure.ReportId `
        -targetWorkspaceId $targetWorkspaceId `
        -OutFile $retryExportFilePath `
        -BlankPbix $blankReportUrl
}

# Output export failures
if ($exportFailuresList.Count -gt 0) {
    Write-Host "The following items could not be exported:" -ForegroundColor Yellow
    $exportFailuresList | Where-Object { $_.ReportId -eq $null } | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
} else {
    Write-Host "All items exported successfully." -ForegroundColor Green
}

# Zip the workspace folder if -Zip is specified
if ($Zip) {
    $zipFilePath = Join-Path -Path $OutPath -ChildPath "$($workspaceDetails.Name).zip"
    if (Test-Path $zipFilePath) {
        if ($Force) {
            Remove-Item -Path $zipFilePath -Force
            Write-Host "Removed existing zip file: $zipFilePath"
        } else {
            Write-Error "Zip file already exists: $zipFilePath. Use -Force to overwrite."
            exit 1
        }
    }

    Compress-Archive -Path $workspaceFolder -DestinationPath $zipFilePath -Force
    Write-Host "Workspace folder zipped to: $zipFilePath"
}

# Disconnect Power BI session
Disconnect-PowerBIServiceAccount
