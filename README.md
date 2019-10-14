# PoshServerLess

[![Build status](https://dev.azure.com/powershell-paris/AzFuncPsHelper/_apis/build/status/AzFuncPsHelper-CI)](https://dev.azure.com/powershell-paris/AzFuncPsHelper/_build/latest?definitionId=1)
 


This project started as a side project to start working on OOP with a PowerShell module. I needed a subject and at this time I worked with Azure Function. 

 One of my main problems when working with Azure Functions v2 with PowerShell is to deal with Binding and Trigger. How to remember what binding I can use, which direction, which extension. It’s easy when using the portal, but if you need to create and modify function locally it’s not the best way. 
This is only a Proof of Concept for the moment. There is a lot of work to do.
The goal is to publish the module in the PowerShell Gallery.

## Installation
This module is listed on powershellgallery

```powershell
Install-Module -Name PoshServerLess -Scope CurrentUser
```

## Documentation 

You can check the full documentation [here](https://github.com/omiossec/AzFuncPsHelper/tree/master/doc)

## Release notes 

You can find the release notes [here](https://github.com/omiossec/AzFuncPsHelper/blob/master/changelog.md)

## Usage

There are 4 main objects used in this module

* PoshServerLessApp, the representation of one Azure Functions App V2 for PowerShell
* PoshServerLessFunction, the representation of one Function in a an Azure  function App
* PoshServerLessFunctionTrigger, the representation of the trigger of a function in an Azure function App
* PoshServerLessFunctionBinding, the representation of binding of a function in an Azure function App

### Load an existing Azure Functions localy

```powershell
$FunctionApp = sync-PoshServerlessFunctionApp -FunctionAppName "FunctionName" -ResourceGroupName "RGName" -LocalFunctionPath "C:\work\lab\functions\FunctionName"
```

 
### Create a new Function

```powershell
$Function = new-PoshServerLessFunction -FunctionAppPath "C:\work\lab\functions\FunctionName" -FunctionName "TimerFunction"
``` 

### Add a Trigger to the function

```powershell
$Trigger = new-PoshServerLessFunctionTrigger -TriggerType timerTrigger -Schedule "0 */5 * * * *"
 
 update-PoshServerLessFunctionTrigger -triggerObject $Trigger  -FunctionObject $Function
```

 
### Add Binding 

```powershell
$Queue = new-PoshServerLessFunctionBinding -Direction out -BindingName MyQueue – connection AzureWebStorage -queueName myAzureQueue
 
add-PoshServerLessFunctionBinding  -FunctionObject $Function -BindingObject $Queue
```

### write function
```powershell
  $Function  | write-PoshServerlessFunction 
  ```

### Update The Function App 

```powershell
add-PoshServerLessFunctionToApp -FunctionAppObject $FunctionApp -FunctionObject $function
```

### Publish the function app 

```powershell
publish-PoshServerLessFunctionApp -FunctionAppObject $FunctionApp
```
 
