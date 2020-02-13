Import-Module PBIPREMIUM
$tableName = "PBISCHEMA"
$dailyDateofData = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$Global:Logfilepath = ComputeNewValue $tableName
$logtime = (get-date).ToString("yyyMMdd_HH:mm:ss") | foreach {$_ -replace ":", "."}




#DON'T CHANGE:PIPELINE PARAMETERS
$Fullpath = $folderFullPath + $tableName + "_" + $dailyDateofData + ".csv"
$file_name= $tableName + "_" +  $dailyDateofData
function Export-PbiPremiumSchema{
    param(
          [string] $ServerName = 'https://analysis.windows.net/powerbi/api',
          [string] $DBName   = $datasetId,
          [string] $sqlCommand = 'SELECT table_schema, table_name FROM $system.dbschema_tables',
          [string]$OutputName,
          [string]$OutputFolder,
          [string] $auth
    )

    Try { Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandStart"
    Connect-PowerBIServiceAccount -Credential $credential
    }
    catch
    { Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
    Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandEnd"

    $outFile = "$OutputFolder\$OutputName.csv"
    $auth = (Get-PowerBIAccessToken).Authorization
    $UserName = $credential.UserName
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
    $datasets = 
    Try { Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandStart"
     Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json 
     }
     catch
{
	Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName)
}
Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandEnd"

    $premiumAppDataset = $datasets |        
        foreach-Object { $_.value } |
        Where-Object { $_.name -eq "Power BI Premium Capacity Metrics"} |
        Select-Object -First 1

    if($premiumAppDataset){
    Try {
    Write-Log -Message 'Creating Premium Capacity Metrics App OLEDB MSOLAP Connection to Extract Information' -Type "CommandStart"
        $region = ([System.Uri]$datasets.'@odata.context').Host
        $datasetId = $premiumAppDataset.id
        $cs = "Provider=MSOLAP;Data Source=https://analysis.windows.net/powerbi/api;;Initial Catalog=$datasetId;Location=https://$region/xmla?vs=sobe_wowvirtualserver&db=$datasetId;MDX Compatibility= 1; MDX Missing Member Mode= Error; Safety Options= 2; Update Isolation Level= 2; Locale Identifier= 1033;User Id = $UserName; Password=$PlainPassword"
        $connection = New-Object System.Data.OleDb.OleDbConnection $cs
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand -ArgumentList  $sqlCommand, $connection
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
        }
        catch
        {
        Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName)
        }
       Write-Log -Message 'Creating Premium Capacity Metrics App OLEDB MSOLAP Connection to Extract Information' -Type "CommandEnd" 
    }
    else{
        Write-Log -Message "Premium Capacity Metrics app not found. Please install the app and try again."   -Type "Exception-AppNotFoundorInstalled"     
    }

}

#Export-PbiPremiumSchema "$file_name" $folderFullPath $auth

Export-PbiPremiumSchema "PBISCHEMA" "C:\Users\bvadmin\PBIPREMIUM" $auth