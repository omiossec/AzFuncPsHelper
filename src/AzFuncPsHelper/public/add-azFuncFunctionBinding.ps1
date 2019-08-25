function add-azFuncFunctionBinding 
{

    <#
    .SYNOPSIS
    
    Add a Binding object to an existing azFunction Object
    
    .DESCRIPTION
    
    Add a Binding object to an existing azFunction Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER BindingObject
    Specifie the Binding Object


    
    .EXAMPLE
    

           
    #>

    
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsBinding]
        $BindingObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionObject.AddBinding($BindingObject)

}