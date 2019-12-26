#AZURE DATALAKE CONNECTION
C:\Windows\azcopy\azcopy.exe login --identity
$env:ACCOUNT_NAME = "Test";

#AUTHENTICATION AND FUNCTION TO RETRIEVE POWERBIMETRICS APP DATA
$previoustimestamp = (get-date).AddDays(-1).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$currenttimestamp = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$file= "C:\Users\admin\test.txt"
$User = "test"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString) 
$folderFullPath = "C:\Users\test\"
Connect-PowerBIServiceAccount -Credential $Credential
#store the auth token
$auth = (Get-PowerBIAccessToken).Authorization

function Export-PbiPremiumData{
    param(
        [string]$DAXQuery,
        [string]$OutputName,
        [string]$OutputFolder,
        [string]$Auth
    )

    $outFile = "$OutputFolder\$OutputName.csv"

    $UserName = $credential.UserName
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))

    $datasets = Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | 
        ConvertFrom-Json 

    $premiumAppDataset = $datasets |        
        foreach-Object { $_.value } |
        Where-Object { $_.name -eq "Power BI Premium Capacity Metrics"} |
        Select-Object -First 1

    if($premiumAppDataset){
        $region = ([System.Uri]$datasets.'@odata.context').Host
        $datasetId = $premiumAppDataset.id
        $cs = "Provider=MSOLAP;Data Source=https://analysis.windows.net/powerbi/api;;Initial Catalog=$datasetId;Location=https://$region/xmla?vs=sobe_wowvirtualserver&db=$datasetId;MDX Compatibility= 1; MDX Missing Member Mode= Error; Safety Options= 2; Update Isolation Level= 2; Locale Identifier= 1033;User Id = $UserName; Password=$PlainPassword"
        $connection = New-Object System.Data.OleDb.OleDbConnection $cs
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand -ArgumentList $DAXQuery, $connection
        $rdr = $command.ExecuteReader()
        $result = New-Object System.Collections.ArrayList
        while($rdr.Read()){
            $properties = @{}
            for($fieldIndex = 0; $fieldIndex -lt $rdr.FieldCount; $fieldIndex ++){
                $properties[$rdr.GetName($fieldIndex)] = $rdr[$fieldIndex]
            }
            $row = New-Object PSObject -Property $properties
            $void = $result.Add($row)
        }
        $rdr.Close()
        $connection.Close()        
        $result | Export-Csv -Path $outFile -NoTypeInformation -Force
        
    }else{
        Write-Error "Premium Capacity Metrics app not found. Please install the app and try again."        
    }
}



#DAX Queries to query against PowerBI. CHANGE AS UPDATES NEEDED


#- QUERY FOR DIMENSION TABLES IN PREMIUM METRICS APP
Export-PbiPremiumData "EVALUATE CALCULATETABLE (Capacities)" "PremiumCapacities_$currenttimestamp" $folderFullPath  $auth
#- QUERY FOR FACT TABLES ON METRICS FOR PREVIOUS DAYS DATA DUMP
Export-PbiPremiumData "EVALUATE CALCULATETABLE (Filter(QueryMetrics, DATEDIFF(QueryMetrics[timestamp],TODAY(),DAY)=1)) " "PremiumQueryMetrics_$previoustimestamp" $folderFullPath $auth


#FILE PATH CREATED WITH QUERY DEFINED FILE AND FOLDER PATH FOR LOCAL MACHINE
$FullFilePath="C:\Users\admin\PremiumCapacities_$timestamp.csv"

#AZURE DATALAKE TRANSFER TO IMPORT FILE INTO
C:\Windows\azcopy\azcopy.exe copy $FullFilePath "https://test.dfs.core.windows.net/staging/PowerBI/Premium_Capacities/PremiumCapacities_$timestamp.csv" --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5
Remove-Item $FullFilePath

#DONT WANT DATALAKE COMMENT OUT BOTH DATALAKE SECTIONS ABOVE