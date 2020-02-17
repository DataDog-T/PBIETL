$principal = New-ScheduledTaskPrincipal -UserID "na\Admin" -LogonType ServiceAccount -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel
#Times Variables
$dashboardTilesTime = New-ScheduledTaskTrigger -Daily -At 7AM
$activitesTime = New-ScheduledTaskTrigger -Daily -At 10AM
$dashboardsTime = New-ScheduledTaskTrigger -Daily -At 6:30AM
$dataflowsTime = New-ScheduledTaskTrigger -Daily -At 6AM
$datasetsDatasourcesTime = New-ScheduledTaskTrigger -Daily -At 1AM
$dataflowDatasourcesTime = New-ScheduledTaskTrigger -Daily -At 7AM
$datasetDataflowsTime = New-ScheduledTaskTrigger -Daily -At 9AM
$datasetsTime = New-ScheduledTaskTrigger -Daily -At 6:10AM
$dqlcTime = New-ScheduledTaskTrigger -Daily -At 10:05PM
$premiumDatasetTimeStampTime = New-ScheduledTaskTrigger -Daily -At 10:15PM
$actionTime = New-ScheduledTaskTrigger -Daily -At 9:25PM
$premiumAiTime = New-ScheduledTaskTrigger -Daily -At 10:38PM
$cleanupPBITime = New-ScheduledTaskTrigger -Daily -At 12:00AM
$premiumDataflowMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:18PM
$DatasetImportsTime = New-ScheduledTaskTrigger -Daily -At 9AM
$premiumDatasetsTime = New-ScheduledTaskTrigger -Daily -At 9:03PM
$DependentDataflowsTime = New-ScheduledTaskTrigger -Daily -At 8:00AM
$PremiumDataflowsTime = New-ScheduledTaskTrigger -Daily -At 10:13PM
$PremiumCapacitiesTime = New-ScheduledTaskTrigger -Daily -At 10:15PM
$PremiumPaginatedReportsTime = New-ScheduledTaskTrigger -Daily -At 10:05PM
$PremiumPaginatedReportOperationsTime = New-ScheduledTaskTrigger -Daily -At 10:10PM
$PremiumDatasetSizesTime = New-ScheduledTaskTrigger -Daily -At 10:42PM
$PremiumQueryPoolJobQueueLengthTime = New-ScheduledTaskTrigger -Daily -At 10:21PM
$PremiumEvictionMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:52PM
$PremiumRefreshMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:47PM
$PremiumInactiveMemoryMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:32PM
$PremiumQueryMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:59PM
$PremiumRefreshThrottlingMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:26PM
$PremiumRefreshWaitTimes = New-ScheduledTaskTrigger -Daily -At 11:05PM
$PowerBIReportsTime = New-ScheduledTaskTrigger -Daily -At 8:45AM
$PremiumSystemMetricsTime = New-ScheduledTaskTrigger -Daily -At 10:18PM
$PremiumWorkspacesTime = New-ScheduledTaskTrigger -Daily -At 10:33PM
$PremiumWorkloadStatusTime = New-ScheduledTaskTrigger -Daily -At 11:15PM
$PremiumWorkloadResourceSettingsTime = New-ScheduledTaskTrigger -Daily -At 11:20PM
$PowerBIWorkspacesTime = New-ScheduledTaskTrigger -Daily -At 7:00AM
$WorkspaceDashboardsTime = New-ScheduledTaskTrigger -Daily -At 7:30AM
$WorkspaceDatasetsTime = New-ScheduledTaskTrigger -Daily -At 8:00AM
$WorkspaceDataflowsTime = New-ScheduledTaskTrigger -Daily -At 7:15AM
$WorkspaceReportsTime = New-ScheduledTaskTrigger -Daily -At 8:30AM

#Action Variables
$dashboardTilesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Dashboard_Tiles.ps1"""
$activitesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Activities.ps1"""
$dashboardsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Dashboards.ps1"""
$dataflowsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_DataflowDevelopers.ps1"""
$datasetsDatasourcesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_DatasetDatasources.ps1"""
$dataflowDatasourcesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_DataflowDatasources.ps1"""
$datasetDataflowsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Dataset_Dataflows.ps1"""
$datasetsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_DatasetDevelopers.ps1"""
$dqlcAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_DQLCMetrics.ps1"""
$premiumDatasetTimeStampAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_DatasetTimestamps.ps1"""
$actionAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumActionCenter.ps1"""
$premiumAiAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumAI.ps1"""
$cleanupPBIAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\CleanUp\DailyCleanUpandLog.ps1"""
$premiumDataflowMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumDataFlowOperations.ps1"""
$DatasetImportsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Dataset_Imports.ps1"""
$premiumDatasetsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumDatasets.ps1"""
$DependentDataflowsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_DependentDataflows.ps1"""
$PremiumDataflowsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumDataflows.ps1"""
$PremiumCapacitiesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumCapacities.ps1"""
$PremiumPaginatedReportsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumPaginatedReports.ps1"""
$PremiumPaginatedReportOperationsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumPaginatedReportOperations.ps1"""
$PremiumDatasetSizesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumDatasetSizes.ps1"""
$PremiumQueryPoolJobQueueLengthAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumQueryPoolJobQueueLength.ps1"""
$PremiumEvictionMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumEvictionMetrics.ps1"""
$PremiumRefreshMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumRefreshMetrics.ps1"""
$PremiumInactiveMemoryMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumInactiveMemoryMetrics.ps1"""
$PremiumQueryMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumQueryMetrics.ps1"""
$PremiumRefreshThrottlingMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumRefreshThrottlingMetrics.ps1"""
$PremiumRefreshWaitActions = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumRefreshWaitTimes.ps1"""
$PowerBIReportsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Reports.ps1"""
$PremiumSystemMetricsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumSystemMetrics.ps1"""
$PremiumWorkspacesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumWorkspaces.ps1"""
$PremiumWorkloadStatusAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumWorkloadStatus.ps1"""
$PremiumWorkloadResourceSettingsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIPREMIUM\ETL_DailyFile_PowerBI_PremiumWorkloadResourceSettings.ps1"""
$PowerBIWorkspacesAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Workspaces.ps1"""
$WorkspaceDashboardsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Workspace_Dashboards.ps1"""
$WorkspaceDatasetsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Workspace_Datasets.ps1"""
$WorkspaceDataflowsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Workspace_Dataflows.ps1"""
$WorkspaceReportsAction = New-ScheduledTaskAction -Execute "powershell" -Argument "-File ""C:\Program Files\WindowsPowerShell\Scripts\PBIAPI\ETL_DailyFile_PowerBI_Workspace_Reports.ps1"""





