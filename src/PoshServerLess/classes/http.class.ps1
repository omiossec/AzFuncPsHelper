class http : AzFunctionsBinding {

    
    http ([string] $Name) {
        $this.BindingName = $Name
        $this.BindingDirection = "out"
        $this.BindingType = "http"
    }
}