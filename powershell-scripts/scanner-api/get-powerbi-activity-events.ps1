# Export Power BI activity log

# Configuration
# Alternatively, files can be stored in a datalake (e.g. partitioned by refresh date or with date in the file name)
$days = 30 #number of days to be exported, valid range 1..30
$filelocation = "C:\Temp\Activities\"

# connect service principal to Power BI
#$clientSecret = "***************************" | ConvertTo-SecureString -AsPlainText -Force
#$connectCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", $clientSecret
#Connect-PowerBIServiceAccount -Tenant xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -ServicePrincipal -Credential $connectCreds

# connect user interactive login
Connect-PowerBIServiceAccount

$date = Get-Date
$startdate = $enddate.AddDays((-1)*$days+1)

$startdatetime = $startdate.ToString("yyyy-MM-dd") + "T00:00:00.000"
$enddatetime = $enddate.ToString("yyyy-MM-dd") + "T23:59:59.999"

# in very active tenants you might prefer to export one file per hour
# https://learn.microsoft.com/en-us/rest/api/power-bi/admin/get-activity-events
# https://learn.microsoft.com/en-us/powershell/module/microsoftpowerbimgmt.admin/get-powerbiactivityevent
$exportdate = Get-Date
for ($var =((-1) * $days + 1); $var -le 0; $var++) {
    $date = (Get-Date).AddDays($var)
    $startdatetime = $date.ToString("yyyy-MM-dd") + "T00:00:00.000"
    $enddatetime = $date.ToString("yyyy-MM-dd") + "T23:59:59.999"
    $path = $filelocation + "Activities_" + $exportdate.ToString("yyyy-MM-ddThh-mm-ss-fff") + "_" + $date.ToString("yyyy-MM-dd") + ".json"
    $activityevents = Get-PowerBIActivityEvent -StartDateTime $startdatetime -EndDateTime $enddatetime
    if($activityevents.Length -gt 0) {
        $activityevents | Out-File -FilePath $path
    }
}
