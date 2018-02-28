
function Get-TfsProjects
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

    Write-Host "`nGathering Tfs projects for:"
    Write-Host "TfsCollection : $TfsCollection"

    $TfsProjects = New-Object System.Collections.Generic.List[System.Object]
    $wiqlUrl = "$TfsUri/$TfsCollection/_apis/projects?api-version=1.0"
    $JsonResult = Invoke-RestMethod -UseDefaultCredentials -uri $wiqlUrl -Method Get -ContentType 'application/Json'

    Write-Host "Tfs projects found for collection $TfsCollection = " $JsonResult.Count
    if($JsonResult.Count -gt 0)
    {
        Write-Host "`nTfs projects are:" 
        foreach($TfsProj in $JsonResult.value)
        {
            #Write-Host $TfsProj.name
            $TfsProjects.Add($TfsProj.name);
        }
    }
    Write-Host "`n############################ END for $TfsCollection  ##############################"
    return $TfsProjects
}

#Get-TfsProjects -TfsCollection 'Binck'
