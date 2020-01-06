
#DailyCleanUp Script

$PBIAPIlogs = Get-ChildItem -Path "C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\*" -Include *.csv -Name

$PREMIUMlogs = Get-ChildItem -Path "C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\*" -Include *.csv -Name

$currenttimestamp = (get-date).ToString("yyyMMdd_HH:mm:ss") | foreach {$_ -replace ":", "."}

Foreach ($Name in $PBIAPIlogs)
{import-csv ("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\" + $Name) | Select * | Export-Csv -Path "C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\Master\PBIAPILOGS_$currenttimestamp.csv" -Append  
Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\" + $Name)
}

Foreach ($Name in $PREMIUMlogs)
{import-csv ("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\" + $Name) | Select * | Export-Csv -Path "C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\Master\PBIPREMIUMLOGS_$currenttimestamp.csv" -Append 
Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\" + $Name)
}


C:\Windows\azcopy\azcopy.exe login --identity

C:\Windows\azcopy\azcopy.exe copy "C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\Master\PBIPREMIUMLOGS_$currenttimestamp.csv" "https://ngddatalake.dfs.core.windows.net/staging/Logs/PBIPREMIUM/Powershell/PBIPREMIUMLOGS_$currenttimestamp.csv" --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5
C:\Windows\azcopy\azcopy.exe copy "C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\Master\PBIAPILOGS_$currenttimestamp.csv" "https://ngddatalake.dfs.core.windows.net/staging/Logs/PBIAPI/Powershell/PBIAPILOGS_$currenttimestamp.csv" --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5


if(![System.IO.File]::Exists("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\Master\PBIPREMIUMLOGS_$currenttimestamp.csv"))
{ }
else
{
Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUMLOGS\Master\PBIPREMIUMLOGS_$currenttimestamp.csv") }
if(![System.IO.File]::Exists("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\Master\PBIAPILOGS_$currenttimestamp.csv"))
{}
else
{
Remove-Item ("C:\Program Files\WindowsPowerShell\Logs\PBIAPILOGS\Master\PBIAPILOGS_$currenttimestamp.csv")
}