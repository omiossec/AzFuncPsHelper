# Documentation 

This tools help to manage PowerShell Azure Functions v2 (Some cmdlet can also be used for non PowerShell Json based Azure Functions)

## Create an Azure Functions Locally and publish your work to an existing Azure Function APP

To create a Function APP localy 

```powershell
$FunctionApp =  new-PoshServerlessFunctionApp -FunctionAppPath "c:\work\functionAppFolder\" -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
```

FunctionAppLocation and FunctionAppResourceGroup are optionnal but you will need this value before pushing the function app to Azure. 



## Create an Azure Functions Locally and publish your work to an existing Azure Function APP

## Get a local Azure Functions App and load Value from Azure

## Get an Azure Functions APP from Azure

## Add a Function to a Functions App 

## Change binding in a Functions APP

## Change the Trigger in a function APP

## The AzFunctionsApp Object

## The AzFunction Object

