---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# new-PoshServerlessFunction

## SYNOPSIS
Create a new azure function object

## SYNTAX

```
new-PoshServerlessFunction [-FunctionAppPath] <String> [-FunctionName] <String> [-OverWrite]
 [<CommonParameters>]
```

## DESCRIPTION
Create a new azure function object
The FunctionAppPath and the name parameter will build the function path

## EXAMPLES

### EXAMPLE 1
```
new-PoshServerlessFunction -FunctionAppPath "c:\work\functionAppFolder\" -FunctionName "TimerFunction"
```

create a new azFunction Object

## PARAMETERS

### -FunctionAppPath
Specifies the function App path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -FunctionName
Specifie the name of the function.

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

### -OverWrite
switch Specifies if the AZFunc Module should recreate the function folder if exist
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
