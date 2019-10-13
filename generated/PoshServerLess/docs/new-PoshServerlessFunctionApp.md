---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# new-PoshServerlessFunctionApp

## SYNOPSIS
Create a new azure function App object and the function app file

## SYNTAX

```
new-PoshServerlessFunctionApp [-FunctionAppPath] <String> [-FunctionAppName] <String>
 [[-FunctionAppLocation] <String>] [[-FunctionAppResourceGroup] <String>] [[-FunctionAppRuntime] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Create a new azure function App object and the function app file
It doesn't create the function in Azure

## EXAMPLES

### EXAMPLE 1
```
new-PoshServerlessFunctionApp -FunctionAppPath "c:\work\functionAppFolder\" -FunctionAppName "MyFunction01" -FunctionAppLocation "WestEurope" -FunctionAppResourceGroup "MyRg"
```

create a new azFunction Object

## PARAMETERS

### -FunctionAppPath
Specifies the function App local path, this path must not exist

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

### -FunctionAppName
The host name of the function App.
This Name must be globally unique

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

### -FunctionAppLocation
The Function App desired location

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FunctionAppResourceGroup
The Function App desired Resource Group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FunctionAppRuntime
{{ Fill FunctionAppRuntime Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Powershell
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### AzFunctionsApp object
## NOTES

## RELATED LINKS
