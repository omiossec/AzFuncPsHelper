# Documentation 

This tools help to manage PowerShell Azure Functions v2 (Some cmdlet can also be used for non PowerShell Json based Azure Functions)

## Create an Azure Functions Locally and publish your work to an existing Azure Function APP

To create a Function APP localy 

```powershell
$FunctionApp =  new-PoshServerlessFunctionApp -FunctionAppPath "c:\work\functionAppFolder\" -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
```

FunctionAppLocation and FunctionAppResourceGroup are optionnal but you will need this value before pushing the function app to Azure. 

If your function app exist in Azure you can load data from Azure like App Seeting by using 

```powershell
Resolve-PoshServerlessFunctionApp -FunctionAppObject $FunctionApp -ResourceGroupName MyRg
```

Now you can publish information to your function app 

```powershell
Publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp
```

## Get a local Azure Functions App and load Value from Azure

If you have downloaded functions App files on your local computer you can use it as an AzFunctionsApp object

```powershell 
$functionApp = get-PoshServerlessFunctionApp -FunctionAppPath "C:\work\formations\poshserverlessa001" -FunctionAppName poshserverlessa001
```

You can load data from Azure like App Seeting by using

```powershell
Resolve-PoshServerlessFunctionApp -FunctionAppObject $FunctionApp -ResourceGroupName MyRg
```

You can no retreive some value like location

```powershell
$functionApp.FunctionAppLocation
```

Or App Settings

```powershell
$functionApp.FunctionAppSettings
```

Now you can publish information to your function app

```powershell
Publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp
```

You can setup the Function TimeZone

```powershell
Set-PoshServerlessFunctionAppTimezone -FunctionAppObject $functionApp -TimeZone 'Romance Standard Time'
```

## Get an Azure Functions APP from Azure

If you have an Azure Functions App in Azure and want to download it locally and create an AzFunctionsApp object.

```powershell
$functionApp =  sync-PoshServerlessFunctionApp -FunctionAppName "poshserverlessa001" -ResourceGroupName "poshserverless-test" -LocalFunctionPath "C:\work\formations\lab2"
```

## Add a Function to a Functions App

in order to add a function to an AzFunctionsApp object we need to create an AzFunction object 

```powershell
$MyFunction = new-PoshServerlessFunction -FunctionAppObject $FunctionApp -FunctionName "MyFunction"
```


## Change the Trigger in a function APP

we need to create a trigger object 

```powershell
$TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage
```

And add it to the function object

```powershell
update-PoshServerlessFunctionTrigger -FunctionObject $myFunction -TriggerObject $TriggerObject
```

## Change binding in a Functions APP

we can also add a binding

```powershell
$Biding = new-PoshServerlessFunctionBinding -Direction out -BindingName MyBinding -BindingType queue -connection MyStorage
```
And add it to a function object 

```powershell 
add-PoshServerlessFunctionBinding -FunctionObject $MyFunction -BindingObject $Biding
```
We can now add the function object to the app 

```powershell
add-PoshServerLessFunctionToApp -FunctionObject $MyFunction -FunctionAppObject $functionApp
```

This will create the function inside the folder with the function.json (but not the run.ps1 file)

finaly you can publish the FunctionApp

```powershell
publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp
```

## The AzFunctionsApp Object

### Properties 

|Name|Description|
|----|-----------|
| FunctionAppName  | The name of the function App. the Name of the function App in Azure. This is also the part of the of the functions App URI (xxxx.azurewebsites.net)   |
| FunctionAppPath  | The local path of the Functions App files on the local computer |
| RessourceGroup | The name of the resources group where your App functions is located |
| FunctionHostName | The URI of the functions App. This properties is populated by using Resolve-PoshServerlessFunctionApp  or sync-PoshServerlessFunctionApp |
| FunctionAppStorageName | The name of the storage account associate with the Azure Functions App. This properties is populated by using Resolve-PoshServerlessFunctionApp  or sync-PoshServerlessFunctionApp |
| FunctionAppLocation | Function App location. This properties is populated by using Resolve-PoshServerlessFunctionApp  or sync-PoshServerlessFunctionApp |
| FunctionTimeZone | The function timezone, if null the Azure functions time zone is UTC|
| FunctionRuntime | By default PowerShell |
| functionAppExtension | [hashtable]  |
| FunctionAppSettings | [hashtable]  |
| Azfunctions | Array of [AzFunction] object associated with the function |


## The AzFunction Object

|Name|Description|
|----|-----------|
|FunctionName | |
|FunctionPath | |
|TriggerBinding | |
|Binding | |
|overwrite | |
|FunctionExist | |
|JsonFunctionBindings | |



## Cmdlet list

* Initialize-PoshServerLessFunctionApp
* Resolve-PoshServerlessFunctionApp
* Set-PoshServerlessFunctionAppTimezone
* add-PoshServerLessFunctionBinding
* add-PoshServerLessFunctionToApp
* get-PoshServerLessFunction
* get-PoshServerLessFunctionApp
* get-PoshServerLessFunctionBinding
* get-PoshServerLessFunctionTrigger
* new-PoshServerLessFunction
* new-PoshServerLessFunctionBinding
* new-PoshServerLessFunctionTrigger
* new-PoshServerlessFunctionApp
* publish-PoshServerLessFunctionApp
* remove-PoshServerLessFunctionBinding
* remove-PoshServerLessFunctionToApp
* set-PoshServerlessFunctionAppSetting
* sync-PoshServerlessFunctionApp
* test-PoshServerLessFunctionBinding
* update-PoshServerLessFunctionTrigger
* write-PoshServerLessFunction
