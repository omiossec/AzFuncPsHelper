$Storage = Get-AzStorageAccount -ResourceGroupName "poshserverless-test" -Name poshserverlessaaf34

$a =Get-AzWebApp -ResourceGroupName "poshserverless-test" -Name "poshserverlessa001" 


$a = Get-AzStorageFile -ShareName "poshserverlessa001af34"  -Context $Storage.Context -Path /site/wwwroot  | Get-AzStorageFile


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
        elseif ($fileobject.name -ne "Microsoft") {
            
            $azPath = $AzurePath + "/" +$fileobject.Name
           
            $FolderPath = join-path -Path $localPath -ChildPath ($azPath.replace("/site/wwwroot/","")).replace("/","\")

            new-item -Path $FolderPath -ItemType Directory | Out-Null

            $fileobject = Get-AzStorageFile -ShareName $AzureStorageShareName -Context $context -Path $azPath | Get-AzStorageFile
            GetFile -CloudFilesObject $fileobject -context $context -AzurePath $azPath -LocalPath $localPath -AzureStorageShareName $AzureStorageShareName 
        }
    }
}


#GetFile -CloudFilesObject $a -context $Storage.Context -AzurePath "/site/wwwroot" -LocalPath "C:\work\lab\testfunctions\a" -AzureStorageShareName "poshserverlessa001af34"