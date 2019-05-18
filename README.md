# NO.AzureDevopsTools
## Requirements
- Windows Powershell 5.1 or Powershell Core 6.1
- Azure CLI (2.0.64)
- Azure Devops extension for Azure CLI
- Azure Devops Migration Tools (7.5.66) from nkdAgility - https://github.com/nkdAgility/azure-devops-migration-tools

## Getting Started
A Powershell module to migrate/export/import Repos and WorkItems from TFS to Azure Devops

### How to install Azure CLI
Go to https://github.com/Azure/azure-cli

### How to install Azure Devops extension for Azure CLI
```
az extension add --name azure-devops
```

### Install from source
1. Download this repository
2. Go to the folder where the NO.AzureDevopsTools.psm1 is located and execute
```
Import-Module .\NO.AzureDevopsTools.psm1 
```

### Backup AzureDevops Instance to a local folder
1. Run Backup-AzDevOps  
```
Backup-AzureDevops -Token "nkpu5llfs2dqeatwytnfnojjfnxqlyy6ievrk45wjgt6u2d3pp4q" -Instance "[AzureDevopsOrg]" -Backuppath "x:\some\path"
```

### Backup AzureDevops Workitems to a local folder
1. Run Backup-AzDevOps  
```
Export-AzDevOpsWorkItem -Instance 'Fabrikam' -Token "PAT" -WorkItemType Epic -ExportAs Csv
```
### Functions 

Function        Add-Folder                                         0.0        NO.AzureDevopsTools
Function        Backup-AzDevOps                                    0.0        NO.AzureDevopsTools
Function        ConvertFrom-JsonToHashtable                        0.0        NO.AzureDevopsTools
Function        Export-AzDevOpsWorkItem                            0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsAuthenticatedGitUri                    0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsGitBranchesForRepo                     0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsGitContent                             0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsGitRepo                                0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsGitRepos                               0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsMigConfiguration                       0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsMigProject                             0.0        NO.AzureDevopsTools
Function        Get-AzDevopsProject                                0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsTeamProjectList                        0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsTfvcContent                            0.0        NO.AzureDevopsTools
Function        Get-AzDevOpsWorkItemTypes                          0.0        NO.AzureDevopsTools
Function        Get-WebClient                                      0.0        NO.AzureDevopsTools
Function        Install-AzCLI                                      0.0        NO.AzureDevopsTools
Function        Install-Nuget                                      0.0        NO.AzureDevopsTools
Function        Invoke-AzDevOpsGitMigration                        0.0        NO.AzureDevopsTools
Function        Invoke-AzDevOpsMigConfiguration                    0.0        NO.AzureDevopsTools
Function        Invoke-AzDevOpsMigPlan                             0.0        NO.AzureDevopsTools
Function        Invoke-AzDevopsProjectCheck                        0.0        NO.AzureDevopsTools
Function        Invoke-Menu                                        0.0        NO.AzureDevopsTools
Function        New-AzDevOpsMigConfiguration                       0.0        NO.AzureDevopsTools
Function        New-AzDevopsProject                                0.0        NO.AzureDevopsTools
Function        Save-AzDevOpsMigConfiguration                      0.0        NO.AzureDevopsTools
Function        Show-AzDevOpsMigProject                            0.0        NO.AzureDevopsTools