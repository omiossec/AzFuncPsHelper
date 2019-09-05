function new-PoshServerlessFunctionTrigger 
{
    
    <#
    .SYNOPSIS
    
    Create an AzFunctionTrigger
    
    .DESCRIPTION
    
    Create an AzFunctionTrigger
    There are 5 types
    queueTrigger, timerTrigger, serviceBusTrigger, httpTrigger, blobTrigger
    
    .PARAMETER TriggerType
    Kind of trigger "queueTrigger","timerTrigger", "httpTrigger","serviceBusTrigger","blobTrigger"

    .PARAMETER TriggerName
    Name of the trigger. The name will be use in the run.ps1 as a parameter

    .PARAMETER connection
    The name of AppSetting for the storage configuration

    .PARAMETER queueName
    For queue trigger only, Name of the queue in the storage

    .PARAMETER ServiceBusqueueName
    For Service Bus trigger only, Name of the queue in the storage

    .PARAMETER Schedule
    For timer trigger only, the schedule in a cron format, 0 * 8 * * *

    .PARAMETER methods
    For web trigger only, Allowed HTTP verbs @("POST", "GET")

    .PARAMETER authLevel
    For web trigger only, authorisation level 
    anonymous no API key needed
    function the function App key is needed 
    admin the function master key is needed (this key can be also use in scm)

    .PARAMETER authLevel
    For blob trigger only, path in the storage account the function will monitor container/{name}



path
    
        
    .EXAMPLE
    
    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

           
    #>


    [OutputType([AzFunctionsTrigger])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [ValidateSet("queueTrigger","timerTrigger", "httpTrigger","serviceBusTrigger","blobTrigger")]
        [string]
        $TriggerType,   

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [string]
        $TriggerName,   

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [string]
        $connection,    

        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [string]
        $queueName, 

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [string]
        $ServiceBusqueueName, 

        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [string]
        $Schedule, 

        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [string[]]
        $methods, 

        [parameter( ParameterSetName = "httpTrigger")]
        [ValidateSet("function","admin")]
        [string]
        $authLevel = "function", 

        [parameter(Mandatory = $true,  ParameterSetName = "blobTrigger")]
        [string]
        $path 
    )

    switch ($PSCmdlet.ParameterSetName) {
        "queueTrigger" {
            return [queueTrigger]::new($triggerName,  $queueName, $connection)
        }
        "blobTrigger" {
            return [blobTrigger]::new($triggerName,  $path, $connection)
        }
        "httpTrigger" {
            return [httpTrigger]::new($triggerName, $authLevel, $methods)
        }
        "timerTrigger" {
            return [timerTrigger]::new($triggerName,  $Schedule)
        }
        "serviceBusTrigger" {
            return [serviceBusTrigger]::new($triggerName,  $ServiceBusqueueName, $connection)
        }

    }



}