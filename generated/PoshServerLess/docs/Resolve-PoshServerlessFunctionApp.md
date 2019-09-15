---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# Resolve-PoshServerlessFunctionApp

## SYNOPSIS
This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync

## SYNTAX

```
Resolve-PoshServerlessFunctionApp [-FunctionAppObject] <AzFunctionsApp> [-ResourceGroupName] <String>
 [<CommonParameters>]
```

## DESCRIPTION
This function resolve Azure Azure Parameters like AppSetting for a function App that exit localy and on Azure but are not sync

## EXAMPLES

### EXAMPLE 1
```
$FunctionApp = get-PoshServerlessFunctionApp -FunctionAppPath Path -FunctionAppName MyFuntion
```

Resolve-PoshServerlessFunctionApp -FunctionAppObject $FunctionApp -ResourceGroupName MyRessourceGroup

## PARAMETERS

### -FunctionAppObject
A \[AzFunctionsApp\] object

```yaml
Type: AzFunctionsApp
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -ResourceGroupName
The name of the ressource Group

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
