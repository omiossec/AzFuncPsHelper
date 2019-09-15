---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# sync-PoshServerlessFunctionApp

## SYNOPSIS
Download a function App content to the local workstation

## SYNTAX

```
sync-PoshServerlessFunctionApp [-FunctionAppName] <String> [-ResourceGroupName] <String>
 [-LocalFunctionPath] <String> [<CommonParameters>]
```

## DESCRIPTION
Download a function App content to the local workstation
this cmdlet use Azure PowerShell, you need to install it install-module -name AZ -scope CurrentUser
You need a valid connexion to azure before, run login-azaccount before runing this cmdlet

## EXAMPLES

### EXAMPLE 1
```
sync-PoshServerlessFunctionApp -FunctionName MyFunctionApp01 -ResourceGroupName MyRessourceGroup -LocalFunctionPath 'c:\work\Myfunction'
```

## PARAMETERS

### -FunctionAppName
{{ Fill FunctionAppName Description }}

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

### -ResourceGroupName
The name of the ressouce group in Azure where the function app is

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

### -LocalFunctionPath
The local path to download Azure functions files and folder
The path should be empty

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### AzFunctionsApp
## NOTES

## RELATED LINKS
