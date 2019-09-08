



class AzFunctionsApp {

    [string] $FunctionAppName
    [string] $FunctionAppPath
    [string] $RessourceGroup
    [string] $FunctionHostName
    [string] $FunctionAppStorageName
    [string] $FunctionAppStorageShareName
    [string] $FunctionAppLocation
    
    hidden [Boolean] $FunctionAppExistLocaly = $false
    [hashtable] $functionAppExtension = @{}
    [hashtable] $FunctionAppSettings = @{}
    [AzFunction[]] $Azfunctions = @()

    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath) {
        $this.init($FunctionAppName, $functionAppPath)
    }

    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath, [string] $RessourceGroup) {
        $this.init($FunctionAppName, $functionAppPath, $RessourceGroup)
    }


    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath, [string] $RessourceGroup, [string] $AzureLocation) {
        $this.init($FunctionAppName, $functionAppPath, $RessourceGroup, $AzureLocation)
    }

    hidden init([string] $FunctionAppName, [string] $functionAppPath) {
        $this.FunctionAppName = $FunctionAppName
        $this.FunctionAppPath = $functionAppPath
        $this.ListFunction()      
    }

    hidden init([string] $FunctionAppName, [string] $functionAppPath, [string] $FunctionResourceGroup, [string] $FunctionAppLocation) {

        $this.FunctionAppName = $FunctionAppName
        $this.FunctionAppPath = join-path -path  $functionAppPath -ChildPath $this.FunctionAppName
        $this.FunctionAppLocation = $FunctionAppLocation
        $this.RessourceGroup = $FunctionResourceGroup

        if (!(test-path -Path $this.FunctionAppPath  -ErrorAction SilentlyContinue)) {
            try {
                new-item -Path $this.FunctionAppPath -ItemType Directory

                $Functionrequirements = "@{ 'Az' = '1.*'`" }"

                $FunctionHostConfig = @{
                    "version" = "2.0"
                    "functionTimeout" = "00:05:00"
                    "extensionBundle" = @{
                            "id" = "Microsoft.Azure.Functions.ExtensionBundle"
                            "version"= "[1.*, 2.0.0)"
                        }
                     "logging"= @{
                        "logLevel"= @{
                            "default"= "Information"
                             }
                      "fileLoggingMode"= "always"
                        }
                  "managedDependency"= @{
                    "enabled"= $true
                    }
                }
                
                $profileConfig = "if (`$env:MSI_SECRET -and (Get-Module -ListAvailable Az.Accounts)) { Connect-AzAccount -Identity }"

                new-item -Path (join-path $this.FunctionAppPath -ChildPath "profile.ps1") -ItemType File | Set-Content -PassThru -Encoding utf8 -Value $profileConfig
                new-item -Path (join-path $this.FunctionAppPath -ChildPath "requirements.psd1") -ItemType File | Set-Content -PassThru -Encoding utf8 -Value $Functionrequirements.ToString()
                new-item -Path (join-path $this.FunctionAppPath -ChildPath "host.json") -ItemType File | Set-Content -PassThru -Encoding utf8 -Value ($FunctionHostConfig | convertTo-json -Depth 4)

           } 
           catch {
                Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
           }           
        }
        else {
            throw "Can not create a function app in $($this.FunctionAppPath)"
        }


    }

    hidden init([string] $FunctionAppName, [string] $functionAppPath, [string] $FunctionResourceGroup) {

        if ($this.TestAzConnection()) {
            try {
                $FunctionAppConfig = Get-AzWebApp -ResourceGroupName $FunctionResourceGroup -Name $FunctionAppName 

                $this.FunctionAppName = $FunctionAppName
                $this.FunctionAppPath = $functionAppPath
                $this.RessourceGroup = $FunctionResourceGroup

                $this.FunctionAppLocation = $FunctionAppConfig.Location
                $this.FunctionHostName = $FunctionAppConfig.HostNames[0]
                $WorkerRuntime = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_WORKER_RUNTIME").Value
                $FunctionExtVerion = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_EXTENSION_VERSION").Value
                
                $this.FunctionAppStorageShareName = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "WEBSITE_CONTENTSHARE").Value
                $FunctionStorageConfigString = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "AzureWebJobsStorage").Value
                $FunctionStorageConfigHash = ConvertFrom-StringData -StringData $FunctionStorageConfigString.Replace(";","`r`n")
                
                $this.FunctionAppStorageName = $FunctionStorageConfigHash.AccountName
                $this.FunctionAppSettings = $FunctionStorageConfigHash

                if ($FunctionExtVerion -ne "~2") {
                    throw "Error this module only support Azure functions v2 with PowerShell"
                }

                $storageAccountObject = Get-AzStorageAccount -ResourceGroupName $FunctionResourceGroup -Name $FunctionStorageConfigHash.AccountName

                $StorageFileObject = Get-AzStorageFile -ShareName $this.FunctionAppStorageShareName  -Context $storageAccountObject.Context -Path "/site/wwwroot"  | Get-AzStorageFile
           
                GetFile -CloudFilesObject $StorageFileObject -context $storageAccountObject.Context -AzurePath "/site/wwwroot" -LocalPath $functionAppPath -AzureStorageShareName $this.FunctionAppStorageShareName
                
                $this.ListFunction()
            }
            catch {
                Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }
        }
        else {
            throw "Not connected to Azure, use Login-AzAccount first"
        }
    }

    hidden [void] ListFunction () {

        try {
            if (test-path -Path $this.FunctionAppPath -ErrorAction SilentlyContinue) {
                $this.FunctionAppExistLocaly = $true
                $FunctionList = get-childitem -Path $this.FunctionAppPath -Exclude @("microsoft","bin","obj", "modules") -Directory
            
                foreach ($function in $FunctionList) {
                    
                    $functionPath = join-path -Path $this.FunctionAppPath -ChildPath $function.name
                    $this.Azfunctions += [AzFunction]::new( $FunctionPath, $true)
    
                }
    
                if (test-path -Path (join-path -Path $this.FunctionAppPath -ChildPath "extensions.csproj") -ErrorAction SilentlyContinue) {
    
                    [xml] $CsPRojetExtenstionItem = Get-Content -Path (join-path -Path $this.FunctionAppPath -ChildPath "extensions.csproj")
    
                    foreach ($extension in $CsPRojetExtenstionItem.Project.ItemGroup.PackageReference) {
                        
                        $this.functionAppExtension.Add($extension.Include, $extension.Version)
    
                    }
                }
               
            }
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
 
    }



    [void] RemoveFunction ([string] $Functionname) {

        $NewFunctiongArray = @()
        $functionPath = $null

        foreach ($Azfunction in $this.Azfunctions){

            if ($Azfunction.FunctionName -ne $Functionname) {
               
                $NewFunctiongArray += $Azfunction
            }
            else {
                $functionPath = $Azfunction.FunctionPath
            }

        }

        $this.Azfunctions = $NewFunctiongArray

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

            $this.Azfunctions += $FunctionObject
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

    

    [void] PublishFunctionApp () {

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



function GetFile (
    [object[]] $CloudFilesObject, 
    [Microsoft.WindowsAzure.Commands.Common.Storage.LazyAzureStorageContext] $context, 
    [string] $AzurePath= "/site/wwwroot", 
    [string] $LocalPath,
    [String] $AzureStorageShareName
    ) { 

    foreach  ($CloudFile in $CloudFilesObject) {

        $fileobject = Get-AzStorageFile -ShareName $AzureStorageShareName -Context $context -Path $AzurePath | Get-AzStorageFile | where-object name -eq $CloudFile.name

        if ($fileobject.GetType().ToString() -eq "Microsoft.Azure.Storage.File.CloudFile") {
            
            $relative = $AzurePath.replace("/site/wwwroot","")
            $relative = $relative.replace("/","\")
            $relative = Join-Path -Path $LocalPath -ChildPath $relative
            $relative = Join-Path -Path $relative -ChildPath $fileobject.Name
                     
            $fileobject | Get-AzStorageFileContent -Destination $relative

        }
        elseif (($fileobject.name -ne "Microsoft") -or ($fileobject.name -ne "bin") ) {
            
            $azPath = $AzurePath + "/" +$fileobject.Name
           
            $FolderPath = join-path -Path $localPath -ChildPath ($azPath.replace("/site/wwwroot/","")).replace("/","\")

            new-item -Path $FolderPath -ItemType Directory | Out-Null

            $fileobject = Get-AzStorageFile -ShareName $AzureStorageShareName -Context $context -Path $azPath | Get-AzStorageFile
            GetFile -CloudFilesObject $fileobject -context $context -AzurePath $azPath -LocalPath $localPath -AzureStorageShareName $AzureStorageShareName 
        }
    }
}