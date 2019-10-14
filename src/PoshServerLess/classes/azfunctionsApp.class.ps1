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


    AzFunctionsApp ([string] $FunctionAppName, [string] $functionAppPath, [string] $RessourceGroup, [string] $AzureLocation, [string] $runtime) {
        $this.init($FunctionAppName, $functionAppPath, $RessourceGroup, $AzureLocation, $runtime)
        
    }

    hidden init([string] $FunctionAppName, [string] $functionAppPath) {
        $this.FunctionAppName = $FunctionAppName
        $this.FunctionAppPath = $functionAppPath
        $this.ListFunction()      
    }

    hidden init([string] $FunctionAppName, [string] $functionAppPath, [string] $FunctionResourceGroup, [string] $FunctionAppLocation,  [string] $FunctionRuntime) {

        $this.FunctionAppName = $FunctionAppName
        $this.FunctionAppPath = join-path -path  $functionAppPath -ChildPath $this.FunctionAppName
        $this.FunctionAppLocation = $FunctionAppLocation
        $this.RessourceGroup = $FunctionResourceGroup
        $this.FunctionRuntime = $FunctionRuntime

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

        if (TestAzConnection)  {
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

                #$this.GetAppSettings($FunctionAppConfig.SiteConfig.AppSettings)

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

    [Boolean] TestFunctionAppExistInAzure () {
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
            exit
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

        #$this.GetAppSettings($FunctionAppConfig.SiteConfig.AppSettings)

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

        try {
            if ($null -ne $this.RessourceGroup) {
                Set-AzWebApp -AppSettings $this.FunctionAppSettings -Name $this.FunctionAppName -ResourceGroupName $this.RessourceGroup
            } else {
                throw "You can't update App Settings as the object do not have any resource group, add a resource group"
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

  

 
    [String] deployFunctionApp ([bool] $ManagedIdentity=$true) {
        try {
            
            if (  -not $this.TestFunctionAppExistInAzure() ) {

                $ModulePath = $PSScriptRoot 
               
                $jsonArmTemplatePath = Join-Path -Path $ModulePath -ChildPath "function.json"
                $jsonArmTemplateObject = (Get-Content -Path $jsonArmTemplatePath  -Raw | ConvertFrom-Json -AsHashtable)
                $DeploiementName = CreateUniqueString -BufferSize 15

                $DeployParam = @{
                    
                    "mode" = "Incremental"
                    "ResourceGroupName" = $this.RessourceGroup
                    "TemplateObject" = $jsonArmTemplateObject
                    "functionAppName" = $this.FunctionAppName
                }

                if ($null -ne $this.FunctionAppLocation) {
                    $DeployParam.add("location", $this.FunctionAppLocation)
                }

                if (! $ManagedIdentity) {
                    $DeployParam.add("ManagedIdentity", "no")
                } else {
                    $DeployParam.add("ManagedIdentity", "yes")
                }

                # implemente test 

                $DeployParam.add("name", $DeploiementName)
                

                New-AzResourceGroupDeployment @DeployParam

                #New-AzResourceGroupDeployment -Name $DeploiementName -mode Incremental -ResourceGroupName $this.RessourceGroup -TemplateObject $jsonArmTemplateObject -functionAppName $this.FunctionAppName
                return $DeploiementName
            }
            else {
                throw "The Azure Functions App $($this.FunctionAppName) all ready exist in Azure"
                return $null
            }
        }
        catch {
            Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            exit
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
    
}