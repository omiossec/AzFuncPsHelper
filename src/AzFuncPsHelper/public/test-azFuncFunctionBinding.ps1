function test-azFuncFunctionBinding 
{
    <#
    .SYNOPSIS
    Test if a binding exist in a AzFunc Object

    .DESCRIPTION
    Test if a binding exist in a AzFunc Object, by BindingName
    Return a boolean 
    True if the Binding exist
    False if the bindind do not exist

    .PARAMETER FunctionObject
    The AzFunction Object to test

    .PARAMETER BindingName
    The Binding name to test (string)

    .OUTPUTS
    Boolean

    .EXAMPLE

    test-azFuncFunctionBinding -FunctionObject $FunctionObject -BindingName BindingNameToTest

    #>
    [OutputType([boolean])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $BindingName

    )

    return $FunctionObject.TestAzFuncBinding($BindingName)
}