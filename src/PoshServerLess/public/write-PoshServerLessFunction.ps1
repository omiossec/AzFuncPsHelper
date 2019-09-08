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