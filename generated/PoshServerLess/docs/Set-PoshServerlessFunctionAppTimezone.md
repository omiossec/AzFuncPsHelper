---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# Set-PoshServerlessFunctionAppTimezone

## SYNOPSIS
Set the time zone setting for the function app object

## SYNTAX

```
Set-PoshServerlessFunctionAppTimezone [-FunctionAppObject] <AzFunctionsApp> [-TimeZone] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Set the time zone setting for the function app object
To take effect the function need be initialised either by sync-PoshServerlessFunctionApp or new-PoshServerLessFunctionApp

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -FunctionAppObject
{{ Fill FunctionAppObject Description }}

```yaml
Type: AzFunctionsApp
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -TimeZone
string Representing the timezone see

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

## NOTES

## RELATED LINKS
