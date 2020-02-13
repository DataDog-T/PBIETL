$firstpath = "C:\Program Files\"
$dailyDateofData = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$attributeHierarchyStoragesSQL = 'Select * from $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES' #distinct data count for each column
$attributeHierarchies = 'Select * from $SYSTEM.TMSCHEMA_ATTRIBUTE_HIERARCHIES'  #ties hierarchy id to column
$columnStoragesSQL = 'SELECT * from $SYSTEM.TMSCHEMA_COLUMN_STORAGES' #has order by column, row count is inaccurate
$columnsSQL = 'Select * from $SYSTEM.TMSCHEMA_COLUMNS' #column name, ID for table, data type, category, hidden, iskey, isunique, is nullable, summarize by, expression for calc columns, hierarchy id, refresh time, modify time. source provider type, display folder
$dataSourcesSQL = 'SELECT * from $SYSTEM.TMSCHEMA_DATA_SOURCES' #connection string, account, impersonation mode, name
$hierarchiesSQL = 'Select * from $SYSTEM.TMSCHEMA_HIERARCHIES' #hierarchy name, display folder
$hierarchyStoragesSQL = 'Select * from $SYSTEM.TMSCHEMA_HIERARCHY_STORAGES' #user hierarchy definitions
$KpiSQL = 'Select * from $SYSTEM.TMSCHEMA_KPIS' #KPI definition
$levelsSQL = 'Select * from $SYSTEM.TMSCHEMA_LEVELS' #hierarchy level and model source column
$measuresSQL = 'Select * from $SYSTEM.TMSCHEMA_MEASURES' #measure and expressions, formatt, hidden, display folder
$modelSQL = 'Select * from $SYSTEM.TMSCHEMA_MODEL' #name of each model
$partitionsSQL = 'Select * from $SYSTEM.TMSCHEMA_PARTITIONS' #source queries for each table
$perspectiveColumnsSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_COLUMNS' #perspective table to perspective column maps
$perspectiveHierarchiesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_HIERARCHIES' # perspective table to hierarchy id map
$perspectiveMeasuresSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_MEASURES' # perspective table id to measure id map
$perspectiveTablesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVE_TABLES' # perspective to table map
$perspectivesSQL = 'Select * from $SYSTEM.TMSCHEMA_PERSPECTIVES' # list of perspectives
$relationshipsSQL = 'Select * from $SYSTEM.TMSCHEMA_RELATIONSHIPS' # active , type, crossfilter, table, colmn, cardinality
$rolemembershipsSQL = 'Select * from $SYSTEM.TMSCHEMA_ROLE_MEMBERSHIPS' # member name, ID, Modified time, role id,
$rolesSQL = 'Select * from $SYSTEM.TMSCHEMA_ROLES' # model, name, description, permission
$tablepermissionsSQL = 'Select * from $SYSTEM.TMSCHEMA_TABLE_PERMISSIONS' # role, rable, filter expression, modified time
$tablesSQL = 'Select * from $SYSTEM.TMSCHEMA_TABLES'  #tables, description, hidden, 
$catalogSQL = 'Select * from $SYSTEM.DBSCHEMA_CATALOGS' #Catalog name, description, compatibility level, type, database id, version
$schemasSQL = 'SELECT * FROM $System.DBSchema_Tables'
$Global:Logfilepath = ComputeNewValue "PBIPREMIUMDMVS"
$credential = (Get-Credential)
$datasetname = "Power BI Premium Capacity Metrics"
function PbiPremiumDataSchemaExport{
    param(
          [string] $ServerName = 'https://analysis.windows.net/powerbi/api',
          [string] $DBName   = $datasetId,
          [string] $sqlCommand,
          [string] $outFile,
          [string] $auth
    )

    Connect-PowerBIServiceAccount -credential $credential

    $auth = (Get-PowerBIAccessToken).Authorization
    $UserName = $credential.UserName
    $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))
    $datasets =
     Invoke-PowerBIRestMethod -Method Get -Url "https://api.powerbi.com/v1.0/myorg/datasets" | ConvertFrom-Json 
     


    $premiumAppDataset = $datasets |        
        foreach-Object { $_.value } |
        Where-Object { $_.name -eq "$datasetname"} |
        Select-Object -First 1

    if($premiumAppDataset){
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
    }
   
    PbiPremiumDataSchemaExport -sqlCommand $attributeHierarchyStoragesSQL  -outFile "$firstpath TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $attributeHierarchies  -outFile "$firstpath TMSCHEMA_ATTRIBUTE_HIERARCHIES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $columnStoragesSQL  -outFile "$firstpath TMSCHEMA_COLUMN_STORAGES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $columnsSQL  -outFile "$firstpath TMSCHEMA_COLUMNS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $dataSourcesSQL  -outFile "$firstpath TMSCHEMA_DATA_SOURCES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $hierarchiesSQL  -outFile "$firstpath TMSCHEMA_HIERARCHIES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $hierarchyStoragesSQL  -outFile "$firstpath TMSCHEMA_HIERARCHY_STORAGES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $KpiSQL  -outFile "$firstpath TMSCHEMA_KPIS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $levelsSQL  -outFile "$firstpath TMSCHEMA_LEVELS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $measuresSQL  -outFile "$firstpath TMSCHEMA_MEASURES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $modelSQL  -outFile "$firstpath TMSCHEMA_MODEL_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $partitionsSQL  -outFile "$firstpath TMSCHEMA_PARTITIONS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $perspectiveColumnsSQL -outFile "$firstpath TMSCHEMA_PERSPECTIVE_COLUMNS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $perspectiveHierarchiesSQL  -outFile "$firstpath TMSCHEMA_PERSPECTIVE_HIERARCHIES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $perspectiveMeasuresSQL -outFile "$firstpath TMSCHEMA_PERSPECTIVE_MEASURES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $perspectiveTablesSQL  -outFile "$firstpath TMSCHEMA_PERSPECTIVE_TABLES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $perspectivesSQL  -outFile "$firstpath TMSCHEMA_PERSPECTIVES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $relationshipsSQL  -outFile "$firstpath TMSCHEMA_RELATIONSHIPS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $rolemembershipsSQL  -outFile "$firstpath TMSCHEMA_ROLE_MEMBERSHIPS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $rolesSQL  -outFile "$firstpath TMSCHEMA_ROLES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $tablepermissionsSQL -outFile "$firstpath TMSCHEMA_TABLE_PERMISSIONS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $tablesSQL -outFile "$firstpath TMSCHEMA_TABLES_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $catalogSQL  -outFile "$firstpath DBSCHEMA_CATALOGS_$dailyDateofData.csv" 
    PbiPremiumDataSchemaExport -sqlCommand $schemasSQL  -outFile "$firstpath DBSCHEMA_TABLES_$dailyDateofData.csv" 
