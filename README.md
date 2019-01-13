# NO.AzureDevopsTools

## Requirements
- N/A

## Getting Started
A Powershell module to export TFS/GIT repos and workitems hosted on AzureDevops

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
