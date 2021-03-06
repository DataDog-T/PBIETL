﻿#Datalake ACCESS CALL
C:\Windows\azcopy\azcopy.exe login --identity
$env:ACCOUNT_NAME = "ngddatalake";

#VARIABLES DEFINED SECTION (REUSE IF WANTED)
$previoustimestamp = (get-date).AddDays(-1).ToString("yyyMMdd") | foreach {$_ -replace ":", "."} #PREVIOUS DAYS TIMESTAMP ETL
$currenttimestamp = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."} #Todays TIMESTAMP ETL
$DATALAKENONPROD = "https://ngddatalake.dfs.core.windows.net/staging/PBIAPI/" #DatalakePowerBIPathNONPROD

#DEPENDENT ON NEEDS VARIABLES (CHANGE EVERY JOB SPECIFIC)
$URL = 'https://api.powerbi.com/v1.0/myorg/admin/tenantKeys'  #URL to get necessary information
$folderPath = "C:\Users\bvadmin\EncryptionKeys_$currenttimestamp.csv" #Path depending on what you are pulling down for the particular job
$DATALAKEFOLDERPATH = "Tenant_EncryptionKeys/EncryptionKeys_$currenttimestamp.csv"  #path depending on what you are pulling and just created in datalake to import data daily/etc


#Credentials Section (RESUSE for any PBI ACCESS JOB)
$file= "C:\Users\bvadmin\powerbicredssecure.txt"
$User = "mccunnt@bv.com"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $User, (Get-Content $File | ConvertTo-SecureString) #getting secured credentials from encrypted file on local machine
Connect-PowerBIServiceAccount -Credential $Credential #call to connect and auth PBI

#SCRIPT TO BRING RELEVANT DATA FROM REST API
$data= Invoke-PowerBIRestMethod -url $URL -method Get | ConvertFrom-Json  #invoking the rest method and convertying the json response to CSV delimited
$data | foreach-Object { $_.value } | Select-Object | Export-Csv -path $folderpath  #EXPORTS LOCAL COPY OF DAYS DATA TO CSV ON LOCAL MACHINE

#DATALAKE EXPORT INSTEAD OF FILE
C:\Windows\azcopy\azcopy.exe copy $folderpath $DATALAKENONPROD$DATALAKEFOLDERPATH --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5
#Remove-Item $folderPath #REMOVES LOCAL COMPUTER COPY OF WHAT WAS JUST IMPORTED INTO DATALAKE
