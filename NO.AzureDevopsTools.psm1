

function ConvertFrom-JsonToHashtable {

    <# 
 .SYNOPSIS 
  Helper function to take a JSON string and turn it into a hashtable 
 .DESCRIPTION 
  The built in ConvertFrom-Json file produces as PSCustomObject that has case-insensitive keys. This means that 
  if the JSON string has different keys but of the same name, e.g. 'size' and 'Size' the comversion will fail. 
  Additionally to turn a PSCustomObject into a hashtable requires another function to perform the operation. 
  This function does all the work in step using the JavaScriptSerializer .NET class 
 #>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [AllowNull()]
        [string]
        $InputObject,

        [switch]
        # Switch to denote that the returning object should be case sensitive
        $casesensitive
    )

    # Perform a test to determine if the inputobject is null, if it is then return an empty hash table
    if ([String]::IsNullOrEmpty($InputObject)) {

        $dict = @{}

    } else {

        # load the required dll
        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
        $deserializer = New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer
        $deserializer.MaxJsonLength = [int]::MaxValue
        $dict = $deserializer.DeserializeObject($InputObject)

        # If the caseinsensitve is false then make the dictionary case insensitive
        if ($casesensitive -eq $false) {
            $dict = New-Object "System.Collections.Generic.Dictionary[System.String, System.Object]"($dict, [StringComparer]::OrdinalIgnoreCase)
        }

    }

    return $dict
}

function Get-WebClient
{
 param
    (
        [string]$Token,
        [string]$contentType = "application/json"
    )

    $wc = New-Object System.Net.WebClient
    $wc.Headers["Content-Type"] = $contentType
    
    $pair = ":${Token}"
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
    $base64 = [System.Convert]::ToBase64String($bytes)
    $wc.Headers.Add("Authorization","Basic $base64");
    $wc
}

function Get-AuthenticatedGitUri
{
    param
    (
        $uri,
        $token
    )

    $colonSlashSlash = "://";
    $protocol = $uri.substring(0, $uri.indexOf($colonSlashSlash))
    $address = $uri.substring($uri.indexOf($colonSlashSlash) + $colonSlashSlash.length)
    return $protocol + $colonSlashSlash + $token + "@" + $address
}

function Get-TeamProjectList
{
 param
    (
        $tfsUri ,
        $Token
    )
    
    write-host "Getting team project details for $tfsUri " -ForegroundColor Green

    $wc = Get-WebClient -Token $Token
        
    $uri = "$($tfsUri)/_apis/projects?api-version=1.0"

    $jsondata = $wc.DownloadString($uri) | ConvertFrom-Json 
    $jsondata.value | select-object -property @{Name="Name"; Expression = {$_.name}}
}

function Get-WorkItemTypes
{
 param
    (
        $Instance,
        $Project,
        $Token
    )
    
    write-host "Getting Work Item Types for Project $($Project) " -ForegroundColor Green

    $wc = Get-WebClient -Token $Token
        
    $uri = "https://$($Instance).visualstudio.com/$($Project)/_apis/wit/workitemtypes?api-version=4.1"

    if ($PSVersionTable.PSVersion.Major -eq "6" ) {
        $jsondata = $wc.DownloadString($uri) | ConvertFrom-Json -AsHashtable     
    }  
    else {
        $jsondata = $wc.DownloadString($uri) | ConvertFrom-JsonToHashtable
    }

    
    $jsondata.value | select-object -property @{Name="name"; Expression = {$_.name}}
}

function Get-GitRepo
{
    param
    (
        $name,
        $uri,
        $backuppath,
        $Token
    )

    write-host "Cloning Git Repo $name into $backuppath"
    Set-Location -Path $backuppath
    $fixeduri = Get-AuthenticatedGitUri -uri $uri -token $Token
    # Git send info to stderr it should not, redirecting it 
    & git clone $fixeduri 2>&1 | % { $_.ToString() }
}

function Get-TfvcContent
{
 param
    (
        $instance ,
        $Token,
        $projectname,
        $backuppath

    )

    Write-Host "  Downloading TFVC ZIP for project $projectname"
    
    $url = "https://$instance.visualstudio.com/$projectname/_apis/tfvc/Items?path=%24%2F$projectname&versionDescriptor%5BversionType%5D=5&%24format=zip&api-version=4.1-preview.1"
    $file = "$backuppath\TFVC-$projectname.zip"
    
    $wc = Get-WebClient -Token $Token
    try
    {
        $wc.DownloadFile($url,$file)
        Write-Host "    Finished TFVC content download"
    } catch 
    {
        Write-Host "    No TFVC content for project"
    }
}

