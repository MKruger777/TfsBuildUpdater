
function Update-TfsBuildDef
{
        <#
        .SYNOPSIS
        As part of certain release activities, it is nessasary to retrieve a set of Tfs work items.
        This function will retrieve the set on basis of the WIQL query passed to it.

        .PARAMETER WiqlQuery
        This is the query that will determine the workitems selected and returned to the caller.

        .EXAMPLE
        Get-TfsWorkItems "SELECT System.ID, System.Title from workitems"
    #>
    param(
        [Parameter(Mandatory)]
        [string]$TfsUri,        
        [Parameter(Mandatory)]
        [string]$TfsCollection
    )

    #Write-Host "`nStarting build definition update for:"
    #Write-Host "TfsCollection : $TfsCollection"
    #."D:\Dev\github\TfsBuildUpdater\release\Get-TfsProjects.ps1"  #work
    #."D:\Dev\github\TfsBuildUpdater\release\Get-TfsBuildDefinitions.ps1" #work

    ."C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\release\Get-TfsProjects.ps1"  #work
    ."C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\release\Get-TfsBuildDefinitions.ps1" #work

    $Script:base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "T800\morne","en55denwlgpdxw2t4bwkdq6apfbugspjaxbhjhrxvymex5tqb2aa")))
    #$JsonResult = Invoke-RestMethod -uri $wiqlUrl -Method Get -ContentType 'application/Json' -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    $TfsProjects = New-Object System.Collections.Generic.List[System.Object]
    $TfsProjects = Get-TfsProjects -TfsUri $TfsUri -TfsCollection $TfsCollection

    $wiqlUrl = "$TfsUri/$TfsCollection/_apis/projects?api-version=2.0"
    #$TfsProjects = Invoke-RestMethod -UseDefaultCredentials -uri $wiqlUrl -Method Get -ContentType 'application/Json'
    $TfsProjects = Invoke-RestMethod -UseDefaultCredentials -uri $wiqlUrl -Method Get -ContentType 'application/Json'-Headers @{Authorization=("Basic {0}" -f $Script:base64AuthInfo)}

    #Write-Host "Tfs projects found for collection $TfsCollection = " $TfsProjects.Count
    if($TfsProjects.Count -gt 0)
    {
        #Write-Host "`n$TfsCollection collecion projects are:" 
        foreach($TfsProj in $TfsProjects.value)
        {
            #Write-Host $TfsProj.name
            Get-TfsBuildDefinitions -TfsUri $TfsUri -TfsCollection $TfsCollection -TfsProject $TfsProj.name
        }
    }
}

#Update-TfsBuildDef -TfsUri "http://papptfs17.binckbank.nv:8080/tfs" -TfsCollection 'Binck'
Update-TfsBuildDef -TfsUri "http://t800:8080/tfs" -TfsCollection 'DefaultCollection'
