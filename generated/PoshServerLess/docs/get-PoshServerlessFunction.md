---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# get-PoshServerlessFunction

## SYNOPSIS
Read a specific Azure Function from a path

## SYNTAX

```
get-PoshServerlessFunction [-FunctionPath] <String> [-OverWrite] [<CommonParameters>]
```

## DESCRIPTION
Read a specific Azure Function from a path

## EXAMPLES

### EXAMPLE 1
```
get-PoshServerlessFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction"
```

Load the function TimerFunction from the FunctionAppFolder

### EXAMPLE 2
```
get-PoshServerlessFunction -FunctionPath "c:\work\functionAppFolder\TimerFunction" -OverWrite
```

Load the function TimerFunction from the FunctionAppFolder and tell the module to overwrite the function folder

## PARAMETERS

### -FunctionPath
{{ Fill FunctionPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OverWrite
switch Specifies if the AZFunc Module should recreate the folder 
Default $false, in this case the module only rewrite the function.json

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### AzFunction object
## NOTES

## RELATED LINKS
