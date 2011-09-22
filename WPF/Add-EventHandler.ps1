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
    .Parameter SourceType
        For RoutedEvents, the type that originates the event
    .Parameter PassThru 
        If this is set, the delegate that is added to the object will
        be returned from the function.
    #>
    param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$true, Position = 0, ParameterSetName="SimpleEvents")]
    [ValidateNotNull()]
    [Alias("Object")]
    $InputObject,
    
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $EventName,
    
    [Parameter(Mandatory=$true, Position=2)]
    [ScriptBlock]
    $Handler,
    
    [Parameter(Mandatory=$false)]
    [String]
    $SourceType,
    
    [Switch]
    $PassThru  
    )
    
    process {
        if($SourceType) {
            $Type = $SourceType -as [Type]
            if(!$Type) {
                $Type = (Get-Command $SourceType).OutputType[0].Type
            }
            if(!$Type) {
                Write-Error "Can't determine type from '$SourceType', you should pass either a Type or the name of a ShowUI command that outputs a UI Element. We will try the InputObject(s)"
                $Type = $InputObject.GetType()
            }
        } else {
            $Type = $InputObject.GetType()
        }
        
        if ($eventName.StartsWith("On_")) {
            $eventName = $eventName.Substring(3)
        }
        
        $Event = $Type.GetEvent($EventName, [Reflection.BindingFlags]"IgnoreCase, Public, Instance")
        if (-not $Event) {
            Write-Error "Handler $EventName does not exist on $InputObject"
            return
        }       
                
        $realHandler = ([ScriptBlock]::Create(@"
`$eventName = 'On_$eventName';
. Initialize-EventHandler

$Handler

trap {                        
    . Write-WPFError `$_    
    continue
}
"@)) -as $event.EventHandlerType

        if($realHandler -is [System.Windows.RoutedEventHandler] -and $Type::"${EventName}Event" ) {
            $InputObject.AddHandler( $Type::"${EventName}Event", $realHandler )
        } else {

            if ($InputObject.Resources) {
                
                if (-not $InputObject.Resources.EventHandlers) {
                    $InputObject.Resources.EventHandlers = @{}
                }
                $InputObject.Resources.EventHandlers."On_$EventName" = $realHandler
            }
            $event.AddEventHandler($InputObject, $realHandler)
        }
        if ($passThru) {
            $RealHandler
        }
    }
} 
