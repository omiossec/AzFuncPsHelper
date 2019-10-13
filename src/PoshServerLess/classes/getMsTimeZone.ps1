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