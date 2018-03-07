
$baseUrl = "https://tfs.mycorp.net/tfs"
$targetCollection = "DefaultCollection"
$targetProject = "Acme"
$targetBuildName = "Acme - My Build Definition"
#$definitionsOverviewUrl = "$baseUrl/$targetCollection/$targetProject/_apis/build/Definitions"
$definitionsOverviewUrl = "http://papptfs17.binckbank.nv:8080/tfs/Binck/Delivery/_apis/build/Definitions" 
$definitionsOverviewResponse = Invoke-WebRequest -UseDefaultCredentials $definitionsOverviewUrl
$NewtonSoftJsonPath = "D:\Dev\github\TfsBuildUpdater\newtonsoft.json.11.0.1\lib\net45\Newtonsoft.Json.dll"

Write-Host "content=" $definitionsOverviewResponse.Content

$definitionsOverview = (ConvertFrom-Json $definitionsOverviewResponse.Content).value
$BldDefinitionUrl = ($definitionsOverview | Where-Object { $_.name -eq "We build this city" } | Select-Object -First 1).url
$response = Invoke-WebRequest $BldDefinitionUrl -UseDefaultCredentials
#as the variable states we get the build def URL ...

Write-Host "BuildDef content =" $response.Content

# This assumes the working directory is the location of the assembly:
[void][System.Reflection.Assembly]::LoadFile($NewtonSoftJsonPath)
$buildDefinition = [Newtonsoft.Json.JsonConvert]::DeserializeObject($response.Content)
Write-Host "BuildDef name=" $buildDefinition.name.ToString()

# JObjects implement IDictionary and therefore support dot notation
#$buildDefinition.variables.MajorMinor.value.ToString()
#$buildDefinition.variables.MajorMinor.value = "3.4"
$buildDefinition.name = "Captain America"

$serialized = [Newtonsoft.Json.JsonConvert]::SerializeObject($buildDefinition)

$postData = [System.Text.Encoding]::UTF8.GetBytes($serialized)
# The TFS2015 REST endpoint requires an api-version header, otherwise it refuses to work properly.
$headers = @{ "Accept" = "api-version=2.3-preview.2" }
$response = Invoke-WebRequest -UseDefaultCredentials -Uri $BldDefinitionUrl -Headers $headers `
              -Method Put -Body $postData -ContentType "application/json"
$response.StatusDescription