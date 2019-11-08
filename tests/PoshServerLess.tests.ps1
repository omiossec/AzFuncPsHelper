param (
    $BuildModulePath=$Env:BUILD_SOURCESDIRECTORY,
    $ModuleName = $ENV:ModuleName,
    $ModuleVersion = $ENV:ModuleVersion
)

$ModuleManifestPath = "$($BuildModulePath)\generated\$($ModuleName)\$($ModuleName).psd1"

Get-Module -Name $ModuleName | remove-module

#Install-Module Az -Force -AllowClobber
#import-module -name AZ 


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
        Context "$($ModuleName) integration test" {



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
$NewFunctionPath = join-path "testdrive:\" -ChildPath "New"
$NewFunctionPathApp = join-path $NewFunctionPath -ChildPath "NewFunctionApp"

$NewFunctionPathHostJson = (join-path $NewFunctionPathApp -ChildPath "host.json")
$NewFunctionPathProfile = (join-path $NewFunctionPathApp -ChildPath "profile.ps1")
$NewFunctionPathEequirements = (join-path $NewFunctionPathApp -ChildPath "requirements.psd1")
$fakeFunctionJsonPath = (join-path $fakeFunctionPath -ChildPath "function.json")




new-item -path $fakeFunctionPath -ItemType Directory
new-item -path $fakeFunctionBinPath -ItemType Directory
new-item -path $fakeFUnctionAppHostJson -ItemType File
Set-Content $fakeFunctionJsonPath -value $FakeFunctionJsonData -Encoding utf8

$FunctionApp =  new-PoshServerlessFunctionApp -FunctionAppPath $fakeFunctionAppPath -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
$Function = new-PoshServerlessFunction -FunctionAppObject $FunctionApp -FunctionName MyTest2 -OverWrite 

$trigger = new-PoshServerlessFunctionTrigger -TriggerType httpTrigger -TriggerName testHttp -methods @("POST")

            It "Should not Throw when create a new function" {
                { new-PoshServerLessFunction -FunctionAppObject $FunctionApp  -FunctionName "TimerFunction" } | Should -not -Throw 
            }

            it "Should not throw when reading an existing function" {
                { get-PoshServerlessFunction -FunctionName TimerFunction -FuncationApp $FunctionApp } | Should -not -Throw 
            }

            it "Function App is a AzFunction Object " {
                $FunctionApp.getType().toString()  | Should -be "AzFunctionsApp"
            }

            it 'Do not throw when creating an http Binding' {
                {  new-PoshServerlessFunctionBinding -Direction "out" -BindingName "outHttp" -BindingType "http" }  | Should -not -Throw 
            }

            it 'Do not throw when creating an http Trigger' {
                { new-PoshServerlessFunctionTrigger -TriggerType httpTrigger -TriggerName testHttp -methods @("POST") }  | Should -not -Throw 
            }

            it 'Do not throw when creating an http Binding' {
                {  new-PoshServerlessFunctionBinding -Direction "out" -BindingName "outHttp" -BindingType "http" }  | Should -not -Throw 
            }

            it 'Do not throw when creating a queue Binding' {
                { new-PoshServerlessFunctionBinding -Direction "out" -BindingName "MyBinding" -BindingType "queue" -queueName "test" -connection "MyStorage" }  | Should -not -Throw 
            }
            
            $Function = new-PoshServerlessFunction -FunctionAppObject $FunctionApp -FunctionName MyTest2 -OverWrite 

            $trigger = new-PoshServerlessFunctionTrigger -TriggerType httpTrigger -TriggerName testHttp -methods @("POST")
            $outHttp = new-PoshServerlessFunctionBinding -Direction "out" -BindingName "outHttp" -BindingType "http" 
            $outQueue = new-PoshServerlessFunctionBinding -Direction "out" -BindingName "MyBinding" -BindingType "queue" -queueName "test" -connection "MyStorage"
        
            it "trigger should not be null" {
                $trigger | Should -Not -BeNullOrEmpty 
            }

            it "outHttp should not be null" {
                $outHttp | Should -Not -BeNullOrEmpty 
            }

            it "outQueue should not be null" {
                $outQueue | Should -Not -BeNullOrEmpty 
            }

            update-PoshServerlessFunctionTrigger -triggerObject $trigger -FunctionObject $Function
            add-PoshServerlessFunctionBinding -BindingObject $outHttp -FunctionObject $Function
            add-PoshServerlessFunctionBinding -BindingObject $outQueue -FunctionObject $Function

             
            it "get-PoshServerlessFunctionBinding  return the correct number of binding " {
                (get-PoshServerlessFunctionBinding -FunctionObject  $Function).count | Should -be 2
            }

            it "get-PoshServerlessFunctionTrigger  return the correct value " {
                (get-PoshServerlessFunctionTrigger -FunctionObject  $Function).TriggerType | Should -be "httpTrigger"
            }

            it " new-PoshServerlessFunction  return a AzFunction Object" {
                (new-PoshServerlessFunction -FunctionAppObject $FunctionApp -FunctionName "TEST3" -OverWrite ).getType() |  Should -be "AzFunction"
            }

            it " get-PoshServerlessFunctionApp Should not Throw" {
                { get-PoshServerlessFunctionApp -FunctionAppName "MyFunction01"  -FunctionAppPath $fakeFunctionAppPath } |  Should -not -Throw 
            }

            add-PoshServerLessFunctionToApp -FunctionObject $Function -FunctionAppObject $FunctionApp


            it "get-PoshServerlessFunctionApp  return a AzFunctionsApp Object" {
                $FunctionApp.getType() |  Should -be "AzFunctionsApp"
            }

            it "get-PoshServerlessFunctionApp  return 1 Function" {
                $FunctionApp.azfunctions.Count |  Should -be 1
            }

            it "new-PoshServerlessFunctionTrigger with QueueTrigger Should not Throw" {
                { new-PoshServerlessFunctionTrigger -TriggerType queueTrigger -TriggerName que -connection con -queueName de } |  Should -not -Throw 
            }

            it "new-PoshServerlessFunctionTrigger with blobTrigger Should not Throw" {
                { new-PoshServerlessFunctionTrigger -TriggerType blobTrigger -TriggerName test -connection test -path path } |  Should -not -Throw 
            }

            it "new-PoshServerlessFunctionTrigger with timerTrigger Should not Throw" {
                { new-PoshServerlessFunctionTrigger -TriggerType timerTrigger -TriggerName test -Schedule "test" } |  Should -not -Throw 
            }

        
        }

    }


}


