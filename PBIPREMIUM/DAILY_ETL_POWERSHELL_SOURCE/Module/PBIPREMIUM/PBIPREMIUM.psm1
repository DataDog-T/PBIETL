$global:folderFullPath = 'C:\Users\Test\PBIPREMIUM\'
$env:ACCOUNT_NAME = "Test"
$env:AZCOPY_LOG_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYLOGS"
$env:AZCOPY_JOB_PLAN_LOCATION = "C:\Program Files\WindowsPowerShell\Logs\AZCOPYPLANS"
$global:previousDay_yyyMMdd = (get-date).AddDays(-1).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$global:currentDay_yyyMMdd = (get-date).ToString("yyyMMdd_HH:mm:ss") | foreach {$_ -replace ":", "."}
$global:Logfilepath = $null
$global:pbiAdminCredFile= "C:\Users\test\powerbicredssecure.txt"
$global:pbiAdminUserName = "test&test.com"
$global:datalakePath = "https://test.dfs.core.windows.net/staging/PBIPREMIUM/"
$global:logDatalakePath = "https://test.dfs.core.windows.net/staging/Logs/PBIPREMIUM/"
$global:AZCOPYMessageContent = $null
$global:sourceTable = $null
$global:datasetName = $null
$global:AZCOPYMessageType = (C:\Windows\azcopy\azcopy.exe jobs list --output-type json | ConvertFrom-Json | Select-Object MessageType -OutVariable string -First 1)
$global:credential = New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $pbiAdminUserName, (Get-Content $pbiAdminCredFile | ConvertTo-SecureString) 
$global:attributeHierarchyStoragesSQL = 'Select * from $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES' #distinct data count for each column
$global:attributeHierarchies = 'Select * from $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHIES'  #ties hierarchy id to column
$global:columnStoragesSQL = 'SELECT * from $SYSTEM.TMSCHEMA_COLUMN_STORAGES' #has order by column, row count is inaccurate
$global:columnsSQL = 'Select * from $SYSTEM.TMSCHEMA_COLUMNS' #column name, ID for table, data type, category, hidden, iskey, isunique, is nullable, summarize by, expression for calc columns, hierarchy id, refresh time, modify time. source provider type, display folder
$global:dataSourcesSQL = 'SELECT * from $SYSTEM.TMSCHEMA_DATA_SOURCES' #connection string, account, impersonation mode, name
$global:hierarchiesSQL = 'Select * from $SYSTEM.TMSCHEMA_HIERARCHIES' #hierarchy name, display folder
$global:hierarchyStoragesSQL = 'Select * from $SYSTEM.TMSCHEMA_HIERARCHY_STORAGES' #user hierarchy definitions
$global:KpiSQL = 'Select * from $SYSTEM.TMSCHEMA_KPIS' #KPI definition
$global:levelsSQL = 'Select * from $SYSTEM.TMSCHEMA_LEVELS' #hierarchy level and model source column
$global:measuresSQL = 'Select * from $SYSTEM.TMSCHEMA_MEASURES' #measure and expressions, formatt, hidden, display folder
$global:modelSQL = 'Select * from $SYSTEM.TMSCHEMA_MODEL' #name of each model
$global:partitionsSQL = 'Select * from $SYSTEM.TMSCHEMA_PARTITIONS' #source queries for each table
$global:perspectiveColumnsSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_COLUMNS' #perspective table to perspective column maps
$global:perspectiveHierarchiesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_HIERARCHIES' # perspective table to hierarchy id map
$global:perspectiveMeasuresSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_MEASURES' # perspective table id to measure id map
$global:perspectiveTablesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_TABLES' # perspective to table map
$global:perspectivesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVES' # list of perspectives
$global:relationshipsSQL = 'Select * from $SYSTEM.TMSCHEMA_RELATIONSHIPS' # active , type, crossfilter, table, colmn, cardinality
$global:rolemembershipsSQL = 'Select * from $SYSTEM.TMSCHEMA_ROLE_MEMBERSHIPS' # member name, ID, Modified time, role id,
$global:rolesSQL = 'Select * from $SYSTEM.TMSCHEMA_ROLES' # model, name, description, permission
$global:tablepermissionsSQL = 'Select * from $SYSTEM.TMSCHEMA_TABLE_PERMISSIONS' # role, rable, filter expression, modified time
$global:tablesSQL = 'Select * from $SYSTEM.TMSCHEMA_TABLES'  #tables, description, hidden, 
$global:catalogSQL = 'Select * from $SYSTEM.DBSCHEMA_CATALOGS' #Catalog name, description, compatibility level, type, database id, version
$global:schemasSQL = 'SELECT * FROM $System.DBSchema_Tables'
 

