---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# Initialize-PoshServerLessFunctionApp

## SYNOPSIS
Create an Azure Function App in Azure And deploy the current function App object in

## SYNTAX

```
Initialize-PoshServerLessFunctionApp [-FunctionAppObject] <AzFunctionsApp> [-RessourceGroup] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Create an Azure Function App in Azure And deploy the current function App object in

## EXAMPLES

### EXAMPLE 1
```
Initialize-PoshServerLessFunctionApp -FunctionAppObject $MyFunctionApp -RessourceGroup MyRg
```

## PARAMETERS

### -FunctionAppObject
In or Out
Queue binding accept only Out direction

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

### -RessourceGroup
The ressource group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
