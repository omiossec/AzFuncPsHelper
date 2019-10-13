function new-PoshServerlessFunctionApp {
    <#
    .SYNOPSIS
    
    Create a new azure function App object and the function app file
    
    .DESCRIPTION
    
    Create a new azure function App object and the function app file
    It doesn't create the function in Azure
    
    .PARAMETER FunctionAppPath
    Specifies the function App local path, this path must not exist
    
    .PARAMETER FunctionAppName
    The host name of the function App. This Name must be globally unique 

    .PARAMETER FunctionAppLocation
    The Function App desired location

    .PARAMETER FunctionAppResourceGroup
    The Function App desired Resource Group
    
    .OUTPUTS
    
    AzFunctionsApp object
    
    .EXAMPLE
    
    new-PoshServerlessFunctionApp -FunctionAppPath "c:\work\functionAppFolder\" -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
    create a new azFunction Object
           
    #>
    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppName,

        [string]
        [ValidateSet("UKSouth", "UKWest", "NorthEurope","WestEurope",	"FranceCentral","SouthAfricaNorth","CentralIndia",	"SouthIndia","WestIndia","JapanEast","JapanWest","KoreaCentral", 
        "EastAsia","SoutheastAsia","AustraliaCentral", "AustraliaCentral2",	"AustraliaEast", "AustraliaSoutheast", "BrazilSouth", "CanadaCentral",
        "CanadaEast", "ChinaEast","ChinaEast2",	"ChinaNorth", "GermanyCentral", "GermanyNortheast","WestUS",
        "WestUS2", "CentralUS", "EastUS","EastUS2","NorthCentralUS","SouthCentralUS","WestCentralUS"
        )]
        $FunctionAppLocation,

        [string]
        $FunctionAppResourceGroup,

        [string]
        [ValidateSet("csharp", "javascript", "fsharp","java", "powershell","python","typescript")]
        $FunctionAppRuntime = "powershell"
    )

  
        return [AzFunctionsApp]::new($FunctionAppName,$FunctionAppPath, $FunctionAppResourceGroup, $FunctionAppLocation, $FunctionAppRuntime)


}











