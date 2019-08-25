function get-PoshServerlessFunctionApp
{

    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateScript({Test-Path $_\host.json})]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppName

    )

    return [AzFunctionsApp]::new($FunctionAppName, $FunctionAppPath)





}