function remove-PoshServerLessFunctionToApp
{
    <#
    .SYNOPSIS
    
    Remove a function object to an existing Function App Object
    
    .DESCRIPTION
    
    Remove a function object to an existing Function App Object
    It also remove the function from the disk
    
    .PARAMETER FunctionName
    Specifies the function Name
    
    .PARAMETER FunctionAppObject
    Specifie the Binding Object


    
    .EXAMPLE
    
           
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionName

    )

    $FunctionAppObject.RemoveFunction($FunctionName)


}