
class AzFunctionsApp {

    [string] $FunctionAppName
    [string] $FunctionAppPath
    [string] $RessourceGroup
    [string] $FunctionHostName
    hidden [Boolean] $FunctionAppExistLocaly = $false
    [hashtable] $functionAppExtension = @{}
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

                foreach ($extension in $CsPRojetExtenstionItem.Project.ItemGroup.PackageReference) {
                    
                    $this.functionAppExtension.Add($extension.Include, $extension.Version)

                }
            }
           
        }
        
    }

    [void] RemoveFunction ([string] $Functionname) {

        $NewFunctiongArray = @()
        $functionPath = $null

        foreach ($Azfunction in $this.functions){

            if ($Azfunction.FunctionName -ne $Functionname) {
               
                $NewFunctiongArray += $Azfunction
            }
            else {
                $functionPath = $Azfunction.FunctionPath
            }

        }

        $this.functions = $NewFunctiongArray

        if ($null -ne $functionPath) {

            try {
                remove-item -path $functionPath -Force -Recurse
            }
            catch {
                Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }
        }   

    }

    [void] AddFunction ([AzFunction] $FunctionObject) {

        

        if ( (Split-Path -Path $FunctionObject.FunctionPath -Parent) -eq $this.FunctionAppPath) {

            if (!(test-path -Path $FunctionObject.FunctionPath -ErrorAction SilentlyContinue)) {
                $FunctionObject.WriteFunction()
            }

            $this.functions += $FunctionObject
        }
        else {
            throw "The Path of The function $($FunctionObject.FunctionName) should be the same as the the Function App"
        }


        
    }

    [boolean] FunctionAppCreated () {
        return $false
    }

    [void] deployFunctionApp () {

    }

    [void] getFunctiondeploymentStatus ([String] $DeployementUserName, [String] $DeployementPassword) {

    }

    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath) {
        $this.init($FunctionAppName, $functionAppPath)
    }

    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath, [string] $RessourceGroup) {
        $this.init($FunctionAppName, $functionAppPath, $RessourceGroup)
    }

    [void] PublishFunctionApp ([String] $DeployementUserName, [String] $DeployementPassword ) {

        $FunctionZippedFolderPath = $this.CompressFunction()

        if ($null -ne $FunctionZippedFolderPath) {

            try {
                Publish-AzWebapp -ResourceGroupName $this.RessourceGroup -Name $this.FunctionAppName -ArchivePath $FunctionZippedFolderPath -force
            }
            catch {
                Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }

        }
        else {
            throw "Zip file $($FunctionZippedFolderPath) not found"
        }
    }

    [string] CompressFunction () {

        try {
            $TmpFuncZipDeployFileName = [System.IO.Path]::GetRandomFileName()
            $TmpFuncZipDeployFileName = $TmpFuncZipDeployFileName.remove($TmpFuncZipDeployFileName.Length - 4) + ".zip"
            
            $TmpFuncZipDeployPath = join-path -Path $ENV:tmp -ChildPath $TmpFuncZipDeployFileName

            

            $excludeFilesAndFolders = @(".git",".vscode","bin","Microsoft",".funcignore",".gitignore")

            $FileToSendArray = @()

            foreach ($file in get-childitem -Path $this.FunctionAppPath) {
                    if ($file.name -notin $excludeFilesAndFolders) {
                        $FileToSendArray += $file.fullname
                    }
            }

            compress-archive -Path $FileToSendArray -DestinationPath $TmpFuncZipDeployPath
            return $TmpFuncZipDeployPath
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            return $null
        }

        
    }

    

    [boolean] TestAzConnection () {

        try {
            $AzContext = get-azContext 
            if ($null -eq $AzContext) {
                return $false
            }
            else {
                return $true
            }
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            write-error "No AZURE PowerShell module"
            return $false
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            return $false
        }
         
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
    [string] $BindingType
    

}

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

class http : AzFunctionsBinding {

    
    http ([string] $Name) {
        $this.BindingName = $Name
        $this.BindingDirection = "out"
        $this.BindingType = "http"
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
        $this.BindingType = "queue"
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
        $this.BindingType = "table"
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
        $this.BindingType = "table"
    }

}

