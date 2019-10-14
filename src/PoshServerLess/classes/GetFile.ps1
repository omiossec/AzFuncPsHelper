
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