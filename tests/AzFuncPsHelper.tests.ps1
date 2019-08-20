param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = $ENV:ModuleName,
    $ModuleVersion = $ENV:ModuleVersion
)

$ModuleManifestPath = "$($BuildModulePath)\generated\$($ModuleName)\$($ModuleName).psd1"

Get-Module -Name $ModuleName | remove-module


$ModuleInformation = Import-module -Name $ModuleManifestPath -PassThru



Describe "$ModuleName Testing"{




    Context "$ModuleName Module manifest" {


        It "Should contains RootModule" {
            $ModuleInformation.RootModule | Should not BeNullOrEmpty
        }

        It "Should contains Author" {
            $ModuleInformation.Author | Should -Not -BeNullOrEmpty
        }

        It "Should contains Company Name" {
             $ModuleInformation.CompanyName|Should -Not -BeNullOrEmpty
            }

        It "Should contains Description" {
            $ModuleInformation.Description | Should -Not -BeNullOrEmpty
        }

        It "Should contains Copyright information" {
            $ModuleInformation.Copyright | Should -Not -BeNullOrEmpty
        }

        It "Should have a project URI" {
            $ModuleInformation.ProjectUri | Should -Not -BeNullOrEmpty
        }

        It "Should have a License URI" {
            $ModuleInformation.LicenseUri | Should -Not -BeNullOrEmpty
        }

        It "Should have at least one tag" {
            $ModuleInformation.tags.count | Should -BeGreaterThan 0
        }

    }
    InModuleScope $ModuleName {
        Context "$($ModuleName) Cmdlet testing" {



            $FakeFunctionJsonData = @"
            {
                "bindings": [
                  {
                    "name": "Timer",
                    "type": "timerTrigger",
                    "direction": "in",
                    "schedule": "0 */5 * * * *"
                  },
                  {
                    "type": "blob",
                    "name": "inputBlob",
                    "path": "incontainer/{name}",
                    "connection": "AzureWebJobsStorage",
                    "direction": "in"
                  },
                  {
                    "type": "table",
                    "name": "inputTable",
                    "tableName": "inTable",
                    "take": 50,
                    "connection": "AzureWebJobsStorage",
                    "direction": "in"
                  },
                  {
                    "type": "queue",
                    "name": "outputQueueItem",
                    "queueName": "outqueue",
                    "connection": "AzureWebJobsStorage",
                    "direction": "out"
                  },
                  {
                    "type": "blob",
                    "name": "return",
                    "path": "outcontainer/{rand-guid}",
                    "connection": "AzureWebJobsStorage",
                    "direction": "out"
                  },
                  {
                    "type": "table",
                    "name": "inputTable2",
                    "tableName": "inTable",
                    "partitionKey": "particitionoptional",
                    "rowKey": "rowkeyoption",
                    "take": 50,
                    "filter": "queryfilteroption",
                    "connection": "AzureWebJobsStorage",
                    "direction": "in"
                  },
                  {
                    "type": "table",
                    "name": "outputTable",
                    "tableName": "outTable",
                    "connection": "AzureWebJobsStorage",
                    "direction": "out"
                  }
                ]
              }
"@
              

$fakeFunctionAppPath = (join-path "testdrive:\" -ChildPath "functionApp")
$fakeFUnctionAppHostJson = (join-path $fakeFunctionAppPath -ChildPath "host.json")
$fakeFunctionPath = (join-path $fakeFunctionAppPath -ChildPath "testFunc")
$fakeFunctionBinPath = (join-path $fakeFunctionAppPath -ChildPath "bin")
$fakeFunctionJsonPath = (join-path $fakeFunctionPath -ChildPath "function.json")
new-item -path $fakeFunctionPath -ItemType Directory
new-item -path $fakeFunctionBinPath -ItemType Directory
new-item -path $fakeFUnctionAppHostJson -ItemType File
Set-Content $fakeFunctionJsonPath -value $FakeFunctionJsonData -Encoding utf8

$FunctionFakeObject = get-azFuncFunction -FunctionPath $fakeFunctionPath 

            It "Should not Throw when create a new function" {
                { new-azFuncFunction -FunctionAppPath $fakeFunctionAppPath -FunctionName "FakeFunction2" } | Should -not -Throw 
            }

            it "Should not throw when reading an existing function" {
                { get-azFuncFunction -FunctionPath $fakeFunctionPath } | Should -not -Throw 
            }

            it "get-azFuncFunction return a AzFunction Object " {
                $FunctionFakeObject.getType()   | Should -be "AzFunction"
            }
             
            it "get-azFuncFunctionBinding  return the correct number of binding " {
                (get-azFuncFunctionBinding -FunctionObject  $FunctionFakeObject).count | Should -be 6
            }

            it "get-azFuncFunctionTrigger  return the correct value " {
                (get-azFuncFunctionTrigger -FunctionObject  $FunctionFakeObject).TriggerType | Should -be "timerTrigger"
            }

            it " new-azFuncFunction  return a AzFunction Object" {
                (new-azFuncFunction  -FunctionAppPath  $fakeFunctionAppPath -FunctionName "test2").getType() |  Should -be "AzFunction"
            }

            it " get-azFuncFunctionApp Should not Throw" {
                { get-azFuncFunctionApp -FunctionAppName "Test"  -FunctionAppPath $fakeFunctionAppPath } |  Should -not -Throw 
            }

            $FunctionAppObject = get-azFuncFunctionApp -FunctionAppName "Test"  -FunctionAppPath $fakeFunctionAppPath


            it "get-azFuncFunctionApp  return a AzFunctionsApp Object" {
                $FunctionAppObject.getType() |  Should -be "AzFunctionsApp"
            }

            it "get-azFuncFunctionApp  return 1 Function" {
                $FunctionAppObject.functions.Count|  Should -be 1
            }

        }

    }


}


