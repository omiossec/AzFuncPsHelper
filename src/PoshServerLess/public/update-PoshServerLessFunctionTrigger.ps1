function update-PoshServerlessFunctionTrigger 
{

    <#
    .SYNOPSIS
    
    Update an AzFunction Object with a trigger Object
    
    .DESCRIPTION
    
    Update an AzFunction Object with a trigger Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER TriggerObject
    Specifie the Trigger binding Object

   
    .EXAMPLE  

    $myFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\Myfunction\timerfunc" -FunctionName "TimerFunction"

    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

    update-PoshServerlessFunctionTrigger -FunctionObject myFunction -TriggerObject $TriggerObject
   
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsTrigger]
        $triggerObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionObject.AddTriger($triggerObject)
    
}