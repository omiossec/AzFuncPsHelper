
class AzFunctionsApp {

    [string] $FunctionAppName
    [string] $FunctionAppPath
    [string] $RessourceGroup
    [string] $FunctionHostName
    [string] $FunctionAppStorageName
    [string] $FunctionAppStorageShareName
    [string] $FunctionAppLocation
    [string] $FunctionTimeZone
    [string] $FunctionRuntime = "PowerShell"
    
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
                
                $this.FunctionAppPath = join-path -Path $functionAppPath -ChildPath $FunctionAppName
                $this.RessourceGroup = $FunctionResourceGroup

                $this.FunctionAppLocation = $FunctionAppConfig.Location
                $this.FunctionHostName = $FunctionAppConfig.HostNames[0]
                $This.FunctionRuntime = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_WORKER_RUNTIME").Value
                $FunctionExtVerion = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_EXTENSION_VERSION").Value
                
                $this.FunctionTimeZone = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "WEBSITE_TIME_ZONE").Value

                $this.FunctionAppStorageShareName = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "WEBSITE_CONTENTSHARE").Value
                $FunctionStorageConfigString = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "AzureWebJobsStorage").Value
                $FunctionStorageConfigHash = ConvertFrom-StringData -StringData $FunctionStorageConfigString.Replace(";","`r`n")
                
                $this.FunctionAppStorageName = $FunctionStorageConfigHash.AccountName
                $this.FunctionAppSettings = $FunctionStorageConfigHash

                $this.GetAppSettings($FunctionAppConfig.SiteConfig.AppSettings)

                if ($FunctionExtVerion -ne "~2") {
                    throw "Error this module only support Azure functions v2 with PowerShell"
                }

                $storageAccountObject = Get-AzStorageAccount -ResourceGroupName $FunctionResourceGroup -Name $FunctionStorageConfigHash.AccountName

                $StorageFileObject = Get-AzStorageFile -ShareName $this.FunctionAppStorageShareName  -Context $storageAccountObject.Context -Path "/site/wwwroot"  | Get-AzStorageFile
           
                GetFile -CloudFilesObject $StorageFileObject -context $storageAccountObject.Context -AzurePath "/site/wwwroot" -LocalPath $this.FunctionAppPath -AzureStorageShareName $this.FunctionAppStorageShareName
                
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

    hidden [Boolean] TestFunctionAppExistInAzure () {
        try {
            $DnsResolve = Resolve-DnsName -Name "$($this.FunctionAppName).azurewebsites.net" -ErrorAction SilentlyContinue
            if ($null -eq $DnsResolve) {
                return $false
            } else {
                return $true
            }
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            return $false
        }       
    }

    hidden [void] CreateFunctionAppInAzure () {

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

    [void] GetAppSettings ([Collections.Generic.List[Microsoft.Azure.Management.WebSites.Models.NameValuePair]] $AppSettingList) {

        foreach ($appSetting in $AppSettingList) {
            write-verbose "Adding Key $($appSetting.name) / Value $($appSetting.value)"
            $this.FunctionAppSettings.Add($appSetting.name, $appSetting.value)
        }
    }

    [void] LoadFunctionFromAzure ([string] $RessourceGroup) {

        $this.RessourceGroup = $RessourceGroup

        $FunctionAppConfig = Get-AzWebApp -ResourceGroupName $this.RessourceGroup -Name $this.FunctionAppName 
        

        $this.FunctionAppLocation = $FunctionAppConfig.Location
        $this.FunctionHostName = $FunctionAppConfig.HostNames[0]
        $This.FunctionRuntime = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_WORKER_RUNTIME").Value
        $FunctionExtVerion = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "FUNCTIONS_EXTENSION_VERSION").Value
        
        $this.FunctionTimeZone = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "WEBSITE_TIME_ZONE").Value

        $this.FunctionAppStorageShareName = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "WEBSITE_CONTENTSHARE").Value
        $FunctionStorageConfigString = ($FunctionAppConfig.SiteConfig.AppSettings | where-object name -eq "AzureWebJobsStorage").Value
        $FunctionStorageConfigHash = ConvertFrom-StringData -StringData $FunctionStorageConfigString.Replace(";","`r`n")
        
        $this.FunctionAppStorageName = $FunctionStorageConfigHash.AccountName
        $this.FunctionAppSettings = $FunctionStorageConfigHash

        $this.GetAppSettings($FunctionAppConfig.SiteConfig.AppSettings)

        if ($FunctionExtVerion -ne "~2") {
            throw "Error this module only support Azure functions v2 with PowerShell"
        }

    }

    [void] UpdateAppSetting ([string] $Name, [string] $Value) {

        if ($null -eq $this.FunctionAppSettings[$name] ) {
            $this.FunctionAppSettings.add($name,$value)        
        }elseif ($name -in @("FUNCTIONS_WORKER_RUNTIME","AzureWebJobsStorage","FUNCTIONS_EXTENSION_VERSION","WEBSITE_CONTENTAZUREFILECONNECTIONSTRING","WEBSITE_CONTENTSHARE")) {
            throw "You can not change this function App Setting, FUNCTIONS_WORKER_RUNTIME,AzureWebJobsStorage,FUNCTIONS_EXTENSION_VERSION,WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,WEBSITE_CONTENTSHARE"
        }
        else {
            $this.FunctionAppSettings[$name] = $value
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
        try {

        }
        catch {

        }
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
            $relativeLocalPath = Join-Path -Path $LocalPath -ChildPath $relative
            $RelativeFilePath = Join-Path -Path $relativeLocalPath -ChildPath $fileobject.Name
            write-verbose "Copy $($fileobject.Name) File to path $($RelativeFilePath) Path $($LocalPath )"
            $fileobject | Get-AzStorageFileContent -Destination $RelativeFilePath

        }
        elseif (($fileobject.name -ne "Microsoft") -and ($fileobject.name -ne "bin") ) {
            
            $azPath = $AzurePath + "/" +$fileobject.Name
           
            $FolderPath = join-path -Path $localPath -ChildPath ($azPath.replace("/site/wwwroot/","")).replace("/","\")

            new-item -Path $FolderPath -ItemType Directory | Out-Null

            $fileobject = Get-AzStorageFile -ShareName $AzureStorageShareName -Context $context -Path $azPath | Get-AzStorageFile
            GetFile -CloudFilesObject $fileobject -context $context -AzurePath $azPath -LocalPath $localPath -AzureStorageShareName $AzureStorageShareName 
        }
    }
}

