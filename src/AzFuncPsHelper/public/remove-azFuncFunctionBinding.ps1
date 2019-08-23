function remove-azFuncFunctionBinding {



    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $BindingName

    )

    if (test-azFuncFunctionBinding -FunctionObject $FunctionObject -BindingName $BindingName) {
        $FunctionObject.RemoveAzFuncBinding($BindingName)
    }
    else {
        throw "Error: No Binding found"
    }

}