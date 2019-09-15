---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# get-PoshServerlessFunctionTrigger

## SYNOPSIS
retreive trigger object from a AzFunc Object

## SYNTAX

```
get-PoshServerlessFunctionTrigger [-FunctionObject] <AzFunction> [<CommonParameters>]
```

## DESCRIPTION
retreive trigger object from a AzFunc Object

## EXAMPLES

### EXAMPLE 1
```
$FunctionObjectVar | get-PoshServerlessFunctionBinding
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

### AzFunctionsTrigger
## NOTES

## RELATED LINKS
