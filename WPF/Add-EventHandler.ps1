function Add-EventHandler {
    <#
    .Synopsis
        Adds an event handler to an object
    .Description
        Adds an event handler to an object.  If the object has a 
        resource dictionary, it will add an eventhandlers 
        hashtable to that object and it will store the event handler,
        so it can be removed later.
    .Example
        $window = New-Window
        $window | Add-EventHandler Loaded { $this.Top = 100 }
    .Parameter Object
        The Object to add an event handler to
    .Parameter EventName
        The name of the event (i.e. Loaded)
    .Parameter Handler
        The script block that will handle the event
    .Parameter Extra
        An extra script block that will be appended to 
        the initial script block.  By default, extra adds 
        a trap that turns terminating errors into non-terminating 
        errors, which can result in more stable user interfaces.
    .Parameter PassThru 
        If this is set, the delegate that is added to the object will
        be returned from the function.
    #>
    param(
    [Parameter(ValueFromPipeline=$true,
        Mandatory=$true)]
    [ValidateNotNull()]
    $Object,
    
    [Parameter(Mandatory=$true)]
    [String]
    $EventName,
    
    [ScriptBlock]
    $Handler,        
    
    [Switch]
    $PassThru  
    )
    
    process {
        if ($eventName.StartsWith("On_")) {
            $eventName = $eventName.Substring(3)
        }
        $Event = $object.GetType().GetEvent($EventName, 
            [Reflection.BindingFlags]"IgnoreCase, Public, Instance")
        if (-not $Event) {
            Write-Error "Handler $EventName does not exist on $Object"
            return
        }       
                
        $realHandler = ([ScriptBlock]::Create(@"
`$eventName = 'On_$eventName';
. Initialize-EventHandler
`$ErrorActionPreference = 'stop'
            
$Handler

trap {                        
    . Write-WPFError `$_    
    continue
}
"@)) -as $event.EventHandlerType
        if ($Object.Resources) {
            if (-not $Object.Resources.EventHandlers) {
                $Object.Resources.EventHandlers = @{}
            }
            $Object.Resources.EventHandlers."On_$EventName" = $realHandler
        }
        #$event.GetAddMethod().Invoke($object, @($realHandler))
        $object."add_$($Event.Name)".Invoke(@($realHandler))
        
        if ($passThru) {
            $RealHandler
        }
    }
} 
