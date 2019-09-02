function sync-PoshServerlessFunctionApp 
{
    <#
    .SYNOPSIS
    
    Download a function App content to the local workstation
    
    .DESCRIPTION
    
    Download a function App content to the local workstation
    this cmdlet use Azure PowerShell, you need to install it install-module -name AZ -scope CurrentUser
    You need a valid connexion to azure before, run login-azaccount before runing this cmdlet
    
    .PARAMETER FunctionName
    The function name in Azure 
    ex: MyPowerShellAzFunction 

    .PARAMETER ResourceGroupName
    The name of the ressouce group in Azure where the function app is 

    .PARAMETER LocalFunctionPath
    The local path to download Azure functions files and folder
    The path should be empty
    

   
    .EXAMPLE  
    sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction'           
    #>


    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string]
        $FunctionAppName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceGroupName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $LocalFunctionPath

    )

    if (test-path -Path $LocalFunctionPath -ErrorAction SilentlyContinue) {

        if ((get-childitem -Path $LocalFunctionPath).count -gt 0) {
            throw "The Path of The function $($LocalFunctionPath) is not empty"
        }
        
      
    } else {
        try {
            new-item -Path $LocalFunctionPath -ItemType Directory | out-null
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
    }


    return [AzFunctionsApp]::new($FunctionAppName, $LocalFunctionPath, $ResourceGroupName)

}