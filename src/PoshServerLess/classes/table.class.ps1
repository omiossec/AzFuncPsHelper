class table : AzFunctionsBinding {

    
    [string] $connection
    [string] $tableName
    
    table([String]$Name, [string] $tableName, [string] $Connection) {
        $this.BindingName = $Name
        $this.connection = $Connection
        $this.tableName = $tableName
        $this.BindingDirection = "out"
        $this.BindingType = "table"
    }
}