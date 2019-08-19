function get-azFuncFunction 
{
<#
.SYNOPSIS

Read a specific Azure Function from a path

.DESCRIPTION

Read a specific Azure Function from a path


.PARAMETER Path
Specifies the function path

.PARAMETER OverWrite
switch Specifies if the AZFunc Module should recreate the folder 
Default $false, in this case the module only rewrite the function.json

.OUTPUTS

AzFunction object

.EXAMPLE

get-azFuncFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction"
Load the function TimerFunction from the FunctionAppFolder 

.EXAMPLE

get-azFuncFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction" -OverWrite
Load the function TimerFunction from the FunctionAppFolder and tell the module to overwrite the function folder


#>

    [OutputType([AzFunction])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateScript({Test-Path $_\function.json})]
        [string]
        $FunctionPath,

        [switch]
        $OverWrite 

    )

    return [AzFunction]::new($FunctionPath, $OverWrite)

}