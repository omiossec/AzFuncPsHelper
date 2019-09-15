---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# write-PoshServerlessFunction

## SYNOPSIS
Update the function folder with the azFunctionObject object

## SYNTAX

```
write-PoshServerlessFunction [-FunctionObject] <AzFunction> [<CommonParameters>]
```

## DESCRIPTION
Update the function folder with the azFunctionObject object

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
