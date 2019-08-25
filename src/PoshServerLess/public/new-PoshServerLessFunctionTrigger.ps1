function new-PoshServerlessFunctionTrigger 
{
    
    <#
    .SYNOPSIS
    
    Create an AzFunctionTrigger
    
    .DESCRIPTION
    
    Create an AzFunctionTrigger
    There are 5 types
    queueTrigger, timerTrigger, serviceBusTrigger, httpTrigger, blobTrigger
    


    .PARAMETER BindingName
    In or Out
    Queue binding accept only Out direction
    
        
    .EXAMPLE
    
   

           
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