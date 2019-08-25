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