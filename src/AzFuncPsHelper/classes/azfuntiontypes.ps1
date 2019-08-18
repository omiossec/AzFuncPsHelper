enum BindingIn {
    blob
    table
    

}

enum Bindingout {
    queue
    blob
    table
    http
}

enum Trigger {
    timerTrigger
    serviceBusTrigger
    queueTrigger
    httpTrigger
    blobTrigger
}

enum Direction {
    in
    out
}

class AzFunctionsApp {

    [string] $FunctionAppName
    [string] $FunctionAppPath
    hidden [Boolean] $FunctionAppExistLocaly = $false
    [hashtable] $functionAppExtension
    [AzFunction[]] $functions = @()

    hidden init([string] $FunctionAppName, [string] $functionAppPath) {

        $this.FunctionAppName = $FunctionAppName
        $this.FunctionAppPath = $functionAppPath

        if (test-path -Path $this.FunctionAppPath -ErrorAction SilentlyContinue) {
            $this.FunctionAppExistLocaly = $true
            $FunctionList = get-childitem -Path $this.FunctionAppPath -Exclude @("microsoft","bin","obj", "modules") -Directory
        
            foreach ($function in $FunctionList) {
                
                $functionPath = join-path -Path $this.FunctionAppPath -ChildPath $function.name
                $this.functions += [AzFunction]::new( $FunctionPath, $true)

            }

            if (test-path -Path (join-path -Path $this.FunctionAppPath -ChildPath "extensions.csproj") -ErrorAction SilentlyContinue) {

                [xml] $CsPRojetExtenstionItem = Get-Content -Path (join-path -Path $this.FunctionAppPath -ChildPath "extensions.csproj")

                foreach ($extension in $CsPRojetExtenstionItem) {

                    $this.functionAppExtension.Add($extension.Include, $extension.Version)

                }
            }
           
        }
        
    }

    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath) {
        $this.init($FunctionAppName, $functionAppPath)
    }



}


class AzFunction {

    [string] $FunctionName
    [string] $FunctionPath
    [AzFunctionsTrigger] $TriggerBinding
    [AzFunctionsBinding[]] $Binding = @()
    [Boolean] $overwrite
    [Boolean] $FunctionExist = $false
    [string] $JsonFunctionBindings

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

    hidden [void] ControlHttpBing() {
        if ($this.TriggerBinding.TriggerType -eq "http") {


        }
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
       
        if ( $null -ne $this.Binding) {
            $this.Binding.count
        }
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

        if (($this.TriggerBinding.count -gt 1) -and ($this.TriggerBinding.TriggerType -eq "http") ) {
            return $true
        }
        elseif (($this.TriggerBinding.count -ge 0) -and ($this.TriggerBinding.TriggerType -ne "http") ) {
            return $true
        }
        else {
            return $false
        }

    }

    [void] WriteFunction () {
        $FunctionConfigFile = join-path -Path $this.FunctionPath -ChildPath "function.json"
        if ((test-path -Path $FunctionConfigFile -ErrorAction SilentlyContinue)) {
            remove-item -Path $FunctionConfigFile -Force
        }

        new-item -ItemType File -Path $FunctionConfigFile 

        $this.BuildJsonFunction()

        Set-Content -Value $this.JsonFunctionBindings -Path $FunctionConfigFile -Encoding utf8
    }

    [void] LoadFunction () {
        $FunctionConfigFile = join-path -Path $this.FunctionPath -ChildPath "function.json"
        if ((test-path -Path $FunctionConfigFile -ErrorAction SilentlyContinue)) {

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
    }


}



class AzFunctionsTrigger {
    
    [string] $TriggerType
    [string] $TriggerName
    [string] hidden $direction = "in"
}

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

class timerTrigger : AzFunctionsTrigger {

    [string] $Schedule

    timerTrigger ([string] $triggerName, [string] $Schedule) {
        $this.TriggerType = "timerTrigger"
        $this.TriggerName = $triggerName    
        $this.Schedule = $Schedule 
    }
}

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

class httpTrigger : AzFunctionsTrigger {

    [string] $authLevel
    [string[]] $methods = @()

    httpTrigger ([string] $triggerName, [string] $authLevel, [string[]] $methods) {
        $this.TriggerType = "httpTrigger"
        $this.TriggerName = $triggerName 
        $this.methods += $methods
        $this.authLevel = $authLevel
    }

}

class blobTrigger : AzFunctionsTrigger {

    [string] $path
    [string] $connection

    blobTrigger ([string] $triggerName, [string] $path, [string] $connection) {
        $this.TriggerType = "blobTrigger"
        $this.TriggerName = $triggerName 
        $this.connection = $connection
        $this.path = $path
    }
}

class AzFunctionsBinding {

    [string] $BindingName
    [string] $BindingDirection
    

}

class blob : AzFunctionsBinding {
    [String] $path
    [string] $connection

    blob([string]$direction, [string]$name, [String] $Path, [string] $connection){
        $this.BindingDirection = $direction
        $this.BindingName = $name
        $this.path = $Path
        $this.connection = $connection
        
    }
    

}

class http : AzFunctionsBinding {

    
    http ([string] $Name) {
        $this.BindingName = $Name
        $this.BindingDirection = "out"
    }
}

class queue : AzFunctionsBinding {
    [string] $queueName
    [string] $connection

    queue ([string] $Name, [string] $QueuName, [string] $connection) {
        $this.BindingName = $Name
        $this.connection = $Connection
        $this.queueName = $QueuName
        $this.BindingDirection = "out"
    }
}


class table : AzFunctionsBinding {

    
    [string] $connection
    [string] $tableName
    
    table([String]$Name, [string] $tableName, [string] $Connection) {
        $this.BindingName = $Name
        $this.connection = $Connection
        $this.tableName = $tableName
        $this.BindingDirection = "out"
    }
}

class tableIn : AzFunctionsBinding {

    [string] $connection
    [string] $tableName
    [string] $partitionKey
    [string] $rowkey
    [int] $take
    [string] $filter

    tableIn([String]$Name, [string] $tableName, [string] $Connection) {
        $this.BindingName = $Name
        $this.connection = $Connection
        $this.tableName = $tableName
        $this.BindingDirection = "in"
    }

}
