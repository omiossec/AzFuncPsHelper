function get-PoshServerlessFunctionApp
{

        <#
    .SYNOPSIS
    
    Create an Azure Function App object by reading a folder
    
    .DESCRIPTION
    
    Create an Azure Function App object by reading a folder
    If you have download a functions App or create it you can use this function to create an AzFunctionsApp object from the folder
    It will read the host.json and function folder
    
    .PARAMETER FunctionAppPath
    [String] the function App Path
    if the path doesn't exist the cmdlet will fail

    .PARAMETER FunctionAppName
    [String] the function App Name
    

           
    #>

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