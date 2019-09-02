---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# test-PoshServerlessFunctionBinding

## SYNOPSIS
Test if a binding exist in a AzFunc Object

## SYNTAX

```
test-PoshServerlessFunctionBinding [-FunctionObject] <AzFunction> [-BindingName] <String> [<CommonParameters>]
```

## DESCRIPTION
Test if a binding exist in a AzFunc Object, by BindingName
Return a boolean 
True if the Binding exist
False if the bindind do not exist

## EXAMPLES

### EXAMPLE 1
```
test-PoshServerlessFunctionBinding -FunctionObject $FunctionObject -BindingName BindingNameToTest
```

## PARAMETERS

### -FunctionObject
The AzFunction Object to test

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

### -BindingName
The Binding name to test (string)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Boolean
## NOTES

## RELATED LINKS
