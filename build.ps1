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



$BuildFolder = join-path -path $SourceFolder  -childpath "generated"

$BuildModulePath =  join-path -path $BuildFolder -ChildPath $ModuleName


$SourceFolder = join-path -path $SourceFolder  -childpath "src"