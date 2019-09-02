function add-PoshServerLessFunctionToApp 
{

        <#
    .SYNOPSIS
    
    Add a function object to an existing Function App Object
    
    .DESCRIPTION
    
    Add a function object to an existing Function App Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER FunctionAppObject
    Specifie the Binding Object


    
    .EXAMPLE
    
           
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionAppObject.AddFunction($FunctionObject)

}