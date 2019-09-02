function publish-PoshServerLessFunctionApp 
{
<#


#>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AzFunctionsApp]
        $FunctionAppObject

    )


    if ($PSCmdlet.ShouldProcess($FunctionAppObject.FunctionAppName,"Publish this Function to Azure, it will rewrite the entire App in Azure")) {

        

    }


}

