
function Get-TfsBuildDefTasks
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
        [string]$TfsBldDefUrl
        # [Parameter(Mandatory)]
        # [string]$TfsCollection,
        # [Parameter(Mandatory)]
        # [string]$TfsProject,
        # [Parameter(Mandatory)]
        # [string]$BuildDefName,
        # [Parameter(Mandatory)]
        # [string]$BuildDefID
    )

    # Write-Host "`nGathering build task for : $BuildDefName (id=$BuildDefID)"
    # Write-Host "TfsCollection : $TfsCollection"
    # Write-Host "TfsProject : $TfsProject"

    Write-Host "URI= $wiqlUrl"
    $JsonResult = Invoke-RestMethod -UseDefaultCredentials -uri $TfsBldDefUrl -Method Get -ContentType 'application/Json'

    Write-Host "`nBuild tasks found = " $JsonResult.Build.Count
    if($JsonResult.Build.Count -gt 0)
    {
        Write-Host "Build tasks are:" 
        foreach($BuildTask in $JsonResult.Build)
        {
            Write-Host "`nTask Name = "$BuildTask.DisplayName
            if($BuildTask.DisplayName.ToLower().Contains("nuget"))
            {
                Write-Host "This needs an update!" -ForegroundColor Yellow
                #Write-Host "Configuration properties are:"
                foreach($Prop in $BuildTask.inputs.PSObject.Properties)
                {
                    Write-Host "Prop = " $Prop.Name
                    Write-Host "Value = " $Prop.Value
                }
            }
        }
    }
    Write-Host "`n############################ END for $BuildDefName (id=$BuildDefID) ##############################"
}

#Get-TfsBuildDefTasks -TfsCollection 'Binck' -TfsProject 'ToplineGit' -BuildDefName "blabla" -BuildDefID "11"
