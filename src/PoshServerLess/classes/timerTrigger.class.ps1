class timerTrigger : AzFunctionsTrigger {

    [string] $Schedule

    timerTrigger ([string] $triggerName, [string] $Schedule) {
        $this.TriggerType = "timerTrigger"
        $this.TriggerName = $triggerName    
        $this.Schedule = $Schedule 
    }
}