#RegisterTasks
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Dashboard_Tiles" -Trigger $dashboardTilesTime -Action $dashboardTilesAction  -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Activities" -Trigger $activitesTime -Action $activitesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Dashboards" -Trigger $dashboardsTime -Action $dashboardsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DataflowDeveloper" -Trigger $dataflowsTime -Action $dataflowsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DatasetDatasources" -Trigger $datasetsDatasourcesTime -Action $datasetsDatasourcesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DataflowDatasources" -Trigger $dataflowDatasourcesTime -Action $dataflowDatasourcesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Dataset_Dataflows" -Trigger $datasetDataflowsTime -Action $datasetDataflowsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DatasetDevelopers" -Trigger $datasetsTime -Action $datasetsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DQLCMetrics" -Trigger $dqlcTime -Action $dqlcAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DatasetTimestamps" -Trigger $premiumDatasetTimeStampTime -Action $premiumDatasetTimeStampAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumActionCenter" -Trigger $actionTime -Action $actionAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumAI" -Trigger $premiumAiTime -Action $premiumAiAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_CleanUp_Log_PBI" -Trigger $cleanupPBITime -Action $cleanupPBIAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumDataFlowOperations" -Trigger $premiumDataflowMetricsTime -Action $premiumDataflowMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Dataset_Imports" -Trigger $DatasetImportsTime -Action $DatasetImportsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumDatasets" -Trigger $premiumDatasetsTime -Action $premiumDatasetsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_DependentDataflows" -Trigger $DependentDataflowsTime -Action $DependentDataflowsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumDataflows" -Trigger $PremiumDataflowsTime -Action $PremiumDataflowsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumCapacities"-Trigger $PremiumCapacitiesTime -Action $PremiumCapacitiesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumPaginatedReports" -Trigger $PremiumPaginatedReportsTime -Action $PremiumPaginatedReportsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumPaginatedReportOperations"-Trigger $PremiumPaginatedReportOperationsTime -Action $PremiumPaginatedReportOperationsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumDatasetSizes" -Trigger $PremiumDatasetSizesTime -Action $PremiumDatasetSizesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumQueryPoolJobQueueLength" -Trigger $PremiumQueryPoolJobQueueLengthTime -Action $PremiumQueryPoolJobQueueLengthAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumEvictionMetrics" -Trigger $PremiumEvictionMetricsTime -Action $PremiumEvictionMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumRefreshMetrics" -Trigger $PremiumRefreshMetricsTime -Action $PremiumRefreshMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumInactiveMemoryMetrics" -Trigger $PremiumInactiveMemoryMetricsTime -Action $PremiumInactiveMemoryMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumQueryMetrics" -Trigger $PremiumQueryMetricsTime -Action $PremiumQueryMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumRefreshThrottlingMetrics" -Trigger $PremiumRefreshThrottlingMetricsTime -Action $PremiumRefreshThrottlingMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumRefreshWaitTimes" -Trigger $PremiumRefreshWaitTimes -Action $PremiumRefreshWaitActions -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Reports" -Trigger $PowerBIReportsTime -Action $PowerBIReportsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumSystemMetrics" -Trigger $PremiumSystemMetricsTime -Action $PremiumSystemMetricsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumWorkspaces" -Trigger $PremiumWorkspacesTime -Action $PremiumWorkspacesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumWorkloadStatus" -Trigger $PremiumWorkloadStatusTime -Action $PremiumWorkloadStatusAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_PremiumWorkloadResourceSettings" -Trigger $PremiumWorkloadResourceSettingsTime -Action $PremiumWorkloadResourceSettingsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Workspaces" -Trigger $PowerBIWorkspacesTime -Action $PowerBIWorkspacesAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Workspace_Dashboards" -Trigger $WorkspaceDashboardsTime -Action $WorkspaceDashboardsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Workspace_Datasets" -Trigger $WorkspaceDatasetsTime -Action $WorkspaceDatasetsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Workspace_Dataflows" -Trigger $WorkspaceDataflowsTime -Action $WorkspaceDataflowsAction -Principal $principal -Settings $settings
Register-ScheduledTask -TaskName "ETL_DailyFile_PowerBI_Workspace_Reports" -Trigger $WorkspaceReportsTime -Action $WorkspaceReportsAction -Principal $principal -Settings $settings






