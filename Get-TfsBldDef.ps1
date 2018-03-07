
function Get-TfsBldDef
{
        <#
        .SYNOPSIS
        
        It seems possible to update the PSCustom object that was returned  
        The plan is thus:
        1) Get the build def
        2) Scan it to see if there is somthing that needs updating
        3) Updat the build definition as required witin the PSObject - plain .(dot) notation
        this seems to work fine
        4) Then convert to JSon 
        5) Do the PUT passing the JSon as body 
        6) Check the return code
        7) Log our action for audit purposes
        

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
    #$wiqlUrl = "https://krugers.visualstudio.com/Build-Discovery/_apis/build/definitions/1?api-version=2.0"  #WORKS! - VSTS
    $wiqlUrl = "http://t800:8080/tfs/DefaultCollection/Discovery/_apis/build/definitions/2?api-version=2.0"   #WORKS! - T800

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "T800\morne","en55denwlgpdxw2t4bwkdq6apfbugspjaxbhjhrxvymex5tqb2aa")))

    #This call returns a powershell custom object...
    $JsonResult = Invoke-RestMethod -uri $wiqlUrl -Method Get -ContentType 'application/Json' -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
    Write-Host "Build name: " $JsonResult.name
    Write-Host "Build ID: " $JsonResult.ID
    Write-Host "Build Type: " $JsonResult.type
    
    #TODO - Ignore XAML builds and log it!
    
    #Search for your stuff and update if required
    foreach($BldTask in $JsonResult.Build)
    {
        Write-Host "`nbldtask:" $BldTask.DisplayName.ToLower() 
        if($BldTask.DisplayName.ToLower().Contains("nuget"))
        {
            #Write-Host "Build display name: " $BldTask.DisplayName
            #Write-Host "Configuration properties are:"
            foreach($Prop in $BldTask.inputs.PSObject.Properties)
            {
                if($Prop.name.ToLower().Contains("nugetversion"))
                {
                    Write-Host "NuGet version found!" -ForegroundColor Yellow
                    Write-Host "Property = " $Prop.Name
                    Write-Host "Value = " $Prop.Value
                }                
            }
        }
        
        #now check the Vstest versions stuff
        if($BldTask.DisplayName.ToLower().Contains("vstest - testassemblies"))
        {
            if($BldTask.Task.VersionSpec -eq "2.*")
            {
                Write-Host "VsTest versionspec 2 detected! " -ForegroundColor Yellow      
            }
        }

        #now check the Vstest versions stuff
        if($BldTask.DisplayName.ToLower().Contains("npm"))
        {
            foreach($Prop in $BldTask.inputs.PSObject.Properties)
            {
                if($Prop.name.ToLower().Contains("command"))
                {
                    Write-Host "Npm command found!" -ForegroundColor Yellow
                    Write-Host "Property = " $Prop.Name
                    Write-Host "Value = " $Prop.Value
                }                
            }
        }
    }


    #temp test
    $JsonResult.name += " Hans-Peter"
    # Now lets send the sucker back and update the definition


}

function  Get-TfsCollProjects
{   
    param(
        [Parameter(Mandatory)]
        [string]$TfsUri,        
        [Parameter(Mandatory)]
        [string]$TfsCollection
    )

    ."C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\Get-TfsProjects.ps1"
    


    # Write-Host "Tfs projects found for collection $TfsCollection = " $JsonResult.Count
    # if($JsonResult.Count -gt 0)
    # {
    #     Write-Host "`nTfs projects are:" 
    #     foreach($TfsProj in $JsonResult.value)
    #     {
    #         #Write-Host $TfsProj.name
    #         $TfsProjects.Add($TfsProj.name);
    #     }
    # }
    # Write-Host "`n############################ END for $TfsCollection  ##############################"
    return $TfsProjects (OptionalParameters) 
}

Get-TfsBldDef -TfsUri "dfgfdgdf" -TfsCollection 'Binck'
