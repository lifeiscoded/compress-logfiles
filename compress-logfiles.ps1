<#
Author : Bilgin Işık

Attention:
Because Compress-Archive relies upon the Microsoft .NET Framework API System.IO.Compression.ZipArchive to compress files,
the maximum file size that you can compress by using Compress-Archive is currently 2 GB. This is a limitation of the underlying API.

Requirements :
Compress-Archive works with only PS Version 5.x and .Net Framework 4.5 or greater.
PS Version greater than 5


Example usage of script :

Path is mandotory.

.\compress-logs.ps1 -Path C:\TempLogs
.\compress-logs.ps1 -Path C:\TempLogs -Filter log,txt,console >> Default is "log,txt"
.\compress-logs.ps1 -Path C:\TempLogs -DaysBack 15 >> Default is 5
.\compress-logs.ps1 -Path C:\TempLogs -ArchiveName LogArchive >> Default is "Logs"

You can combine the parameters.

#>



Param([Parameter(Position=1,Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName,ParameterSetName="PerPath")][Alias("FullName")]$Path,
		[Parameter(Position=2,ParameterSetName="PerPath")][STRING]$Filter = "log,txt",
		[Parameter(Position=3,ParameterSetName="PerPath")][INT]$DaysBack = 5,
		[Parameter(Position=4,ParameterSetName="PerPath")][STRING]$ArchiveName = "Logs"
)


$Releases = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse | Get-ItemProperty -name Version,Release -EA 0 | Where-Object { $_.PSChildName -match '^(?!S)\p{L}' -and $_.Release -ge 378389 } | Select-Object Release

foreach($R in $Releases)
{
    if($R.Release -ge 378389)
    {
        [bool]$netVersionCheck = $true
    }
}

Write-Verbose -Message "Your .Net Version is : $netVersionCheck" -Verbose

if ($PSVersionTable.PSVersion.major -eq '5' -and $netVersionCheck){


$LogFolder=$Path
$paramFilter = $Filter
$Arcfolder="$LogFolder\Archive"
$TempFolder ="$Arcfolder\Temp"
$LastWrite=(get-date).AddDays(-1 * $DaysBack).ToString("MM/dd/yyyy")
$logdate = (get-date).ToString("ddMMyyyy")

$StartTime = $(get-date)

if (-not (Test-Path -LiteralPath $Arcfolder)) {

    try {
        New-Item -Path $Arcfolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
		New-Item -Path $TempFolder -ItemType Directory -ErrorAction Stop | Out-Null #-Force
    }
    catch {
        Write-Error -Message "Unable to create directory '$Arcfolder'. Error was: $_" -ErrorAction Stop
    }

    Write-Verbose -Message "Successfully created directory '$Arcfolder'." -Verbose
    Write-Output ("-"*80)

}
else {
    Write-Verbose -Message "$ArcFolder already exist" -Verbose
}

#$_.extension -eq ".log" -or $_.extension -eq ".txt"
#$Logs = Get-ChildItem $LogFolder | Where-Object {$_.LastWriteTime -le $LastWrite -and !($_.PSIsContainer)} | sort-object LastWriteTime | Move-Item -Destination $TempFolder
$Logs = Get-ChildItem $LogFolder | Where-Object {$_.LastWriteTime -le $LastWrite -and !($_.PSIsContainer) -and ($paramFilter.Contains($_.Extension.Replace(".","")))} | sort-object LastWriteTime

if($Logs)
{
    try {
	    $Logs | Move-Item -Destination $TempFolder
	    Compress-Archive -Path $TempFolder\* -DestinationPath $Arcfolder\$ArchiveName-$logdate.zip -Force -ErrorAction Stop
	    Remove-Item -Path $TempFolder\* -Force

	    $elapsedTime = $(get-date) - $StartTime
	    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
	    Write-Verbose -Message "Total elapsed time : $totalTime" -Verbose
    }
    catch {
        Write-Error -Message "Unable to process compress. Error was: $_" -ErrorAction Stop
    }
}
else {Write-Verbose -Message "Found no log files older than 1 days." -Verbose}

}
else{
    # no method found.. Just have to copy without compression
    Write-Verbose -Message "PS Version is lower than 5 or .Net Version is lower than 4.5, please update your PS or .Net" -Verbose
}
