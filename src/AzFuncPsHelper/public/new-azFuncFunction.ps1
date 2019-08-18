function new-azFuncFunction 
{
    <#
    .SYNOPSIS
    
    Create a new azure function object
    
    .DESCRIPTION
    
    Create a new azure function object
    The FunctionAppPath and the name parameter will build the function path 
    
    .PARAMETER FunctionAppPath
    Specifies the function App path
    
    .PARAMETER FunctionName
    Specifie the name of the function. 

    .PARAMETER OverWrite
    switch Specifies if the AZFunc Module should recreate the function folder if exist
    Default $false, in this case the module only rewrite the function.json
    
    .OUTPUTS
    
    AzFunction object
    
    .EXAMPLE
    
    new-azFuncFunction -FunctionAppPath "c:\work\functionAppFolder\" -FunctionName "TimerFunction"
    create a new azFunction Object
           
    #>
    [OutputType([AzFunction])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionName,

        [switch]
        $OverWrite 

    )

    $functionPath = join-path -Path $FunctionAppPath -ChildPath $FunctionName

    return [AzFunction]::new($FunctionName,$FunctionPath, $OverWrite)

}