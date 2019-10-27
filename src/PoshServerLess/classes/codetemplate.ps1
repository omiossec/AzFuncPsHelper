function createCodeTemplate (
    [system.object] $ParameterList,
    [string] $Language
    ) {
    
        $HttpUsing = "using namespace System.Net"
         
        switch ($Language) {

            "powershell" {
                $codetemplate = "param("
                $FunctionParams = @()
                
                foreach ($Param in $ParameterList){
                     
                    if ($Param.type -eq "httpTrigger") {
                        $codetemplate = $HttpUsing + "`n" + $codetemplate
                        $FunctionParams +=  "`$" + $Param.name
                    }
                    elseif ($Param.type -eq "blob" -OR $Param.type -eq "blobtrigger") {
                        $FunctionParams +=  "[byte[]] `$" + $Param.name
                    } else {
                        $FunctionParams +=  "`$" + $Param.name
                    }
                    
                }
                $codetemplate += ($FunctionParams -join ",") + ",`$TriggerMetadata)"
            }

        }


        return $codetemplate



}