function set-PoshServerlessFunctionAppSetting 
{
    <#
    .SYNOPSIS
    
    Add or Update an App Setting 
    
    .DESCRIPTION
    
    Add or Update an App Setting 
    
    
    .PARAMETER FunctionsAppObject
    The Function App object

    .PARAMETER AppSettingName
    string Representing the timezone see 
    the value can't be FUNCTIONS_WORKER_RUNTIME,AzureWebJobsStorage,FUNCTIONS_EXTENSION_VERSION,WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,WEBSITE_CONTENTSHARE

    .PARAMETER AppSettingValue
    string Representing the timezone see 
    
    .EXAMPLE
    

           
    #>


    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -notin @("FUNCTIONS_WORKER_RUNTIME","AzureWebJobsStorage","FUNCTIONS_EXTENSION_VERSION","WEBSITE_CONTENTAZUREFILECONNECTIONSTRING","WEBSITE_CONTENTSHARE")})]
        [string]
        $AppSettingName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AppSettingValue
    )

    write-verbose "Setting value for $($AppSettingName)"

    $PatternWhiteSpace ="[\s-[\r\n]]" 
    if (! $AppSettingName -match $PatternWhiteSpace) {
        $FunctionAppObject.UpdateAppSetting($AppSettingName, $AppSettingValue)
    }
    else {
        throw "White Space are not allowed in App Settings Name"
    }
    
}