function write-azFuncFunction 
{
    <#
    .SYNOPSIS
    
    Update a function.json file (and the run.ps1) from the azFunctionObject
    
    .DESCRIPTION
    
    Update a function.json file (and the run.ps1) from the azFunctionObject
    
    .PARAMETER FunctionObject
    Specifies the function Object
    


   
    .EXAMPLE  
    $AzFunctionObject | write-azFuncFunction 
           
    #>


    [CmdletBinding()]
    param(


        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ValueFromPipeline = $true)]
        [AzFunction]
        $FunctionObject

    )

  
        $FunctionObject.WriteFunction()

  

}