function Get-GitBranchesForRepo
{
 param
    (
        $instance ,
        $Token,
        $projectname,
        $repo

    )

    Write-Host "  Getting branches repo $repo in project $projectname"
    
    $url = "https://$instance.visualstudio.com/$projectname/_apis/git/repositories/$repo/stats/branches?api-version=4.1"
    
    try
    {
        $wc = Get-WebClient -Token $Token
        $jsondata = $wc.DownloadString($url) | ConvertFrom-Json 
        $jsondata.value | select-object -property @{Name="Name"; Expression = {$_.name}}
    } catch
    {
          Write-Host "    No Repos for project"
    }
}

function Get-GitContent
{
 param
    (
        $instance ,
        $Token,
        $projectname,
        $repo,
        $backuppath,
        $branch

    )

    Write-Host "  Downloading GIT ZIP for branch $branch in repo $repo in project $projectname"
    
    # A branch name may have a / in it which is not a valid file name
    $fixedbranch = $branch -replace "/", "-" 
    $url = "https://$instance.visualstudio.com/$projectname/_apis/git/repositories/$repo/Items?path=%2F&versionDescriptor%5BversionOptions%5D=0&versionDescriptor%5BversionType%5D=0&versionDescriptor%5Bversion%5D=$branch&%24format=zip&api-version=4.1-preview.1"
    $file = "$backuppath\GIT-$projectname-$repo-$fixedbranch.zip"
    
    $wc = Get-WebClient -Token $Token
    $wc.DownloadFile($url,$file)
    Write-Host "    Finished GIT content download"
}


function Git-GetRepos
{
 param
    (
        $instance,
        $Token,
        $projectname
    )
    

    $url = "https://$instance.visualstudio.com/$projectname/_apis/git/repositories?api-version=4.1"
    $wc = Get-WebClient -Token $Token

    $jsondata = $wc.DownloadString($url) | ConvertFrom-Json 
    $jsondata.value | select-object -property @{Name="Name"; Expression = {$_.name}},@{Name="RemoteUrl"; Expression = {$_.remoteUrl}}

}


function Add-Folder
{
param
    (
        $Path
    )

    if ((Test-Path($Path)) -eq $false)
    {
        Write-Host "  Creating folder $Path"
        New-Item -ItemType directory -Path $Path -force | Out-Null
    } else 
    {
        Write-Host "  Cleaning folder $Path"
        Remove-Item "$Path" -Force -Recurse
    }

}


function Backup-AzureDevops
{
param
    (
        [Parameter(Mandatory = $true)]
        [string]$Token,

        [Parameter(Mandatory = $true)]
        [string]$instance,

        [Parameter(Mandatory = $true)]
        [string]$backuppath,

        [Parameter(Mandatory = $False)]
        [switch]$BackupWorkItems
    )
    $projects = Get-TeamProjectList -Token $Token -tfsUri "https://$instance.visualstudio.com"
    
    $instancepath = Join-Path -Path $backuppath -ChildPath $instance
    Add-Folder -Path $instancepath

    foreach ($project in $projects)
    {
        $name = $project.Name
        Write-Host "Procesing project $name" -ForegroundColor Green

        if ($BackupWorkItems){
            $workitemtypes = Get-WorkItemTypes -Token $Token -Instance $instance -Project $project.Name
            $workitemtypes | Format-Table
        }
        
        $projectpath = Join-Path -Path $instancepath -ChildPath $name
        Add-Folder -Path $projectpath
    
        $repos = Git-GetRepos -instance $instance -Token $Token -projectname $name 

        if ($repos.count -eq 0)
        {
            Write-Host "    No GIT content for project"
        } else
        {
            foreach ($repo in $repos)
            {
                Get-GitRepo -name $repo.Name -uri $repo.remoteurl -backuppath $projectpath -Token $Token
                    
                # If you wish to get the repo's as simple ZIPs
                # $branches = Get-GitBranchesForRepo -instance $instance -Token $Token -projectname $name -repo $repo.Name
                # foreach ($branch in $branches)
                # {
                #    Get-GitContent -instance $instance -Token $Token -projectname $name -Path $projectpath -repo $repo.Name -branch $branch.Name
                # }
            }
        }
        
        Get-TfvcContent -instance $instance -Token $Token -projectname $name -Path $projectpath 
    }

    Write-Host "`n"
}

