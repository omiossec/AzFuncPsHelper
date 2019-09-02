[cmdletbinding()]
param (
    [Parameter(Mandatory=$false)]
    [String]
    $SourceFolder = [Environment]::GetEnvironmentVariable('BUILD_SOURCESDIRECTORY'),

    [Parameter(Mandatory=$false)]
    [String]
    $ModuleName=[Environment]::GetEnvironmentVariable('ModuleName'),

    [Parameter(Mandatory=$false)]
    [String]
    $ModuleVersion=[Environment]::GetEnvironmentVariable('ModuleVersion')
)

$PathSeparator = [IO.Path]::DirectorySeparatorChar


$BuildFolder = join-path -path $SourceFolder  -childpath "generated"

$BuildModulePath =  join-path -path $BuildFolder -ChildPath $ModuleName

$BuildModuleDoc =  join-path -path $BuildModulePath -ChildPath "docs"

$BuildModuleClasses =  join-path -path $BuildModulePath -ChildPath "classes"

$BuildModulePrivateFolder =  join-path -path $BuildModulePath -ChildPath "private"

$BuildModulePublicFolder =  join-path -path $BuildModulePath -ChildPath "public"


$ModuleSourceFolder = join-path -path $SourceFolder  -childpath "src"

$ModuleSourceFolder = join-path -path $ModuleSourceFolder  -childpath $ModuleName

if (Test-Path $BuildFolder) {
    Remove-Item -Path $BuildFolder -Force -Recurse -Confirm:$false
}

new-item -Path $BuildFolder -ItemType Directory

new-item -Path $BuildModulePath -ItemType Directory


$BuildModuleManifest = Join-Path -Path $BuildModulePath -ChildPath "$($ModuleName).psd1"
$BuildModulePSM1 = Join-Path -Path $BuildModulePath -ChildPath "$($ModuleName).psm1"
$SourceMouduleManifest = Join-Path -Path $ModuleSourceFolder -ChildPath "module.psd1"

Copy-Item -Path $SourceMouduleManifest -Destination $BuildModuleManifest -Force

$PublicFunctionsList = Get-ChildItem -Path $ModuleSourceFolder -Include 'Public' -Recurse -Directory | Get-ChildItem -Include *.ps1 -File


$AllFunctionsAndClasses = Get-ChildItem -Path $ModuleSourceFolder -Include 'Public', 'classes' -Recurse -Directory | Get-ChildItem -Include *.ps1 -File


new-item -Path $BuildModulePSM1 -ItemType File

if ($AllFunctionsAndClasses) {
    Foreach ($FunctionAndClass in $AllFunctionsAndClasses) {
        Get-Content -Path $FunctionAndClass.FullName | Add-Content -Path $BuildModulePSM1
    }
}


Update-ModuleManifest -Path $BuildModuleManifest -FunctionsToExport $PublicFunctionsList.BaseName

Update-ModuleManifest -Path $BuildModuleManifest -ModuleVersion $ModuleVersion

Update-ModuleManifest -Path $BuildModuleManifest -RootModule "$($ModuleName).psm1"

Install-Module -Name platyPS -Scope CurrentUser
Import-Module platyPS -Force



$ModuleInformation = Import-module -Name $BuildModuleManifest -PassThru



New-MarkdownHelp -Module $ModuleName -OutputFolder $BuildModuleDoc -ErrorAction SilentlyContinue

