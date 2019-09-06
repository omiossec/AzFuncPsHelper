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