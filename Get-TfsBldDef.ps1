
function Get-TfsBldDef
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
    #$wiqlUrl = "$TfsUri/$TfsCollection/_apis/projects?api-version=1.0"
    #$wiqlUrl = "https://krugers.visualstudio.com/Build-Discovery/_apis/build/definitions?api-version=2.0"
    $wiqlUrl = "https://krugers.visualstudio.com/Build-Discovery/_apis/build/definitions/1?api-version=2.0"  # WOOOORKS!!!!!
    #https://fabrikam-fiber-inc.visualstudio.com/DefaultCollection/Fabrikam-Fiber-Git/_apis/build/definitions/3?api-version=1.0

    #$secpasswd = ConvertTo-SecureString "H@nspeterHeidi2" -AsPlainText -Force
    #$mycreds = New-Object System.Management.Automation.PSCredential ("morne.kruger@outlook.com", $secpasswd)


    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "morne.kruger@outlook.com","2hrvgyuonfsffwpq4anfcsvzqp2wxpxyjurvvxtgj34y26dpukda")))
    $JsonResult = Invoke-RestMethod -uri $wiqlUrl -Method Get -ContentType 'application/Json' -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

    Write-Host $definitionsOverviewResponse.Content


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

Get-TfsBldDef -TfsUri "dfgfdgdf" -TfsCollection 'Binck'
