Function TestAzConnection () {

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