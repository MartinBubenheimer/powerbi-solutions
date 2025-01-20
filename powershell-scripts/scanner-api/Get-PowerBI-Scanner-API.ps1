# Export detailed scanner API results

# Configuration
# Alternatively, files can be stored in a datalake (e.g. partitioned by refresh date or with date in the file name)
$filelocation = "C:\Temp\Scans\"

# Microsoft Blog Announcement Enhanced Scanner API:
# https://powerbi.microsoft.com/en-us/blog/announcing-scanner-api-admin-rest-apis-enhancements-to-include-dataset-tables-columns-measures-dax-expressions-and-mashup-queries/
# Report Template using this data, including table details:
# https://powerbi.tips/2021/10/using-the-power-bi-scanner-api-to-manage-tenants-entire-metadata/
# Power BI Monitor solution: usage, refreshes, licencense, etc.
# https://github.com/RuiRomano/pbimonitor
# Why and when tables array is empty (the dataset must haven been refreshed in the service at least once)
# https://community.fabric.microsoft.com/t5/Developer/Enhaced-Metadata-scanning-doesn-t-retrieve-tables/m-p/2207822

# connect service principal to Power BI
#$clientSecret = "*******************************" | ConvertTo-SecureString -AsPlainText -Force
#$connectCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", $clientSecret
#Connect-PowerBIServiceAccount -Tenant xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ServicePrincipal -Credential $connectCreds

# connect user interactive login
Connect-PowerBIServiceAccount

# get list of workspaces
$workspaceids = Invoke-PowerBIRestMethod -Method GET -Url "https://api.powerbi.com/v1.0/myorg/admin/workspaces/modified" | convertfrom-json

# request scanner information for all workspaces
$array = @()
foreach($workspaceid in $Workspaceids)
{
    $array = $array + $workspaceid.id
}
$chunks = [math]::ceiling($array.Length/100)
$scanids = @()

# each scanner API call can scan up to 100 workspaces, so process chunks of 100 workspaces in a loop
for ($var = 0; $var -lt $chunks; $var++)
{
    $start = $var * 100
    $end = (($start + 99),($array.Length - 1) | Measure-Object -Minimum).Minimum
    $jsonlist = ""
    foreach($id in $array[$start..$end])
    {
        $jsonlist = $jsonlist + '"' + $id + '",'
    }
    $jsonlist = $jsonlist -replace ".{1}$" # remove last character, the excessive ","
    $body = '{"workspaces":[' + $jsonlist + ']}'
    $url = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/getInfo?lineage=True&datasourceDetails=True&datasetSchema=true&datasetExpressions=true&getArtifactUsers=true"
    $method = "POST"

    $scanids = $scanids + (Invoke-PowerBIRestMethod -Method $method -Url $url -Body $body | convertfrom-json)
}
# wait for scans to finish
$var = 1
do {
    $done = 0
    Start-Sleep -Seconds 30
    foreach($scan in $scanids) {
        $url = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/scanStatus/" + $scan.id
        $scanstatus = Invoke-PowerBIRestMethod -Method GET -Url $url | convertfrom-json
        if($scanstatus.status -eq "Succeeded")
        {
           $done += 1
        } 
    }
    $var++
} while ($done -lt $scanids.Length -and $var -lt 100)
"Scanned " + $array.Length + " workspaces. "
"Scan duration: " + [math]::round($var/2, 1) + " minutes " + [Environment]::NewLine

# scans finished - retrieve result
foreach($scan in $scanids) {
    $path = $filelocation + $scan.id + ".json"
    $url = "https://api.powerbi.com/v1.0/myorg/admin/workspaces/scanResult/" + $scan.id
    Invoke-PowerBIRestMethod -Method GET -Url $url | Out-File -FilePath $path
}
