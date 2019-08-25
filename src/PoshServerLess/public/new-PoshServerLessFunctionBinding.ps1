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