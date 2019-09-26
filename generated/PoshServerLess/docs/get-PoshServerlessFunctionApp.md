---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# get-PoshServerlessFunctionApp

## SYNOPSIS
Create an Azure Function App object by reading a folder

## SYNTAX

```
get-PoshServerlessFunctionApp [-FunctionAppPath] <String> [-FunctionAppName] <String> [<CommonParameters>]
```

## DESCRIPTION
Create an Azure Function App object by reading a folder
If you have download a functions App or create it you can use this function to create an AzFunctionsApp object from the folder
It will read the host.json and function folder

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -FunctionAppPath
\[String\] the function App Path
if the path doesn't exist the cmdlet will fail

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

### -FunctionAppName
\[String\] the function App Name

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

### AzFunctionsApp
## NOTES

## RELATED LINKS
