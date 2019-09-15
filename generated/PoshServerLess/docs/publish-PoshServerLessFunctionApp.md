---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# publish-PoshServerLessFunctionApp

## SYNOPSIS
Publish the function to Azure

## SYNTAX

```
publish-PoshServerLessFunctionApp [-FunctionAppObject] <AzFunctionsApp> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Publish the function app to Azure
This action will replace all the functions inside Azure by those in the function app Object
You need to have a valid ResourceGroup in the object (for example by using sync-PoshServerlessFunctionApp)

## EXAMPLES

### EXAMPLE 1
```
$myFunctionApp = sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction'
```

$myFunction = new-PoshServerlessFunction -FunctionAppPath "c:\work\Myfunction\timerfunc" -FunctionName "TimerFunction"

$TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage

update-PoshServerlessFunctionTrigger -FunctionObject myFunction -TriggerObject $TriggerObject

add-PoshServerLessFunctionToApp -FunctionObject $myFunction -FunctionAppObject $myFunctionApp

publish-PoshServerLessFunctionApp -FunctionAppObject $myFunctionApp

## PARAMETERS

### -FunctionAppObject
Specifies the function Object

```yaml
Type: AzFunctionsApp
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
