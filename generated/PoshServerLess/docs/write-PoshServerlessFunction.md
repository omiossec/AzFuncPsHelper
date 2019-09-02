---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# write-PoshServerlessFunction

## SYNOPSIS
Update a function.json file (and the run.ps1) from the azFunctionObject

## SYNTAX

```
write-PoshServerlessFunction [-FunctionObject] <AzFunction> [<CommonParameters>]
```

## DESCRIPTION
Update a function.json file (and the run.ps1) from the azFunctionObject

## EXAMPLES

### EXAMPLE 1
```
$AzFunctionObject | write-PoshServerlessFunction
```

## PARAMETERS

### -FunctionObject
Specifies the function Object

```yaml
Type: AzFunction
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
