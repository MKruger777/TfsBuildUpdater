
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

    #$TfsProjBuildDefs = @()
    #returns the all build definitions for a project (limited - NOT all details)
    $Url = "$TfsUri/$TfsCollection/$TfsProject/_apis/build/definitions?api-version=2.0"
    $BuildDefs = Invoke-RestMethod -UseDefaultCredentials -uri $Url -Method Get -ContentType 'application/Json'

    Write-Host "`nBuild definitions found for $TfsProject = " $BuildDefs.Count
    if($BuildDefs.Count -gt 0)
    {
        foreach($BuildDef in $BuildDefs.value)
        {
            #$TfsProjBuildDefs += ($BuildDef)
            Set-Changes  -TfsUri $TfsUri -TfsCollection $TfsCollection -TfsProject $TfsProj.name -TfsBuildDefId $BuildDef.id
        }
    }
    else 
    {
        Write-Host "Zero Build definitions found for $TfsProject !" -ForegroundColor Yellow
    }
}

function Set-Changes 
{
    param(
        [Parameter(Mandatory)]
        [string]$TfsUri,        
        [Parameter(Mandatory)]
        [string]$TfsCollection,
        [Parameter(Mandatory)]
        [string]$TfsProject,
        [Parameter(Mandatory)]
        [string]$TfsBuildDefId      
    )

    #returns the complete build definitions a Build ID 
    $Url = "$TfsUri/$TfsCollection/$TfsProject/_apis/build/definitions/$($TfsBuildDefId)?api-version=2.0"    
    $TfsBuildDef = Invoke-RestMethod -uri $Url -Method Get -UseDefaultCredentials -ContentType 'application/Json'  
    Write-Host "`n-------------------------------------------------------------"
    Write-Host "Build name: " $TfsBuildDef.name
    Write-Host "Build ID: " $TfsBuildDef.ID
    Write-Host "Build Type: " $TfsBuildDef.type
    
    #Ignore XAML builds and log it!
    if($TfsBuildDef.type -eq 'xaml')
    {
        Write-Host "XAML build are no longer supported! This build definition will be ignored - please investigate." -ForegroundColor Red
    }
    else
    {

        if($TfsBuildDef.name -eq "Sonar.Binck.Systems.ACA")
        {
            Write-Host "found!"
        }

        #Search for your stuff and update if required
        foreach($BldTask in $TfsBuildDef.Build)
        {
            Write-Host "`nbldtask:" $BldTask.DisplayName.ToLower() 
            if($BldTask.refName.ToLower().Contains("nugetinstaller"))
            {
                #Write-Host "Build display name: " $BldTask.DisplayName
                #Write-Host "Configuration properties are:"
                foreach($Prop in $BldTask.inputs.PSObject.Properties)
                {
                    if($Prop.name.ToLower().Contains("nugetversion"))
                    {
                        if(Find-NugetVersion ($BldTask.inputs.PSObject.Properties) -eq $false)
                        {
                            Write-Host "No nugetversion property found!" -ForegroundColor Yellow
                            break
                        }
                        if(($Prop.name.ToLower() -eq "nugetversion" -and $Prop.value.ToLower() -eq ("4.0.0.2283"))
                        {
                            #should be "nuGetVersion =  4.0.0.2283"
                            Write-Host "Incorrect NuGet version found! should be nuGetVersion =  4.0.0.2283" -ForegroundColor Yellow
                            Write-Host "current values are:"
                            Write-Host "Property = " $Prop.Name
                            Write-Host "Value = " $Prop.Value
                        }
                    }                     
                    }
                }
            }
            
            #now check the Vstest versions stuff
            if($BldTask.DisplayName.ToLower().Contains("test assemblies"))
            {
                if(($BldTask.Task.VersionSpec -ne "2.*") -or ($BldTask.inputs.vsTestVersion.ToLower() -ne "latest"))
                {
                    Write-Host "VsTest settngs needs attention! Current values are: " -ForegroundColor Yellow      
                    Write-Host "Version spec: " $BldTask.Task.VersionSpec
                    Write-Host "vsTest version: " $BldTask.inputs.vsTestVersion
                }
            }

            #now check the Vstest versions stuff
            if($BldTask.DisplayName.ToLower().Contains("npm"))
            {
                foreach($Prop in $BldTask.inputs.PSObject.Properties)
                {
                    if($Prop.name.ToLower().Contains("command"))
                    {
                        Write-Host "Npm command found! Current values are": -ForegroundColor Yellow
                        Write-Host "Property = " $Prop.Name
                        Write-Host "Value = " $Prop.Value
                    }                
                }
            }
        }
    }
}

function Find-NugetVersion ($BldTask)
{
    $exists = $false
    foreach($Prop in $BldTask )
    {
        if($Prop.Name.ToLower().Contains("nugetversion"))
        {
            $exists = $true
        }
    }
    return $exists
}