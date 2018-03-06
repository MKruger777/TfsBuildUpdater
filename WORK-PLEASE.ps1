
function Get-TfsBldDef
{
        <#
        .SYNOPSIS

    #>
    param(
        [Parameter(Mandatory)]
        [string]$TfsUri,        
        [Parameter(Mandatory)]
        [string]$TfsCollection
    )
#####################################################################





#local
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "T800\morne","en55denwlgpdxw2t4bwkdq6apfbugspjaxbhjhrxvymex5tqb2aa")))

#vsts
#$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "morne","w6zlqyawxnfomgwwh3v3zll6tfg2i2y35nsjtjotbzpc5acwpvyq")))

#local
$url = "http://t800:8080/tfs/DefaultCollection/Discovery/_apis/build/definitions/2?api-version=2.0"  #local

#vsts
#$url = "https://krugers.visualstudio.com/Build-Discovery/_apis/build/definitions/1?api-version=2.0"  #vsts

#$definition = Invoke-RestMethod -Uri $url -Headers @{Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"} -Method Get -ContentType application/json
$definition = Invoke-RestMethod -Uri $url -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Get -ContentType application/json

#Write-Host "Befor json = $($definition | ConvertTo-Json -Depth 100)" 

    #$definition.build[1].enabled = "True"   
    #$definition.build[1].DisplayName = "LaterGet- bla-bla-bla"
    $definition.Name = "Batman"

try {
    [void][System.Reflection.Assembly]::LoadFile("C:\Program Files\WindowsPowerShell\Modules\newtonsoft.json\1.0.1.141\libs\Newtonsoft.Json.dll")
    #$buildDefinition = [Newtonsoft.Json.JsonConvert]::DeserializeObject($definition)
    $serialized = [Newtonsoft.Json.JsonConvert]::SerializeObject($definition)

    #$body = (Convertto-Json  $definition -Depth 100) | clip
    #$body = (Get-Content "C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\json_inputs\t800\BuildDefKillerApp.json") #sort of works ...
    $Updatedefinition = Invoke-RestMethod -uri $url -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method PUT -Body $serialized -ContentType application/json
}
catch {
         $ErrorMessage = $_.Exception.Message
         $FailedItem = $_.Exception.ItemName
         Write-Host "errormessage = $ErrorMessage failditem = $FailedItem"
         Write-Host $Error(0)

#    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
#    $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
#    $streamReader.Close()
}

Write-Host "After json = $($Updatedefinition | ConvertTo-Json -Depth 100)" 


#######################################################################





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
        Write-Host $BldTask.DisplayName.ToLower() 
        if($BldTask.DisplayName.ToLower().Contains("nuget"))
        {
            Write-Host "Build display name: " $BldTask.DisplayName
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

    #now we need to convert to JSon to update some values? ...
    $JsonParameters = ConvertTo-Json -InputObject $JsonResult  
       

    # Now lets send the sucker back and update the definition
    #example
    #https://fabrikam-fiber-inc.visualstudio.com/DefaultCollection/Fabrikam-Fiber-Git/_apis/build/definitions/29?api-version=2.0
   
    
    try {
            #$r = Invoke-WebRequest -Uri "$uri/api/4.0/edges" -Body $body -Method:Post -Headers $head -ContentType "application/xml" -TimeoutSec 180 -ErrorAction:Stop
            $JsonResult = Invoke-WebRequest -uri $wiqlUrl -Method Put -Body $JsonParameters -ContentType 'application/Json' -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
        } 
        catch 
        {
            Failure
        }
 


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

function Failure {
    $global:helpme = $body
    $global:helpmoref = $moref
    $global:result = $_.Exception.Response.GetResponseStream()
    $global:reader = New-Object System.IO.StreamReader($global:result)
    $global:responseBody = $global:reader.ReadToEnd();
    Write-Host -BackgroundColor:Black -ForegroundColor:Red "Status: A system exception was caught."
    Write-Host -BackgroundColor:Black -ForegroundColor:Red $global:responsebody
    Write-Host -BackgroundColor:Black -ForegroundColor:Red "The request body has been saved to `$global:helpme"
    break
    }

    Get-TfsBldDef -TfsUri "dfgfdgdf" -TfsCollection 'Binck'
