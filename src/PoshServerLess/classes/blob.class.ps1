class blob : AzFunctionsBinding {
    [String] $path
    [string] $connection

    blob([string]$direction, [string]$name, [String] $Path, [string] $connection){
        $this.BindingDirection = $direction
        $this.BindingName = $name
        $this.path = $Path
        $this.connection = $connection
        $this.BindingType = "blob"
        
    }

}