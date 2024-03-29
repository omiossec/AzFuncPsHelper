function get-PoshServerlessFunctionTrigger
{
    
    <#
    .SYNOPSIS
    
    retreive trigger object from a AzFunc Object
    
    .DESCRIPTION
    
    retreive trigger object from a AzFunc Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
        
    .EXAMPLE
    
    $FunctionObjectVar | get-PoshServerlessFunctionBinding 
    

           
    #>

    [OutputType([AzFunctionsTrigger])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

    return $FunctionObject.TriggerBinding

}