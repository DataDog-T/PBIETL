Import-Module PBIAPI
#Datalake ACCESS CALL
#SELECT ACTIVITY PARAMAETERS
$tableName = "Workspace_Dashboards"
$datalakeFolder = "Workspace_Dashboards"
$dailyDateofData = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$Global:Logfilepath = ComputeNewValue $tableName

Try {
Write-Log -Message 'AzCopy Initial Login Using Machine Identity' -Type "Script_CommandStart"
C:\Windows\azcopy\azcopy.exe login --identity
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "AzCopy Initial Login Using Machine Identity" -Type "CommandEnd"


#DON'T CHANGE:PIPELINE PARAMETERS
$Fullpath = $PBIfolderFullPath + $tableName + "_" + $dailyDateofData + ".csv"
$file_name= $tableName + "_" +  $dailyDateofData
$datalakeFinalPath = $PBIdatalakePath + $datalakeFolder + "/" + $tableName + "_" + $dailyDateofData + ".csv"


Try {
Write-Log -Message 'Connecting to PBI Service Account using Admin credentials' -Type "Script_CommandStart"
Connect-PowerBIServiceAccount -Credential $credential #call to connect and auth PBI
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "Connecting to PBI Service Account using Admin credentials" -Type "CommandEnd"


#DEPENDENT VARIABLES (Must change every time to match corresponding API)
$LASTAPIPARAM = '/dashboards' #Parameter needed to retrieve all datasets in a workspace
$folderPath = "C:\Users\bvadmin\PBIAPI\Workspacesfordashboards_$dailyDateofData.csv" #Path on VM to save results to


#SCRIPT TO BRING RELEVANT DATA FROM REST API
Try {
Write-Log -Message 'Using PBIManagement Powershell Module calling (Get all workspaces that are not personal with organization scope)' -Type "Script_CommandStart"
Get-PowerBIWorkspace -scope Organization -ALL |Where { ($_.Type -ne "PersonalGroup")} | Export-Csv $folderPath
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }

Write-Log -Message "Using PBIManagement Powershell Module calling (Get all workspaces that are not personal with organization scope)" -Type "CommandEnd"


#ITERATE AND PASS PARAMETERS ONE BY ONE FROM ABOVE TO GIVE DATA FOR EACH ELEMENT WE NEED BELOW
Try { 
Write-Log -Message 'Importing CSV from previous call to iterate through each parent asset and get associated child items' -Type "Script_CommandStart"
$Ids = import-csv $folderPath 
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
Write-Log -Message "Importing CSV from previous call to iterate through each parent asset and get associated child items" -Type "CommandEnd"

Foreach ($Id in $Ids) {
Try
{ Write-Log -Message ("Looping through each parent ID:" + $Id.Id + "-" + "calling the PBI rest api to retrieve child items and appending output to a CSV file") -Type "Script_CommandStart"
$MAINURL  = 'https://api.powerbi.com/v1.0/myorg/admin/groups/' + $Id.Id + $LASTAPIPARAM #Concat the REST API URI together to grab dashboards
$allinfo = Invoke-PowerBIRestMethod -Url $MAINURL -Method Get -ErrorAction SilentlyContinue | ConvertFrom-Json 
#DEFINE IN @{1= WHAT COLUMN NAME YOU NEED TO DESCRIBE WHAT ID YOU PASSED IN FIRST API PARAMETER SO YOU HAVE PARENT ID OF WHAT YOU ITERATED THROUGH AND IN SELECT-OBJECT DEFINE THE VARIABLES YOU WANT TO RETRIEVE FROM API CALL
$allinfo | foreach-Object { $_.value} | Select-Object id, displayName, embedUrl, isReadOnly,@{l="workspaceid";e={$Id.Id}} | Export-Csv $Fullpath -Append  
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
Write-Log -Message ("Looping through each parent ID:" + $Id.Id + "-" + "calling the PBI rest api to retrieve child items and appending output to a CSV file") -Type "Script_CommandEnd"
}
Write-Log -Message ("Looping through all parent Id's Completed") -Type "Script_CommandEnd"

Try{
Write-Log -Message 'Copying CSV File to Datalake Folder Path and returning AZcopy JobID' -Type "CommandStart"
$firstjob = azCopyComputeRunningJobID $Fullpath $datalakeFinalPath return $firstjob.JOBID
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID)}
Write-Log -Message (ComputeNewValueazcopy $firstjob.JOBID) -Type "CommandEnd - AzCopy" -CopyDataJobId ($firstjob.JOBID)

$cleanuppath = $PBIlogDatalakePath + "Azcopy/" + $firstjob.JOBID + ".log"
$logpath = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $firstjob.JOBID + ".log"

Try { Write-Log -Message "Copying Default AZCOPY LogFile to Datalake Folder" -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID)
$logjob = azCopyComputeRunningJobID $logpath $cleanuppath return $logjob.JOBID
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}
Write-Log -Message (ComputeNewValueazcopy $logjob.JOBID) -Type "CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up File that Successfully Copied to Datalake' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)
Remove-Item $Fullpath
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID) }

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)
Try { Write-Log -Message 'Removing and Cleaning up File that Successfully Copied to Datalake' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)
Remove-Item $folderPath
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID) }

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up data copy log fil created for Azopy' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $firstjob.JOBID + ".log")
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}

Write-Log -Message "Files Removed and Cleaned-Up" -Type "Script_CommandEnd" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Try { Write-Log -Message 'Removing and Cleaning up copylogfile job log created for Azopy' -Type "CommandStart" -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)

Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS\" + $logjob.JOBID + ".log")
}
catch 
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) -CopyDataJobId ($firstjob.JOBID) -CopyLogJobId ($logjob.JOBID)}


if(![System.IO.File]::Exists($Logfilepath))
{ }
else
{
Move-Item -Path $Logfilepath -Destination ("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\" + $tableName + "_" + $currentDay_yyyMMdd + ".csv") }