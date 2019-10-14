
class AzFunction {

    [string] $FunctionName
    [string] $FunctionPath
    [AzFunctionsTrigger] $TriggerBinding
    [AzFunctionsBinding[]] $Binding = @()
    [Boolean] $overwrite
    [Boolean] $FunctionExist = $false
    [string] $JsonFunctionBindings
    [string] $Runtime

    hidden Init([string] $FunctionName, [string] $FunctionPath, [Boolean] $overwrite= $false) {

        $this.overwrite = $overwrite
        $this.FunctionName = $FunctionName
        $this.FunctionPath = $FunctionPath

        $this.TestFunctionPath();

        if ($this.FunctionExist) {
            $this.LoadFunction()
        }

       
        
    }

    hidden [void] TestFunctionPath() {       
        $this.FunctionExist=  test-path -Path $this.FunctionPath -ErrorAction SilentlyContinue
    }

    hidden [Boolean] TestHttpOutBinding() {
        $HttpControl = $false
        if ($this.TriggerBinding.TriggerType -eq "http") { 
            foreach ($binding in $this.Binding) {
                if (($binding.BindingDirection -eq "out") -and ($binding.BindingType -eq "http")) {
                    $HttpControl = $true
                }
            }
        } else {
            $HttpControl = $true
        }
        return $HttpControl
    }

    [void] BuildJsonFunction() {

        $FunctionBinding = New-Object System.Collections.ArrayList 

        $FunctionBinding.add($this.TriggerBinding)

        foreach ($binding in $this.Binding) {
            $FunctionBinding.add($binding)
        }

        $this.JsonFunctionBindings = @{"disabled"=$false; "bindings"=$FunctionBinding} | ConvertTo-Json -Depth 5

    }
    
    AzFunction ([string] $FunctionName, [string] $FunctionPath) {

        $this.init($FunctionName, $FunctionPath, $false)

    }

    AzFunction ([string] $FunctionPath, [Boolean] $overwrite) {

         

        $this.init((split-path -Path $FunctionPath -Leaf),  $FunctionPath, $overwrite)

    }

    AzFunction ([string] $FunctionName, [string] $FunctionPath, [Boolean] $overwrite) {

        $this.init( $FunctionName, $FunctionPath, $overwrite)
    }

    [void] AddBinding ([AzFunctionsBinding]$BindingObject) {
       

        $this.Binding += $BindingObject
        
    }

    [void] AddBindings ([AzFunctionsBinding[]]$BindingObjects) {
         foreach ($bindingObject in $BindingObjects) {
             $this.AddBinding($bindingObject)
         }
    }


    [void] AddTriger ([AzFunctionsTrigger]$Triger) {
        $this.TriggerBinding = $Triger
    }

    [Boolean] testAzFunction () {
        
        
        if (($this.Binding.count -ge 1) -and ($this.TriggerBinding.TriggerType -eq "http") ) {
            return $true
        }
        elseif (($this.Binding.count -ge 0) -and ($this.TriggerBinding.TriggerType -ne "http") -and ($null  -ne $this.TriggerBinding) ) {
            return $true
        }
        else {
            return $false
        }

    }

    [boolean] TestAzFuncBinding ([string] $BindingName) {

        $SearchResult = $false 

        foreach ($binding in $this.Binding){

            if ($binding.BindingName -eq $BindingName) {
                $SearchResult = $true 
            }

        }


        return $SearchResult
    }

    [void] RemoveAzFuncBinding ([string] $BindingName) {

        $NewBindingArray = @()

        foreach ($binding in $this.Binding){

            if ($binding.BindingName -ne $BindingName) {
               
                $NewBindingArray += $binding
            }

        }

        $this.Binding = $NewBindingArray

    }

    [void] WriteFunction () {
        
        $FunctionConfigFile = join-path -Path $this.FunctionPath -ChildPath "function.json"
       
        if ($this.testAzFunction() -and $this.TestHttpOutBinding()) {

            if ((test-path -Path $FunctionConfigFile -ErrorAction SilentlyContinue)) {
                try {
                     remove-item -Path $FunctionConfigFile -Force
                } 
                catch {
                     Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
                }
     
             }
     
             if (!(test-path -Path $this.FunctionPath  -ErrorAction SilentlyContinue)) {
                 try {
                     new-item -Path $this.FunctionPath -ItemType Directory
                } 
                catch {
                     Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
                }           
             }
     
             try {
                 new-item -ItemType File -Path $FunctionConfigFile 
     
                 $this.BuildJsonFunction()
         
                 Set-Content -Value $this.JsonFunctionBindings -Path $FunctionConfigFile -Encoding utf8
             }
             catch {
                 Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
             }
        }
        else {  
            throw "You can not have a function without trigger or a http trigger without a http out binding"
        }



    }

    [void] LoadFunction () {
        $FunctionConfigFile = join-path -Path $this.FunctionPath -ChildPath "function.json"
        if ((test-path -Path $FunctionConfigFile -ErrorAction SilentlyContinue)) {

            try {
                $FunctionJsonConfig = Get-Content $FunctionConfigFile -Raw | ConvertFrom-Json

                ForEach ($Binding in $FunctionJsonConfig.bindings) {
                
                    if ($Binding.Type -like "*Trigger") {
    
                        switch ($Binding.Type) {
                            "timerTrigger" { 
                                $this.AddTriger([timerTrigger]::new($Binding.name, $Binding.Schedule))
                                
                             }
                             "queueTrigger" {
                                
                                $this.AddTriger([queueTrigger]::new($Binding.name, $Binding.queueName, $Binding.connection))
                             }
                             "serviceBusTrigger" {
                                $this.AddTriger([serviceBusTrigger]::new($Binding.name, $Binding.queueName, $Binding.connection))
    
                             }
                             "blobTrigger" {
                                $this.AddTriger( [blobTrigger]::new($Binding.name, $Binding.path, $Binding.connection))
                             }
                             "httpTrigger" {
                                $this.AddTriger( [httpTrigger]::new($Binding.name, $Binding.authLevel, $Binding.methods))
                             }
                        }
                    }
                    else {
                        
                        switch ($Binding.Type) { 
                            "http" {
                                $this.AddBinding([http]::new($Binding.name))
                            }
                            "table" {
                                if ($Binding.Direction -eq "in") {
                                    
                                    [tableIn]$TableInBinding = [tableIn]::new($Binding.name, $Binding.tableName, $Binding.connection)
    
                                    if ($null -ne $Binding.partitionKey) {
                                        $TableInBinding.partitionKey = $Binding.partitionKey
                                    }
    
                                    if ($null -ne $Binding.rowKey) {
                                        $TableInBinding.rowKey = $Binding.rowKey
                                    }
    
                                    if ($null -ne $Binding.take) {
                                        $TableInBinding.take = $Binding.take
                                    }
    
                                    if ($null -ne $Binding.filter) {
                                        $TableInBinding.filter = $Binding.filter
                                    }
    
                                    $this.AddBinding($TableInBinding)
                                }
                                else {
                                    $this.AddBinding( [table]::new($Binding.name, $Binding.tableName, $Binding.connection))
                                }
                            }
                            "blob" {
                                
                                $this.AddBinding([blob]::new($Binding.direction, $Binding.name, $Binding.path, $binding.connection))
                                
                            }
                            "queue" {
                                $this.AddBinding([queue]::new($Binding.name, $Binding.queueName , $Binding.connection))
    
                            }
    
                        }
    
                    }
    
                }
    
                
            }
            catch [System.ArgumentException] {
                Write-Error -Message "Error while reading the json file"
            }
            catch {
                Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }

        }
    }


}

