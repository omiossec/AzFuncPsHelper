function get-azFuncFunctionBinding 
{

    <#
    .SYNOPSIS
    
    retreive Binding from a AzFunc Object
    
    .DESCRIPTION
    
    retreive Binding from a AzFunc Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
        
    .EXAMPLE
    
    $FunctionObjectVar | get-azFuncFunctionBinding 
    

           
    #>

    [OutputType([AzFunctionsBinding[]])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

    return $FunctionObject.Binding
    
}