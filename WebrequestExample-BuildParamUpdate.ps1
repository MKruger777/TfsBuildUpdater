

#this code works to update the VNext build definition without chucking the tasks away

$BldDefinitionUrl = "http://t800:8080/tfs/DefaultCollection/Discovery/_apis/build/definitions/3?api-version=2.0"
$response = Invoke-WebRequest $BldDefinitionUrl -UseDefaultCredentials

# This assumes the working directory is the location of the assembly:
[void][System.Reflection.Assembly]::LoadFile("C:\dev\PowerShell\Tfs-BuildDefinitions\TfsBuildUpdater\newtonsoft.json.11.0.1\lib\net45\Newtonsoft.Json.dll")
$buildDefinition = [Newtonsoft.Json.JsonConvert]::DeserializeObject($response.Content)
Write-Host "BuildDef name=" $buildDefinition.name.ToString()

$buildDefinition.name = "Captain America"

$serialized = [Newtonsoft.Json.JsonConvert]::SerializeObject($buildDefinition)

$postData = [System.Text.Encoding]::UTF8.GetBytes($serialized)
# The TFS2015 REST endpoint requires an api-version header, otherwise it refuses to work properly.
$headers = @{ "Accept" = "api-version=2.3-preview.2" }
$response = Invoke-WebRequest -UseDefaultCredentials -Uri $BldDefinitionUrl -Headers $headers `
              -Method Put -Body $postData -ContentType "application/json"
$response.StatusDescription