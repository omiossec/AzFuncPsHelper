
function TestModulePresent ([string] $moduleName="Az") {

    return ! $null -eq (get-module -ListAvailable | where-object name -eq $moduleName)
}