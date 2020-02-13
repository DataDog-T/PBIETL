Import-Module PBIPREMIUM
$firstpath = "C:\Program Files\"
$dailyDateofData = (get-date).ToString("yyyMMdd") | foreach {$_ -replace ":", "."}
$Global:Logfilepath = ComputeNewValue "PBIPREMIUMDMVS"
$Global:datasetName = ComputeNewDatasetName -datasetName "Power BI Premium Capacity Metrics"

   
    PbiDataSchemaExport -sqlCommand $attributeHierarchyStoragesSQL  -outFile ("$firstpath" + "TMSCHEMA_ATTRIBUTE_HIERARCHY_STORAGES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $attributeHierarchies  -outFile ("$firstpath" + "TMSCHEMA_ATTRIBUTE_HIERARCHIES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $columnStoragesSQL  -outFile ("$firstpath" + "TMSCHEMA_COLUMN_STORAGES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $columnsSQL  -outFile ("$firstpath" + "TMSCHEMA_COLUMNS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $dataSourcesSQL  -outFile ("$firstpath" + "TMSCHEMA_DATA_SOURCES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $hierarchiesSQL  -outFile ("$firstpath" + "TMSCHEMA_HIERARCHIES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $hierarchyStoragesSQL  -outFile ("$firstpath" + "TMSCHEMA_HIERARCHY_STORAGES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $KpiSQL  -outFile ("$firstpath" + "TMSCHEMA_KPIS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $levelsSQL  -outFile ("$firstpath" + "TMSCHEMA_LEVELS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $measuresSQL  -outFile ("$firstpath" + "TMSCHEMA_MEASURES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $modelSQL  -outFile ("$firstpath" + "TMSCHEMA_MODEL_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $partitionsSQL  -outFile ("$firstpath" + "TMSCHEMA_PARTITIONS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $perspectiveColumnsSQL -outFile ("$firstpath" + "TMSCHEMA_PERSPECTIVE_COLUMNS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $perspectiveHierarchiesSQL  -outFile ("$firstpath" + "TMSCHEMA_PERSPECTIVE_HIERARCHIES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $perspectiveMeasuresSQL -outFile ("$firstpath" + "TMSCHEMA_PERSPECTIVE_MEASURES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $perspectiveTablesSQL  -outFile ("$firstpath" + "TMSCHEMA_PERSPECTIVE_TABLES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $perspectivesSQL  -outFile ("$firstpath" + "TMSCHEMA_PERSPECTIVES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $relationshipsSQL  -outFile ("$firstpath" + "TMSCHEMA_RELATIONSHIPS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $rolemembershipsSQL  -outFile ("$firstpath" + "TMSCHEMA_ROLE_MEMBERSHIPS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $rolesSQL  -outFile ("$firstpath" + "TMSCHEMA_ROLES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $tablepermissionsSQL -outFile ("$firstpath" + "TMSCHEMA_TABLE_PERMISSIONS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $tablesSQL -outFile ("$firstpath" + "TMSCHEMA_TABLES_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $catalogSQL  -outFile ("$firstpath" + "DBSCHEMA_CATALOGS_$dailyDateofData.csv")
    PbiDataSchemaExport -sqlCommand $schemasSQL  -outFile ("$firstpath" + "DBSCHEMA_TABLES_$dailyDateofData.csv")
