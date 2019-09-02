---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# new-PoshServerlessFunctionBinding

## SYNOPSIS
Create an AzfunctionBinding object

## SYNTAX

### http
```
new-PoshServerlessFunctionBinding -Direction <String> -BindingName <String> -BindingType <String>
 [<CommonParameters>]
```

### table
```
new-PoshServerlessFunctionBinding -Direction <String> -BindingName <String> -BindingType <String>
 -connection <String> -tableName <String> [-partitionKey <String>] [-rowkey <String>] [-take <Int32>]
 [-filter <String>] [<CommonParameters>]
```

### queue
```
new-PoshServerlessFunctionBinding -Direction <String> -BindingName <String> -BindingType <String>
 -connection <String> -queueName <String> [<CommonParameters>]
```

### blob
```
new-PoshServerlessFunctionBinding -Direction <String> -BindingName <String> -BindingType <String>
 -Path <String> -connection <String> [<CommonParameters>]
```

## DESCRIPTION
Create an AzfunctionBinding object 
There are two types of Direction In and Out
and "blob","http","queue", "table"

## EXAMPLES

### EXAMPLE 1
```

```

## PARAMETERS

### -Direction
In or Out
Queue binding accept only Out direction

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindingName
In or Out
Queue binding accept only Out direction

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BindingType
{{ Fill BindingType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
{{ Fill Path Description }}

```yaml
Type: String
Parameter Sets: blob
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -connection
{{ Fill connection Description }}

```yaml
Type: String
Parameter Sets: table, queue, blob
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -queueName
{{ Fill queueName Description }}

```yaml
Type: String
Parameter Sets: queue
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -tableName
{{ Fill tableName Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -partitionKey
{{ Fill partitionKey Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -rowkey
{{ Fill rowkey Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -take
{{ Fill take Description }}

```yaml
Type: Int32
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -filter
{{ Fill filter Description }}

```yaml
Type: String
Parameter Sets: table
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### AzFunctionsBinding
## NOTES

## RELATED LINKS
