---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# set-PoshServerlessFunctionAppSetting

## SYNOPSIS
Add or Update an App Setting

## SYNTAX

```
set-PoshServerlessFunctionAppSetting [-FunctionAppObject] <AzFunctionsApp> [-AppSettingName] <String>
 [-AppSettingValue] <String> [<CommonParameters>]
```

## DESCRIPTION
Add or Update an App Setting

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

### -AppSettingName
string Representing the timezone see 
the value can't be FUNCTIONS_WORKER_RUNTIME,AzureWebJobsStorage,FUNCTIONS_EXTENSION_VERSION,WEBSITE_CONTENTAZUREFILECONNECTIONSTRING,WEBSITE_CONTENTSHARE

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppSettingValue
string Representing the timezone see

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
