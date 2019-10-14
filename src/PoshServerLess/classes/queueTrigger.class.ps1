class queueTrigger : AzFunctionsTrigger {

    [string] $queueName
    [string] $connection 

    queueTrigger ([string] $triggerName, [String] $queueName, [string] $connection) {

        $this.TriggerType = "queueTrigger"
        $this.TriggerName = $triggerName
        $this.connection = $connection
        $this.queueName = $queueName

    }

}