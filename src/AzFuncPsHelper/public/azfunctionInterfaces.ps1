$ErrorActionPreference = "Stop"

$ClassFile = join-path -path (Join-Path -Path (Split-Path -Path $PSScriptRoot) -ChildPath "classes") -ChildPath "azfuntiontypes.ps1"
."$($ClassFile)"



$a = [AzFunction]::new("TimerTrigger1", "C:\work\lab\azfuncpowershellhelper01\HttpTrigger1")

 

$a.TriggerBinding

