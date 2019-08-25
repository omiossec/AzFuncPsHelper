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

$FunctionFakeObject = get-PoshServerlessFunction -FunctionPath $fakeFunctionPath 

            It "Should not Throw when create a new function" {
                { new-PoshServerlessFunction -FunctionAppPath $fakeFunctionAppPath -FunctionName "FakeFunction2" } | Should -not -Throw 
            }

            it "Should not throw when reading an existing function" {
                { get-PoshServerlessFunction -FunctionPath $fakeFunctionPath } | Should -not -Throw 
            }

            it "get-PoshServerlessFunction return a AzFunction Object " {
                $FunctionFakeObject.getType()   | Should -be "AzFunction"
            }
             
            it "get-PoshServerlessFunctionBinding  return the correct number of binding " {
                (get-PoshServerlessFunctionBinding -FunctionObject  $FunctionFakeObject).count | Should -be 6
            }

            it "get-PoshServerlessFunctionTrigger  return the correct value " {
                (get-PoshServerlessFunctionTrigger -FunctionObject  $FunctionFakeObject).TriggerType | Should -be "timerTrigger"
            }

            it " new-PoshServerlessFunction  return a AzFunction Object" {
                (new-PoshServerlessFunction  -FunctionAppPath  $fakeFunctionAppPath -FunctionName "test2").getType() |  Should -be "AzFunction"
            }

            it " get-PoshServerlessFunctionApp Should not Throw" {
                { get-PoshServerlessFunctionApp -FunctionAppName "Test"  -FunctionAppPath $fakeFunctionAppPath } |  Should -not -Throw 
            }

            $FunctionAppObject = get-PoshServerlessFunctionApp -FunctionAppName "Test"  -FunctionAppPath $fakeFunctionAppPath


            it "get-PoshServerlessFunctionApp  return a AzFunctionsApp Object" {
                $FunctionAppObject.getType() |  Should -be "AzFunctionsApp"
            }

            it "get-PoshServerlessFunctionApp  return 1 Function" {
                $FunctionAppObject.functions.Count|  Should -be 1
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

            it "new-PoshServerlessFunctionTrigger with httpTrigger Should not Throw" {
                { new-PoshServerlessFunctionTrigger -TriggerType httpTrigger -TriggerName test -methods @("post","get") } |  Should -not -Throw 
            }

            it "test-PoshServerlessFunctionBinding with outputQueueItem and $FunctionFakeObject Should not Throw" {
                { test-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "outputQueueItem" } |  Should -not -Throw 
            }


            it "test-PoshServerlessFunctionBinding with outputQueueItem and $FunctionFakeObject return $true" {
                (test-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "outputQueueItem") |  Should -be $true
            }

            it "test-PoshServerlessFunctionBinding with fakeBinding and $FunctionFakeObject return $false" {
                (test-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "fakeBinding") |  Should -be $false
            }

            it "remove-PoshServerlessFunctionBinding with FakeBinding and $FunctionFakeObject Should  Throw" {
                { remove-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "FakeBinding" } |  Should -Throw 
            }

            # Removing a Binding

            it "remove-PoshServerlessFunctionBinding with outputQueueItem and $FunctionFakeObject Should not Throw" {
                { remove-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "outputQueueItem" } |  Should -not -Throw 
            }

            it "remove-PoshServerlessFunctionBinding with NotExistingBinding and $FunctionFakeObject Should not Throw" {
                { remove-PoshServerlessFunctionBinding -FunctionObject $FunctionFakeObject -BindingName "NotExistingBinding" } |  Should  -Throw 
            }


            

            it "get-PoshServerlessFunctionBinding  should return the correct number of binding, 5 after " {
                (get-PoshServerlessFunctionBinding -FunctionObject  $FunctionFakeObject).count | Should -be 5
            }

            # create a new function
            $NewFakeFunction = new-PoshServerlessFunction -FunctionAppPath $fakeFunctionAppPath -FunctionName "TestFunc02"



            it "Generate and error When try to create a function without any trigger" {
                {  write-PoshServerlessFunction  -FunctionObject $NewFakeFunction } | Should  -Throw 
            }

            $trigger = new-PoshServerlessFunctionTrigger -TriggerType httpTrigger -TriggerName testHttp -methods @("POST")

            

            it "Generate and error When try to create an HTTP function without a out binding" {
                {  write-PoshServerlessFunction  -FunctionObject $NewFakeFunction } | Should -Throw 
            }

            update-PoshServerlessFunctionTrigger -triggerObject $trigger -FunctionObject $NewFakeFunction

            it "Doesn't fail when creating an Http out binding" {
                {$HttpOutBinding = new-PoshServerlessFunctionBinding -Direction "out" -BindingName "outHttp" -BindingType "http"} | Should -not -Throw 
            }



            it "do not generate and error When try to create a function with trigger" {
                {  write-PoshServerlessFunction  -FunctionObject $NewFakeFunction } | Should -not -Throw 
            }
            
        }

    }


}