function getMsTimeZone () {

    $ModulePath = $PSScriptRoot 

    try {
        $jsonArmTemplatePath = Join-Path -Path $ModulePath -ChildPath "function.json"
        $ObjectData = (Get-Content -Path $jsonArmTemplatePath  -Raw | ConvertFrom-Json)

        return $ObjectData.parameters.timezone.allowedValues

    }
    catch {
        Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
    }

}

function TestModulePresent ([string] $moduleName="Az") {

    return ! $null -eq (get-module -ListAvailable | where-object name -eq $moduleName)
}


function TestAzureConnection () {

    try {
        $null = Get-AzContext
        return $true
    }
    catch {
        return $false
    }
}
function add-PoshServerlessFunctionBinding 
{

    <#
    .SYNOPSIS
    
    Add a Binding object to an existing azFunction Object
    
    .DESCRIPTION
    
    Add a Binding object to an existing azFunction Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER BindingObject
    Specifie the Binding Object


    
    .EXAMPLE
    $MyFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\functionAppFolder\" -FunctionName "TimerFunction"
    $Biding = new-PoshServerlessFunctionBinding -Direction out -BindingName MyBinding -BindingType queue -connection MyStorage

    add-PoshServerlessFunctionBinding -FunctionObject $MyFunction -BindingObject $Biding

           
    #>

    
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsBinding]
        $BindingObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionObject.AddBinding($BindingObject)

}
function add-PoshServerLessFunctionToApp 
{

    <#
    .SYNOPSIS
    
    Add a function object to an existing Function App Object
    
    .DESCRIPTION
    
    Add a function object to an existing Function App Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER FunctionAppObject
    Specifie the function App Object
  
    .EXAMPLE
    add-PoshServerLessFunctionToApp -FunctionObject $MyNewFunction -FunctionAppObject $MyApp
           
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionAppObject.AddFunction($FunctionObject)

}
function get-PoshServerlessFunction 
{
<#
.SYNOPSIS

Read a specific Azure Function from a path

.DESCRIPTION

Read a specific Azure Function from a path


.PARAMETER Path
Specifies the function path

.PARAMETER OverWrite
switch Specifies if the AZFunc Module should recreate the folder 
Default $false, in this case the module only rewrite the function.json

.OUTPUTS

AzFunction object

.EXAMPLE

get-PoshServerlessFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction"
Load the function TimerFunction from the FunctionAppFolder 

.EXAMPLE

get-PoshServerlessFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction" -OverWrite
Load the function TimerFunction from the FunctionAppFolder and tell the module to overwrite the function folder

#>

    [OutputType([AzFunction])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateScript({Test-Path $_\function.json})]
        [string]
        $FunctionPath,

        [switch]
        $OverWrite 

    )

    return [AzFunction]::new($FunctionPath, $OverWrite)

}
function get-PoshServerlessFunctionApp
{

    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [ValidateScript({Test-Path $_\host.json})]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppName

    )

    return [AzFunctionsApp]::new($FunctionAppName, $FunctionAppPath)





}
function get-PoshServerlessFunctionBinding 
{

    <#
    .SYNOPSIS
    
    retreive Binding from a AzFunc Object
    
    .DESCRIPTION
    
    retreive Binding from a AzFunc Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
        
    .EXAMPLE
    
    $FunctionObjectVar | get-PoshServerlessFunctionBinding 
    

           
    #>

    [OutputType([AzFunctionsBinding[]])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

    return $FunctionObject.Binding
    
}
function get-PoshServerlessFunctionTrigger
{
    
    <#
    .SYNOPSIS
    
    retreive trigger object from a AzFunc Object
    
    .DESCRIPTION
    
    retreive trigger object from a AzFunc Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
        
    .EXAMPLE
    
    $FunctionObjectVar | get-PoshServerlessFunctionBinding 
    

           
    #>

    [OutputType([AzFunctionsTrigger])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

    return $FunctionObject.TriggerBinding

}
function new-PoshServerlessFunction 
{
    <#
    .SYNOPSIS
    
    Create a new azure function object
    
    .DESCRIPTION
    
    Create a new azure function object
    The FunctionAppPath and the name parameter will build the function path 
    
    .PARAMETER FunctionAppPath
    Specifies the function App path
    
    .PARAMETER FunctionName
    Specifie the name of the function. 

    .PARAMETER OverWrite
    switch Specifies if the AZFunc Module should recreate the function folder if exist
    Default $false, in this case the module only rewrite the function.json
    
    .OUTPUTS
    
    AzFunction object
    
    .EXAMPLE
    
    new-PoshServerlessFunction -FunctionAppPath "c:\work\functionAppFolder\" -FunctionName "TimerFunction"
    create a new azFunction Object
           
    #>
    [OutputType([AzFunction])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionName,

        [switch]
        $OverWrite 
    )

    $functionPath = join-path -Path $FunctionAppPath -ChildPath $FunctionName

    return [AzFunction]::new($FunctionName,$FunctionPath, $OverWrite)

}
function new-PoshServerlessFunctionApp {
    <#
    .SYNOPSIS
    
    Create a new azure function App object and the function app file
    
    .DESCRIPTION
    
    Create a new azure function App object and the function app file
    It doesn't create the function in Azure
    
    .PARAMETER FunctionAppPath
    Specifies the function App local path, this path must not exist
    
    .PARAMETER FunctionAppName
    The host name of the function App. This Name must be globally unique 

    .PARAMETER FunctionAppLocation
    The Function App desired location

    .PARAMETER FunctionAppResourceGroup
    The Function App desired Resource Group
    
    .OUTPUTS
    
    AzFunctionsApp object
    
    .EXAMPLE
    
    new-PoshServerlessFunctionApp -FunctionAppPath "c:\work\functionAppFolder\" -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
    create a new azFunction Object
           
    #>
    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppPath,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionAppName,

        [string]
        [ValidateSet("UKSouth", "UKWest", "NorthEurope","WestEurope",	"FranceCentral","SouthAfricaNorth","CentralIndia",	"SouthIndia","WestIndia","JapanEast","JapanWest","KoreaCentral", 
        "EastAsia","SoutheastAsia","AustraliaCentral", "AustraliaCentral2",	"AustraliaEast", "AustraliaSoutheast", "BrazilSouth", "CanadaCentral",
        "CanadaEast", "ChinaEast","ChinaEast2",	"ChinaNorth", "GermanyCentral", "GermanyNortheast","WestUS",
        "WestUS2", "CentralUS", "EastUS","EastUS2","NorthCentralUS","SouthCentralUS","WestCentralUS"
        )]
        $FunctionAppLocation,

        [string]
        $FunctionAppResourceGroup
    )

  
        return [AzFunctionsApp]::new($FunctionAppName,$FunctionAppPath, $FunctionAppResourceGroup, $FunctionAppLocation)


}











function new-PoshServerlessFunctionBinding 
{
    
    <#
    .SYNOPSIS
    
    Create an AzfunctionBinding object 
    
    .DESCRIPTION
    
    Create an AzfunctionBinding object 
    There are two types of Direction In and Out
    and "blob","http","queue", "table"

    
    .PARAMETER Direction
    In or Out
    Queue binding accept only Out direction

    .PARAMETER BindingName
    In or Out
    Queue binding accept only Out direction
    
        
    .EXAMPLE
    
    $Biding = new-PoshServerlessFunctionBinding -Direction out -BindingName MyBinding -BindingType queue -connection MyStorage

           
    #>

    [OutputType([AzFunctionsBinding])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName = "blob")]
        [parameter(Mandatory = $true, ParameterSetName = "queue")]
        [parameter(Mandatory = $true, ParameterSetName = "table")]
        [parameter(Mandatory = $true, ParameterSetName = "http")]
        [ValidateSet("in","Out")]
        [string]
        $Direction, 

        [parameter(Mandatory = $true, ParameterSetName = "blob")]
        [parameter(Mandatory = $true, ParameterSetName = "queue")]
        [parameter(Mandatory = $true, ParameterSetName = "table")]
        [parameter(Mandatory = $true, ParameterSetName = "http")]
        [string]
        $BindingName,       

        [parameter(Mandatory = $true, ParameterSetName = "blob")]
        [parameter(Mandatory = $true, ParameterSetName = "queue")]
        [parameter(Mandatory = $true, ParameterSetName = "table")]
        [parameter(Mandatory = $true, ParameterSetName = "http")]
        [ValidateSet("blob","http","queue", "table")]
        [string]
        $BindingType,   


       [parameter(Mandatory = $true, ParameterSetName = "blob")]
       [string]
       $Path,    

       [parameter(Mandatory = $true, ParameterSetName = "blob")]
       [parameter(Mandatory = $true, ParameterSetName = "queue")]
       [parameter(Mandatory = $true, ParameterSetName = "table")]
       [string]
       $connection,    


       [parameter(Mandatory = $true, ParameterSetName = "queue")]
       [string]
       $queueName,    

       [parameter(Mandatory = $true, ParameterSetName = "table")]
       [string]
       $tableName,  

       [parameter(ParameterSetName = "table")]
       [string]
       $partitionKey, 

       [parameter(ParameterSetName = "table")]
       [string]
       $rowkey, 

       [parameter(ParameterSetName = "table")]
       [int]
       $take, 

       [parameter(ParameterSetName = "table")]
       [string]
       $filter 

    )



    switch ($PSCmdlet.ParameterSetName) {
        "blob" {
            return [blob]::new($direction, $BindingName, $Path, $connection)
        }
        "table" {
            if ($direction -eq "in") {
                $tableinObject =  [table]::new($BindingName,  $tableName, $Connection)

                if ($PSBoundParameters.ContainsKey('filter')) {
                    $tableinObject.filter = $filter
                }
                if ($PSBoundParameters.ContainsKey('take')) {
                    $tableinObject.take = $take
                }
                if ($PSBoundParameters.ContainsKey('rowkey')) {
                    $tableinObject.rowkey = $rowkey
                }
                if ($PSBoundParameters.ContainsKey('partitionKey')) {
                    $tableinObject.partitionKey = $partitionKey
                }
                return $tableinObject
            }
            else {
                return [table]::new($BindingName,  $tableName, $Connection)
            }
        }
        "queue" {
            return [queue]::new($BindingName, $QueuName, $connection)
        }
        "http" {
            return [http]::new($BindingName)
        }
    }

}
function new-PoshServerlessFunctionTrigger 
{
    
    <#
    .SYNOPSIS
    
    Create an AzFunctionTrigger
    
    .DESCRIPTION
    
    Create an AzFunctionTrigger
    There are 5 types
    queueTrigger, timerTrigger, serviceBusTrigger, httpTrigger, blobTrigger
    
    .PARAMETER TriggerType
    Kind of trigger "queueTrigger","timerTrigger", "httpTrigger","serviceBusTrigger","blobTrigger"

    .PARAMETER TriggerName
    Name of the trigger. The name will be use in the run.ps1 as a parameter

    .PARAMETER connection
    The name of AppSetting for the storage configuration

    .PARAMETER queueName
    For queue trigger only, Name of the queue in the storage

    .PARAMETER ServiceBusqueueName
    For Service Bus trigger only, Name of the queue in the storage

    .PARAMETER Schedule
    For timer trigger only, the schedule in a cron format, 0 * 8 * * *

    .PARAMETER methods
    For web trigger only, Allowed HTTP verbs @("POST", "GET")

    .PARAMETER authLevel
    For web trigger only, authorisation level 
    anonymous no API key needed
    function the function App key is needed 
    admin the function master key is needed (this key can be also use in scm)

    .PARAMETER authLevel
    For blob trigger only, path in the storage account the function will monitor container/{name}



path
    
        
    .EXAMPLE
    
    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

           
    #>


    [OutputType([AzFunctionsTrigger])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [ValidateSet("queueTrigger","timerTrigger", "httpTrigger","serviceBusTrigger","blobTrigger")]
        [string]
        $TriggerType,   

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [string]
        $TriggerName,   

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [parameter(Mandatory = $true, ParameterSetName = "blobTrigger")]
        [string]
        $connection,    

        [parameter(Mandatory = $true, ParameterSetName = "queueTrigger")]
        [string]
        $queueName, 

        [parameter(Mandatory = $true, ParameterSetName = "serviceBusTrigger")]
        [string]
        $ServiceBusqueueName, 

        [parameter(Mandatory = $true, ParameterSetName = "timerTrigger")]
        [string]
        $Schedule, 

        [parameter(Mandatory = $true, ParameterSetName = "httpTrigger")]
        [string[]]
        $methods, 

        [parameter( ParameterSetName = "httpTrigger")]
        [ValidateSet("function","admin")]
        [string]
        $authLevel = "function", 

        [parameter(Mandatory = $true,  ParameterSetName = "blobTrigger")]
        [string]
        $path 
    )

    switch ($PSCmdlet.ParameterSetName) {
        "queueTrigger" {
            return [queueTrigger]::new($triggerName,  $queueName, $connection)
        }
        "blobTrigger" {
            return [blobTrigger]::new($triggerName,  $path, $connection)
        }
        "httpTrigger" {
            return [httpTrigger]::new($triggerName, $authLevel, $methods)
        }
        "timerTrigger" {
            return [timerTrigger]::new($triggerName,  $Schedule)
        }
        "serviceBusTrigger" {
            return [serviceBusTrigger]::new($triggerName,  $ServiceBusqueueName, $connection)
        }

    }



}
function publish-PoshServerLessFunctionApp 
{
    <#
    .SYNOPSIS
    
    Publish the function to Azure
    
    .DESCRIPTION
    
    Publish the function app to Azure
    This action will replace all the functions inside Azure by those in the function app Object
    You need to have a valid ResourceGroup in the object (for example by using sync-PoshServerlessFunctionApp)
    
    .PARAMETER FunctionAppObject
    Specifies the function Object
    
    .EXAMPLE

    $myFunctionApp = sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction' 

    $myFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\Myfunction\timerfunc" -FunctionName "TimerFunction"

    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

    update-PoshServerlessFunctionTrigger -FunctionObject myFunction -TriggerObject $TriggerObject

    add-PoshServerLessFunctionToApp -FunctionObject $myFunction -FunctionAppObject $myFunctionApp

    publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp

           
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [ValidateNotNull()]
        [AzFunctionsApp]
        $FunctionAppObject

    )


    if ($PSCmdlet.ShouldProcess($FunctionAppObject.FunctionAppName,"Publish this Function to Azure, it will rewrite the entire App in Azure")) {

        $FunctionAppObject.PublishFunctionApp()

    }


}

