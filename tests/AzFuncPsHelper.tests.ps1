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
        Context "$ModuleName Cmdlet testing" {

            $fakeFunctionAppName = "functionApp"
            $fakeFunctionName = "testFunc"

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
            
        }

    }


}


