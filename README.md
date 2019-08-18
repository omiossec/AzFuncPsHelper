# AzFuncPsHelper
 
This project started as a side project to start working on OOP with a PowerShell module. I needed a subject and at this time I worked with Azure Function. 

 One of my main problems when working with Azure Functions v2 with PowerShell is to deal with Binding and Trigger. How to remember what binding I can use, which direction, which extension. It’s easy when using the portal, but if you need to create and modify function locally it’s not the best way. 
This is only a Proof of Concept for the moment. There is a lot of work to do. 
The goal is to publish the module in the PowerShell Gallery. 
 
## Usage

There are 4 main objects used in this module 
·       AzFuncApp, the representation of one Azure Functions App V2 for PowerShell
·       AzFuncFunction, the representation of one Function in a an Azure  function App
·       AzFuncFunctionTrigger, the representation of the trigger of a function in an Azure function App
·       AzFuncFunctionBinding, the representation of binding of a function in an Azure function App
 
### Create a new Function

```powershell
$Function = new-azFuncFunction -FunctionAppPath "c:\work\functionAppFolder\" -FunctionName "TimerFunction"
``` 

### Add a Trigger to the function

```powershell
$Trigger = new-azFuncFunctionTrigger -TriggerType timerTrigger -Schedule "0 */5 * * * *"
 
 update-azFuncFunctionTrigger -triggerObject $Trigger  -FunctionObject $Function
```

 
### Add Binding 

```powershell
$Queue = new-azFuncFunctionBinding -Direction out -BindingName MyQueue – connection AzureWebStorage -queueName myAzureQueue
 
add-azFuncFunctionBinding  -FunctionObject $Function -BindingObject $Queue
```
 
 
 
## Release Note
 
V 0.0.1 Initial release