function remove-PoshServerlesstionBinding 
{

    
}
function remove-PoshServerlessFunctionBinding {



    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $BindingName

    )

    if (test-PoshServerlessFunctionBinding -FunctionObject $FunctionObject -BindingName $BindingName) {
        $FunctionObject.RemoveAzFuncBinding($BindingName)
    }
    else {
        throw "Error: No Binding found"
    }

}
function remove-PoshServerLessFunctionToApp
{
    <#
    .SYNOPSIS
    
    Remove a function object to an existing Function App Object
    
    .DESCRIPTION
    
    Remove a function object to an existing Function App Object
    It also remove the function from the disk
    
    .PARAMETER FunctionName
    Specifies the function Name
    
    .PARAMETER FunctionAppObject
    Specifie the Binding Object


    
    .EXAMPLE
    
           
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $FunctionName

    )

    $FunctionAppObject.RemoveFunction($FunctionName)


}
function Resolve-PoshServerlessFunctionApp 
{
    <#
    .SYNOPSIS
    
    This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync
    
    .DESCRIPTION
    
    This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync
    
    .PARAMETER FunctionAppObject
    A [AzFunctionsApp] object

    .PARAMETER ResourceGroupName
    The name of the ressource Group

   
    .EXAMPLE  

    $FunctionApp = get-PoshServerlessFunctionApp -FunctionAppPath Path -FunctionAppName MyFuntion
    Resolve-PoshServerlessFunctionApp -FunctionAppObject $FunctionApp -ResourceGroupName MyRessourceGroup
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceGroupName

    )

    $FunctionAppObject.LoadFunctionFromAzure($ResourceGroupName)

}
function set-PoshServerlessFunctionAppSetting 
{
    <#
    .SYNOPSIS
    
    Add or Update an App Setting 
    
    .DESCRIPTION
    
    Add or Update an App Setting 
    
    
    .PARAMETER FunctionsAppObject
    The Function App object

    .PARAMETER AppSettingName
    string Representing the timezone see 
    the value can't be FUNCTIONS_WORKER_RUNTIME,AzureWebJobsStorage,FUNCTIONS_EXTENSION_VERSION,WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,WEBSITE_CONTENTSHARE

    .PARAMETER AppSettingValue
    string Representing the timezone see 
    
    .EXAMPLE
    

           
    #>


    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -notin @("FUNCTIONS_WORKER_RUNTIME","AzureWebJobsStorage","FUNCTIONS_EXTENSION_VERSION","WEBSITE_CONTENTAZUREFILECONNECTIONSTRING","WEBSITE_CONTENTSHARE")})]
        [string]
        $AppSettingName,

        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $AppSettingValue
    )

    write-vebose "Setting value for $($AppSettingName)"
    
}
function Set-PoshServerlessFunctionAppTimezone 
{

    <#
    .SYNOPSIS
    
    Set the time zone setting for the function app object
    
    .DESCRIPTION
    
    Set the time zone setting for the function app object
    To take effect the function need be initialised either by sync-PoshServerlessFunctionApp or new-PoshServerLessFunctionApp 
    
    .PARAMETER FunctionApp
    The Function App object

    .PARAMETER TimeZone
    string Representing the timezone see 


    
    .EXAMPLE
    

           
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsApp]
        $FunctionAppObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        [ValidateSet("Dateline Standard Time",
        "UTC-11",
        "Aleutian Standard Time",
        "Hawaiian Standard Time",
        "Marquesas Standard Time",
        "Alaskan Standard Time",
        "UTC-09",
        "Pacific Standard Time (Mexico)",
        "UTC-08",
        "Pacific Standard Time",
        "US Mountain Standard Time",
        "Mountain Standard Time (Mexico)",
        "Mountain Standard Time",
        "Central America Standard Time",
        "Central Standard Time",
        "Easter Island Standard Time",
        "Central Standard Time (Mexico)",
        "Canada Central Standard Time",
        "SA Pacific Standard Time",
        "Eastern Standard Time (Mexico)",
        "Eastern Standard Time",
        "Haiti Standard Time",
        "Cuba Standard Time",
        "US Eastern Standard Time",
        "Turks And Caicos Standard Time",
        "Paraguay Standard Time",
        "Atlantic Standard Time",
        "Venezuela Standard Time",
        "Central Brazilian Standard Time",
        "SA Western Standard Time",
        "Pacific SA Standard Time",
        "Newfoundland Standard Time",
        "Tocantins Standard Time",
        "E. South America Standard Time",
        "SA Eastern Standard Time",
        "Argentina Standard Time",
        "Greenland Standard Time",
        "Montevideo Standard Time",
        "Magallanes Standard Time",
        "Saint Pierre Standard Time",
        "Bahia Standard Time",
        "UTC-02",
        "Mid-Atlantic Standard Time",
        "Azores Standard Time",
        "Cape Verde Standard Time",
        "UTC",
        "Morocco Standard Time",
        "GMT Standard Time",
        "Greenwich Standard Time",
        "W. Europe Standard Time",
        "Central Europe Standard Time",
        "Romance Standard Time",
        "Sao Tome Standard Time",
        "Central European Standard Time",
        "W. Central Africa Standard Time",
        "Jordan Standard Time",
        "GTB Standard Time",
        "Middle East Standard Time",
        "Egypt Standard Time",
        "E. Europe Standard Time",
        "Syria Standard Time",
        "West Bank Standard Time",
        "South Africa Standard Time",
        "FLE Standard Time",
        "Israel Standard Time",
        "Kaliningrad Standard Time",
        "Sudan Standard Time",
        "Libya Standard Time",
        "Namibia Standard Time",
        "Arabic Standard Time",
        "Turkey Standard Time",
        "Arab Standard Time",
        "Belarus Standard Time",
        "Russian Standard Time",
        "E. Africa Standard Time",
        "Iran Standard Time",
        "Arabian Standard Time",
        "Astrakhan Standard Time",
        "Azerbaijan Standard Time",
        "Russia Time Zone 3",
        "Mauritius Standard Time",
        "Saratov Standard Time",
        "Georgian Standard Time",
        "Caucasus Standard Time",
        "Afghanistan Standard Time",
        "West Asia Standard Time",
        "Ekaterinburg Standard Time",
        "Pakistan Standard Time",
        "India Standard Time",
        "Sri Lanka Standard Time",
        "Nepal Standard Time",
        "Central Asia Standard Time",
        "Bangladesh Standard Time",
        "Omsk Standard Time",
        "Myanmar Standard Time",
        "SE Asia Standard Time",
        "Altai Standard Time",
        "W. Mongolia Standard Time",
        "North Asia Standard Time",
        "N. Central Asia Standard Time",
        "Tomsk Standard Time",
        "China Standard Time",
        "North Asia East Standard Time",
        "Singapore Standard Time",
        "W. Australia Standard Time",
        "Taipei Standard Time",
        "Ulaanbaatar Standard Time",
        "Aus Central W. Standard Time",
        "Transbaikal Standard Time",
        "Tokyo Standard Time",
        "North Korea Standard Time",
        "Korea Standard Time",
        "Yakutsk Standard Time",
        "Cen. Australia Standard Time",
        "AUS Central Standard Time",
        "E. Australia Standard Time",
        "AUS Eastern Standard Time",
        "West Pacific Standard Time",
        "Tasmania Standard Time",
        "Vladivostok Standard Time",
        "Lord Howe Standard Time",
        "Bougainville Standard Time",
        "Russia Time Zone 10",
        "Magadan Standard Time",
        "Norfolk Standard Time",
        "Sakhalin Standard Time",
        "Central Pacific Standard Time",
        "Russia Time Zone 11",
        "New Zealand Standard Time",
        "UTC+12",
        "Fiji Standard Time",
        "Kamchatka Standard Time",
        "Chatham Islands Standard Time",
        "UTC+13",
        "Tonga Standard Time",
        "Samoa Standard Time",
        "Line Islands Standard Time")]
        $TimeZone

    )


        $FunctionAppObject.UpdateAppSetting("WEBSITE_TIME_ZONE", $TimeZone)


}
function sync-PoshServerlessFunctionApp 
{
    <#
    .SYNOPSIS
    
    Download a function App content to the local workstation
    
    .DESCRIPTION
    
    Download a function App content to the local workstation
    this cmdlet use Azure PowerShell, you need to install it install-module -name AZ -scope CurrentUser
    You need a valid connexion to azure before, run login-azaccount before runing this cmdlet
    
    .PARAMETER FunctionName
    The function name in Azure 
    ex: MyPowerShellAzFunction 

    .PARAMETER ResourceGroupName
    The name of the ressouce group in Azure where the function app is 

    .PARAMETER LocalFunctionPath
    The local path to download Azure functions files and folder
    The path should be empty
    

   
    .EXAMPLE  
    sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction'           
    #>


    [OutputType([AzFunctionsApp])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [string]
        $FunctionAppName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $ResourceGroupName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $LocalFunctionPath

    )

    $FunctionPath = join-path -Path $LocalFunctionPath -ChildPath $FunctionAppName
    if (test-path -Path $LocalFunctionPath -ErrorAction SilentlyContinue) {

        

        if (test-path -Path $FunctionPath -ErrorAction SilentlyContinue) {
            throw "The Path of The function $($LocalFunctionPath) is not empty"
        }else {
            new-item -Path $FunctionPath -ItemType Directory | out-null
        }
        
      
    } else {
        try {
            new-item -Path $FunctionPath -ItemType Directory | out-null
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
    }


    return [AzFunctionsApp]::new($FunctionAppName, $LocalFunctionPath, $ResourceGroupName)

}
function test-PoshServerlessFunctionBinding 
{
    <#
    .SYNOPSIS
    Test if a binding exist in a AzFunc Object

    .DESCRIPTION
    Test if a binding exist in a AzFunc Object, by BindingName
    Return a boolean 
    True if the Binding exist
    False if the bindind do not exist

    .PARAMETER FunctionObject
    The AzFunction Object to test

    .PARAMETER BindingName
    The Binding name to test (string)

    .OUTPUTS
    Boolean

    .EXAMPLE

    test-PoshServerlessFunctionBinding -FunctionObject $FunctionObject -BindingName BindingNameToTest

    #>
    [OutputType([boolean])]
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]
        $BindingName

    )

    return $FunctionObject.TestAzFuncBinding($BindingName)
}
function update-PoshServerlessFunctionTrigger 
{

    <#
    .SYNOPSIS
    
    Update an AzFunction Object with a trigger Object
    
    .DESCRIPTION
    
    Update an AzFunction Object with a trigger Object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
    .PARAMETER TriggerObject
    Specifie the Trigger binding Object

   
    .EXAMPLE  

    $myFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\Myfunction\timerfunc" -FunctionName "TimerFunction"

    $TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

    update-PoshServerlessFunctionTrigger -FunctionObject myFunction -TriggerObject $TriggerObject
   
    #>

    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunctionsTrigger]
        $triggerObject,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [AzFunction]
        $FunctionObject

    )

    $FunctionObject.AddTriger($triggerObject)
    
}
function write-PoshServerlessFunction 
{
    <#
    .SYNOPSIS
    Update the function folder with the azFunctionObject object
    
    .DESCRIPTION
    Update the function folder with the azFunctionObject object
    
    .PARAMETER FunctionObject
    Specifies the function Object
    
   
    .EXAMPLE  
    $AzFunctionObject | write-PoshServerlessFunction 
           
    #>


    [CmdletBinding()]
    param(


        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

  
        $FunctionObject.WriteFunction()

  

}