function azCopyComputeRunningJobID ($fileToCopy,$datalakeFullPath)
{ 
C:\Windows\azcopy\azcopy.exe copy $fileToCopy $datalakeFullPath --overwrite=FALSE --follow-symlinks --recursive --from-to=LocalBlobFS --put-md5 --output-type=json | ConvertFrom-Json | Select-Object MessageType,MessageContent | Where-Object MessageType -EQ "INIT" | 
Select-Object @{l='LogFileLocation';e={$_.MessageContent.Split(',')[1]}} | Select-Object @{l='JobID';e={$_.LogFileLocation.Split(":")[1]}} | Select-Object @{l='JOBID';e={$_.JobID.Replace("""","")}} -OutVariable string 
}

function ComputeNewValue ($tableName)
{
   "C:\Program Files\WindowsPowerShell\Logs\PBIPREMIUM_" + $tableName + "_" + $currentDay_yyyMMdd + ".csv"
}

function ComputeNewValueazcopy ($jobsid)
{
   C:\Windows\azcopy\azcopy.exe jobs show "$jobsid"  --output-type json  | ConvertFrom-Json | Select-Object MessageContent -OutVariable string -First 1
}

function ComputeNewDataCheckQuery ($sourceTable)
{
   "EVALUATE SUMMARIZE(Filter(" + $sourceTable + "," + "DATEDIFF(" + $sourceTable + "[timestamp]" + "," + "TODAY()" +"," + "DAY" + ")" + "=1" + ")" + "," + '"Hours"' +"," + "DISTINCTCOUNT(" + $sourceTable + "[timestamp]" + "))"
}

function ComputeNewDatasetName ($datasetName)
{
[Parameter(Mandatory)]
[string]$datasetName

}


function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$ScriptName,
        [int]$ScriptLineNumber,

        [Parameter()]
        [string]$Type,
        [string]$CopyDataJobId,
        [string]$CopyLogJobId
    )
    
    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'ScriptName' = $MyInvocation.ScriptName
        'ScriptLineNumber' = $MyInvocation.ScriptLineNumber
        'Message' = $Message
        'Type' = $Type
        'CopyDataJobId' = $CopyDataJobId
        'CopyLogJobId' = $CopyLogJobId
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    $line | Export-Csv -Path $Logfilepath -Append -NoTypeInformation
}

function Export-PbiPremiumData{
    param(
        [string]$DAXQuery,
        [string]$OutputName,
        [string]$OutputFolder,
        [string]$Auth
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
    Try{
    Write-Log -Message "ResultQuerySetEmpty Check for Data Returned" -Type "CommandStart"
 $data = Get-childitem -File $outFile | select -property length 
 if ($data.length -lt 1)
 { Write-Log -Message "ResultQuerySetEmpty Check RawSource for Data Integrity" -Type "Exception-EmptyData"

}
else
{  Write-Log -Message "ResultQuerySet Not Empty and Passed Initial Data Integrity Check FileSize = $data" -Type "CommandEnd" }
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) 
}
}

function PbiPremiumDataCheckInt{
    param(
        [string]$DAXQuery,
        [string]$Auth
    )

    Try { Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandStart"
    Connect-PowerBIServiceAccount -Credential $credential
    }
    catch
    { Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
    Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandEnd"

    #$outFile = "$OutputFolder\$OutputName.csv"
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
        $result | Select-Object * -OutVariable Int
         #| Export-Csv -Path $outFile -NoTypeInformation -Force
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


function Get-ResultSize { 
param(
        [string]$FolderPath
    )

Try{
 Get-childitem -File   | select -property fullname, length | Export-csv -notypeinformation -path "C:\Program Files\WindowsPowerShell\Logs\ExportDataSizes.csv" -Append
}
catch
{ Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) 
}
}

function Get-CurrentLineNumber {
    $MyInvocation.ScriptLineNumber
}


function Get-CurrentFileName {
    $MyInvocation.ScriptName
}


function PbiDataSchemaExport{
    param(
          [string] $ServerName = 'https://analysis.windows.net/powerbi/api',
          [string] $DBName   = $datasetId,
          [string] $sqlCommand,
          [string] $outFile,
          [string] $auth
    )

 Try { Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandStart"
    Connect-PowerBIServiceAccount -Credential $credential
 }
    catch
    { Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName) }
    Write-Log -Message 'Connect-PowerBIServiceAccount -Credential $credential' -Type "CommandEnd"

    $auth = (Get-PowerBIAccessToken).Authorization
    $UserName = $credential.UserName
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
    Try { Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandStart"
    $datasets =
     Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json 
     }
     catch
{
	Write-Log -Message $_.Exception.Message -Type ($_.Exception.GetType().FullName)
}
Write-Log -Message 'Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json' -Type "CommandEnd"


    $premiumAppDataset = $datasets |        
        foreach-Object { $_.value } |
        Where-Object { $_.name -eq "$datasetName"} |
        Select-Object -First 1

    if($premiumAppDataset){
 Try {
    Write-Log -Message 'Creating Premium Capacity Metrics App OLEDB MSOLAP Connection to Extract Information' -Type "CommandStart"
        $region = ([System.Uri]$datasets.'@odata.context').Host
        $datasetId = $premiumAppDataset.id
        $cs = "Provider=MSOLAP;Data Source=https://analysis.windows.net/powerbi/api;;Initial Catalog=$datasetId;Location=https://$region/xmla?vs=sobe_wowvirtualserver&db=$datasetId;MDX Compatibility= 1; MDX Missing Member Mode= Error; Safety Options= 2; Update Isolation Level= 2; Locale Identifier= 1033;User Id = $UserName; Password=$PlainPassword"
        $connection = New-Object System.Data.OleDb.OleDbConnection $cs
        $connection.Open()
        $command = New-Object System.Data.OleDb.OleDbCommand -ArgumentList $sqlCommand, $connection
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
        $result | Select-Object * | Export-Csv -Path $outFile -NoTypeInformation -Force
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
   
