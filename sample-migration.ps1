function Start-Migration {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $False)] [string] $vstssyncHome = "e:\vstssync-7.5.66",
        [parameter(Mandatory = $False)] [bool] $SkipProjectCreation = $false,
        [parameter(Mandatory = $False)] [bool] $MigrateGit = $false,
        [parameter(Mandatory = $False)] [bool] $CloneRepo = $true,
        [parameter(Mandatory = $False)] [uri] $SourceOrgUri,
        [parameter(Mandatory = $False)] [string] $SourceProject,
        [parameter(Mandatory = $False)] [uri] $DestinationOrgUri,
        [parameter(Mandatory = $False)] [string] $DestinationProject,
        [parameter(Mandatory = $False)] [string] $Process
            
    )
    Set-Location -Path $PSScriptRoot
   
    [uri] $SourceProjectUri = "$($SourceOrgUri)/_git/$($SourceProject)"
    [uri] $DestinationProjectUri = "$($DestinationOrgUri)/_git/$($DestinationProject)"
    $ProjectExist = Invoke-AzDevopsProjectCheck -OrgUri $DestinationOrgUri -Project $DestinationProject
    $env:VSTSSyncHome = $vstssyncHome
    
    if (-not($ProjectExist)) {        
        New-AzDevopsProject -OrgUri $DestinationOrgUri -Project $DestinationProject -Process $Process
    }
    
    if ($MigrateGit) {
        Invoke-GitMigration -SourceRepo $SourceProjectUri -DestinationRepo $DestinationProjectUri
    }   
    
    Invoke-AzDevOpsMigConfiguration -Configuration .\Configuration.json
    Invoke-AzDevOpsMigConfiguration -Configuration .\migrate-wits.json -Label "Batch01" -QueryBit "AND [System.CreatedDate] >= '01-01-2016' AND [System.CreatedDate] <= '31-12-2016' AND [System.WorkItemType] IN ('Shared Steps', 'Product Backlog Item', 'Shared Parameter', 'Test Case', 'Task', 'Feature', 'Epic', 'Bug')" -Confirm $false  
}

Get-Module NO.AzureDevopsTools|Remove-Module
Import-Module .\NO.AzureDevopsTools.psd1

Start-Migration -vstssyncHome D:\vstssync-7.5.66 -MigrateGit $false