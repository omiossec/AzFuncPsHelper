function test-azFuncFunctionBinding 
{

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