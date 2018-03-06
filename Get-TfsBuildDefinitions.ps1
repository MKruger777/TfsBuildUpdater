
function Get-TfsBuildDefinitions
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
        [string]$TfsCollection,
        [Parameter(Mandatory)]
        [string]$TfsProject
    )

    # Write-Host "`nGathering Build definitions for:"
    # Write-Host "TfsCollection : $TfsUri"
    # Write-Host "TfsCollection : $TfsCollection"
    # Write-Host "TfsProject : $TfsProject"

    $TfsProjBuildDefs = @()
    $wiqlUrl = "http://t800:8080/tfs/$TfsCollection/$TfsProject/_apis/build/definitions?api-version=2.0"
    $JsonResult = Invoke-RestMethod -UseDefaultCredentials -uri $wiqlUrl -Method Get -ContentType 'application/Json'

    Write-Host "Build definitions found = " $JsonResult.Count
    if($JsonResult.Count -gt 0)
    {
        foreach($BuildDef in $JsonResult.value)
        {
            $TfsProjBuildDefs += ($BuildDef)
        }
    }
    return $TfsProjBuildDefs
}

