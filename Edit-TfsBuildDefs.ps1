
function Edit-TfsBuildDefs
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

    Write-Host "`nGathering Build definitions for:"
    Write-Host "TfsCollection : $TfsCollection"
    
    $TfsProjects = New-Object System.Collections.Generic.List[System.Object]

    
    .'C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\Get-TfsProjects.ps1'
    .'C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\Get-TfsBuildDefinitions.ps1'
    .'C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\Get-TfsBuildDefTasks.ps1'
    
    $TfsProjects = Get-TfsProjects -TfsUri $TfsUri -TfsCollection $TfsCollection

    #Gather all deinitions for this collection
    $TfsProjBuildDefs = foreach($TfsProject in $TfsProjects)
    {
        Write-Host $TfsProject
        Get-TfsBuildDefinitions -TfsUri $TfsUri -TfsCollection $TfsCollection -TfsProject $TfsProject
    }

    foreach($BuildDefinition in $TfsProjBuildDefs)
    {
        Write-Host "`n"
        Write-Host $BuildDefinition.Project.Name
        Write-Host $BuildDefinition.Name
        Write-Host $BuildDefinition.id
        Write-Host $BuildDefinition.Type
        if($BuildDefinition.Type -eq 'xaml')
        {
            Write-Host "XAML build are no longer supported! This build definition will be ignored - please investigate." -ForegroundColor Red
        }
        else
        {
            Get-TfsBuildDefTasks -TfsBldDefUrl $BuildDefinition.url #-TfsCollection $TfsCollection -TfsProject $BuildDefinition.Project.Name -BuildDefName $BuildDefinition.Name -BuildDefID $BuildDefinition.id    
        }
    }
}

Edit-TfsBuildDefs   -TfsUri "http://t800:8080/tfs/" -TfsCollection 'DefaultCollection'
