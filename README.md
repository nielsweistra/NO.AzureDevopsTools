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
1. Run Backup-AzureDevops  
```
Backup-AzureDevops -Token "nkpu5llfs2dqeatwytnfnojjfnxqlyy6ievrk45wjgt6u2d3pp4q" -Instance "[AzureDevopsOrg]" -Backuppath "x:\some\path"
```

### Backup AzureDevops Workitems to a local folder
1. Run Backup-AzureDevops  
```
Export-VSTSWorkItem -Instance 'Fabrikam' -Token "PAT" -WorkItemType Epic -ExportAs Csv
```
