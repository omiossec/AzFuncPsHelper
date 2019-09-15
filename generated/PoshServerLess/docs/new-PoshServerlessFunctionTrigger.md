---
external help file: PoshServerLess-help.xml
Module Name: PoshServerLess
online version:
schema: 2.0.0
---

# new-PoshServerlessFunctionTrigger

## SYNOPSIS
Create an AzFunctionTrigger

## SYNTAX

### httpTrigger
```
new-PoshServerlessFunctionTrigger -TriggerType <String> -TriggerName <String> -methods <String[]>
 [-authLevel <String>] [<CommonParameters>]
```

### timerTrigger
```
new-PoshServerlessFunctionTrigger -TriggerType <String> -TriggerName <String> -Schedule <String>
 [<CommonParameters>]
```

### blobTrigger
```
new-PoshServerlessFunctionTrigger -TriggerType <String> -TriggerName <String> -connection <String>
 -path <String> [<CommonParameters>]
```

### queueTrigger
```
new-PoshServerlessFunctionTrigger -TriggerType <String> -TriggerName <String> -connection <String>
 -queueName <String> [<CommonParameters>]
```

### serviceBusTrigger
```
new-PoshServerlessFunctionTrigger -TriggerType <String> -TriggerName <String> -connection <String>
 -ServiceBusqueueName <String> [<CommonParameters>]
```

## DESCRIPTION
Create an AzFunctionTrigger
There are 5 types
queueTrigger, timerTrigger, serviceBusTrigger, httpTrigger, blobTrigger

## EXAMPLES

### EXAMPLE 1
```
$TriggerObject = new-PoshServerlessFunctionTrigger  -TriggerName QueueTrigger  -TriggerType queueTrigger -queueName myQueue -connection MyAzFuncStorage
```

## PARAMETERS

### -TriggerType
Kind of trigger "queueTrigger","timerTrigger", "httpTrigger","serviceBusTrigger","blobTrigger"

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

### -TriggerName
Name of the trigger.
The name will be use in the run.ps1 as a parameter

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

### -connection
The name of AppSetting for the storage configuration

```yaml
Type: String
Parameter Sets: blobTrigger, queueTrigger, serviceBusTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -queueName
For queue trigger only, Name of the queue in the storage

```yaml
Type: String
Parameter Sets: queueTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceBusqueueName
For Service Bus trigger only, Name of the queue in the storage

```yaml
Type: String
Parameter Sets: serviceBusTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Schedule
For timer trigger only, the schedule in a cron format, 0 * 8 * * *

```yaml
Type: String
Parameter Sets: timerTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -methods
For web trigger only, Allowed HTTP verbs @("POST", "GET")

```yaml
Type: String[]
Parameter Sets: httpTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -authLevel
For web trigger only, authorisation level 
anonymous no API key needed
function the function App key is needed 
admin the function master key is needed (this key can be also use in scm)

```yaml
Type: String
Parameter Sets: httpTrigger
Aliases:

Required: False
Position: Named
Default value: Function
Accept pipeline input: False
Accept wildcard characters: False
```

### -path
{{ Fill path Description }}

```yaml
Type: String
Parameter Sets: blobTrigger
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### AzFunctionsTrigger
## NOTES

## RELATED LINKS
