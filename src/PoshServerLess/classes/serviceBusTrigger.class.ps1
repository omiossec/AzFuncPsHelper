class serviceBusTrigger : AzFunctionsTrigger {

    [string] $queueName
    [string] $connection

    serviceBusTrigger ([string] $triggerName, [string] $queueName, [string] $Connection) {
        $this.TriggerType = "serviceBusTrigger"
        $this.TriggerName = $triggerName 
        $this.queueName = $queueName
        $this.connection = $Connection
    }
}