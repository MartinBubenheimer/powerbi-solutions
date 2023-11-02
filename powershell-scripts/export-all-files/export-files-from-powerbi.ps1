# Prevent existing arrays from growing
Remove-Variable -Name * -ErrorAction SilentlyContinue

# Configuration
$ExportRootPath = "C:\Temp\TripsReports\Datasets"

# Interactive login to Power BI API
Connect-PowerBIServiceAccount

# List all workspaces
$workspaces = Get-PowerBIWorkspace

# Create folders for datasets - required to have only one folder per dataset even if the dataset is used in reports in different workspaces
$datasetfolders = @{}

# Iterate workspaces
for ($workspaceiteration = 0; $workspaceiteration -lt $workspaces.length; $workspaceiteration++) {
    $newreports = Get-PowerBIReport -WorkspaceId $workspaces[$workspaceiteration].Id

    # Iterate reports in each workspace
    for ($reportiteration = 0; $reportiteration -lt $newreports.length; $reportiteration++) {
        $currentdataset = Get-PowerBIDataset -Id ($newreports[$reportiteration].DatasetId) -WorkspaceId $workspaces[$workspaceiteration].Id
        if($currentdataset.length -gt 0) {
            $currentpath = $ExportRootPath + "\" + ($currentdataset.Id) + " (" + ($currentdataset.Name) + ")"
            New-Item -ItemType Directory -Force -Path $currentpath | out-null
            if(-Not ($datasetfolders.ContainsKey($currentdataset.Id))) {
                $datasetfolders.Add($currentdataset.Id, $currentpath)
            }
        }
    }
}

# Export pbix files into their respective folders

# Iterate workspaces
for ($workspaceiteration = 0; $workspaceiteration -lt $workspaces.length; $workspaceiteration++) {
    $newreports = Get-PowerBIReport -WorkspaceId $workspaces[$workspaceiteration].Id

    #Iterate reports in each workspce
    for ($reportiteration = 0; $reportiteration -lt $newreports.length; $reportiteration++) {

        # Errors might come from usage metrics reports or from reports created in the web-browser
        # To do: Skip datasets called "Dashboard Usage Metrics Model" or "Report Usage Metrics Model"
        #        or try-catch errors and then write name of workspace and report attempted to export to console out.
        $currentdatasetid = $newreports[$reportiteration].DatasetId
        $currentdatasetpath = $datasetfolders[([System.Guid]::Parse($currentdatasetid))]
        $currentreportpath = $currentdatasetpath + "\Workspaces\" + ($workspaces[$workspaceiteration].Name) # without filename
        New-Item -ItemType Directory -Force -Path $currentreportpath | out-null
        $currentfilename = ($newreports[$reportiteration].Name) + " (" + ($newreports[$reportiteration].Id) + ").pbix" # filename only, without path
        Export-PowerBIReport -Id $newreports[$reportiteration].Id -OutFile "$currentreportpath\$currentfilename"
    }
}

# ls "C:\Temp\TripsReports" -r | % { $_.FullName + $(if($_.PsIsContainer){'\'}) + " " + ([math]::Round($_.Length / 1MB, 3)) + " MB" } | Select-String -Pattern ".pbix"