function Export-VSTSWorkItem  
{  
<#  
.SYNOPSIS  
    A PowerShell function to export Visual Studio Team Servies work items.   
.DESCRIPTION  
    A PowerShell function to export Visual Studio Team Servies work items.
.EXAMPLE  
    PS C:\> Export-VSTSWorkItem -Instance 'Fabrikam" -Token "PAT"  
    Export all Workitems of any type.  
.EXAMPLE  
    PS C:\> Export-VSTSWorkItem -Instance 'Fabrikam' -Token "PAT" -WorkItemType Bug  
    Export Bug Workitems.  
.EXAMPLE  
    PS C:\> Export-VSTSWorkItem -Instance 'Fabrikam' -Token "PAT" -WorkItemType Task  
    Export Task Workitems.    
.EXAMPLE  
    PS C:\> Export-VSTSWorkItem -Instance 'Fabrikam' -Token "PAT" -WorkItemType Epic -ExportAs csv  
    Exports as csv 
.NOTES  
     
#>  
    [CmdletBinding()]  
    param (  
        # AzureDevops Organisation Name
        [Parameter(Mandatory)]  
        [string] $Instance,  
 
        # Personal Access Token  
        [Parameter(Mandatory)]  
        [string] $Token,  
 
        # Opt the Work Items Type  
        [Parameter()]  
        [ValidateSet("Bug", "Task", "Epic", "Feature", "All")]  
        [string] $WorkItemType = "All",

        [Parameter()]
        [string[]] $WorkItemFields = @('System.Id','System.Title','System.AssignedTo','System.State','System.CreatedBy','System.WorkItemType'),    
 
        # Export in your favorite format.  
        [Parameter()]  
        [ValidateSet("Csv", "HTML", "JSON", "FancyHTML")]
        [string] $ExportAs
    )  
      
    begin  
    {  
    }  
      
    process  
    {  
        $Authentication = (":$Token")  
        $Authentication = [System.Text.Encoding]::ASCII.GetBytes($Authentication)  
        $Authentication = [System.Convert]::ToBase64String($Authentication)  
        switch ($WorkItemType)  
        {  
            "Bug"  
            {  
                $Body = @{  
                    Query = "Select * from WorkItems WHERE [System.WorkItemType] = '$WorkItemType'"  
                } | ConvertTo-Json  
            }  
            "Task"  
            {  
                $Body = @{  
                    Query = "Select * from WorkItems WHERE [System.WorkItemType] = '$WorkItemType'"  
                } | ConvertTo-Json  
            }  
            "Epic"  
            {  
                $Body = @{  
                    Query = "Select * from WorkItems WHERE [System.WorkItemType] = '$WorkItemType'"  
                } | ConvertTo-Json  
            }  
            "Feature"  
            {  
                $Body = @{  
                    Query = "Select * from WorkItems WHERE [System.WorkItemType] = '$WorkItemType'"  
                } | ConvertTo-Json  
            }
            "All"
            {  
                $Body = @{  
                    Query = "Select * from WorkItems"  
                } | ConvertTo-Json  
            }
        }  
        $RestParams = @{  
            Uri         = "https://$Instance.visualstudio.com/DefaultCollection/_apis/wit/wiql?api-version=1.0"  
            Method      = "Post"  
            ContentType = "application/json"  
            Headers     = @{  
                Authorization = ("Basic {0}" -f $Authentication)  
            }  
            Body        = $Body  
        }  
        try  
        {  
            $Id = (Invoke-RestMethod @RestParams).workitems.id -join ","  
            if (-not ([string]::IsNullOrEmpty($Id)))  
            {  
                if(-not($WorkItemFields -eq $null)){
                    $Fields = @($WorkItemFields) -join ","    
                }
                else {
                    throw 'Something went wrong'
                }
                $RestParams["Uri"] = "https://$Instance.visualstudio.com/DefaultCollection/_apis/wit/WorkItems?ids=$Id&fields=$Fields&api-version=1"  
                $RestParams["Method"] = "Get"  
                $RestParams.Remove("Body")  
                $Result = Invoke-RestMethod @RestParams  
                if (! $PSBoundParameters['ExportAs'])  
                {  
                    ($Result.value.fields)  
                }  
            }  
            else  
            {  
                Write-Warning "No Items are available in $WorkItemType"  
            }  
          
            switch ($ExportAs)  
            {  
                'csv'  
                {  
                    $Result.value.fields | Export-Csv ".\$($WorkItemType)-WorkItems.csv" -NoTypeInformation   
                }  
                'HTML'  
                {  
                    $Result.value.fields | Export-Csv .\$WorkItemType.html -NoTypeInformation   
                } 
                'JSON'  
                {  
                    $Result.value.fields | ConvertTo-Json -Depth 50 | Out-File ".\$($WorkItemType)-WorkItems.json"
                }  
                'FancyHTML'  
                {  
                    Add-Content  ".\style.CSS"  -Value " body {   
                    font-family:Calibri;   
                    font-size:10pt;   
                    }   
                    th {    
                    background-color:black;   
                    color:white;   
                    }   
                    td {   
                    background-color:#19fff0;   
                    color:black;}"  
                    $Result.value.fields | ConvertTo-Html -CssUri .\Style.css | Out-File .\Report.html  
                }  
            }  
        }  
        catch  
        {
            Write-host $_.Exception.Message -ForegroundColor Red  
        }  
    }  
      
    end  
    {  
    }  
}  