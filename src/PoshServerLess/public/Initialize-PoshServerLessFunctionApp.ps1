function Initialize-PoshServerLessFunctionApp {

    <#
    .SYNOPSIS
    
    Create an Azure Function App in Azure And deploy the current function App object in 
    
    .DESCRIPTION
    
    Create an Azure Function App in Azure And deploy the current function App object in 
    This cmdlet can be use for creating a function localy and then create the function App in Azure and then deploy the functions
    or to copy a functions app
    
    .PARAMETER FunctionAppObject
    In or Out
    Queue binding accept only Out direction

    .PARAMETER RessourceGroup
    The ressource group 
    
        
    .EXAMPLE
    
    Initialize-PoshServerLessFunctionApp -FunctionAppObject $MyFunctionApp -RessourceGroup MyRg

    to copy a function app 

    $functionsAppToCopy = sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction'           
    
    $NewFunctionAppFromCopy = get-PoshServerlessFunctionApp -FunctionAppPath "c:\work\Myfunction\MyFunctionApp01" -FunctionAppName FunctionAppUniqueName

    Initialize-PoshServerLessFunctionApp -FunctionAppObject $NewFunctionAppFromCopy -RessourceGroup MyRg

    This will copy the content of MyFunctionApp01 into FunctionAppUniqueName
           
    #>


    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunctionsApp]
        $FunctionAppObject, 

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string]
        $RessourceGroup
    )

    $FunctionAppObject.RessourceGroup = $RessourceGroup


  
    if ( TestAzConnection ) {
        if (-not $functionAppObject.TestFunctionAppExistInAzure()) {
            $FunctionAppObject.deployFunctionApp()

            $FunctionAppObject.PublishFunctionApp()

            $FunctionAppObject.LoadFunctionFromAzure($FunctionAppObject.RessourceGroup)
        }
        else {
            throw "The Azure Functions App $($this.FunctionAppName) all ready exist in Azure"
        }

    }else {
        throw "You are not connected to Azure"
    }

      
 


}