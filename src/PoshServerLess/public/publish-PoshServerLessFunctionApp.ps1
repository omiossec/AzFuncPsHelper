function publish-PoshServerLessFunctionApp 
{
    <#
    .SYNOPSIS
    
    Publish the function to Azure
    
    .DESCRIPTION
    
    Publish the function app to Azure
    This action will replace all the functions inside Azure by those in the function app Object
    You need to have a valid ResourceGroup in the object (for example by using sync-PoshServerlessFunctionApp)
    
    .PARAMETER FunctionAppObject
    Specifies the function Object
    
    .EXAMPLE

    $myFunctionApp = sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction' 

    $myFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\Myfunction\timerfunc" -FunctionName "TimerFunction"

    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

    update-PoshServerlessFunctionTrigger -FunctionObject myFunction -TriggerObject $TriggerObject

    add-PoshServerLessFunctionToApp -FunctionObject $myFunction -FunctionAppObject $myFunctionApp

    publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp

           
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AzFunctionsApp]
        $FunctionAppObject

    )


    if ($PSCmdlet.ShouldProcess($FunctionAppObject.FunctionAppName,"Publish this Function to Azure, it will rewrite the entire App in Azure")) {

        $FunctionAppObject.PublishFunctionApp()

    }


}

