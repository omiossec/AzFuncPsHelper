param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = $ENV:ModuleName
)

$ModuleManifestPath = "$($BuildModulePath)\build\$($ModuleName)\$($ModuleName).psd1"

Get-Module -Name $ModuleName | remove-module


$ModuleInformation = Import-module -Name $ModuleManifestPath -PassThru


