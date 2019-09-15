function Resolve-PoshServerlessFunctionApp 
{
    <#
    .SYNOPSIS
    
    This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync
    
    .DESCRIPTION
    
    This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync
    
    .PARAMETER FunctionAppObject
    A [AzFunctionsApp] object

    .PARAMETER ResourceGroupName
    The name of the ressource Group

   
    .EXAMPLE  

    $FunctionApp = get-PoshServerlessFunctionApp -FunctionAppPath Path -FunctionAppName MyFuntion
    Resolve-PoshServerlessFunctionApp -FunctionAppObject $FunctionApp -ResourceGroupName MyRessourceGroup
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceGroupName

    )

    $FunctionAppObject.LoadFunctionFromAzure($ResourceGroupName)

}