[CmdletBinding(DefaultParameterSetName='KeyOnly')]
PARAM(
	[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.Key]$Key
,
	[Parameter(Mandatory=$true, Position=1, ParameterSetName='WithModifier', ValueFromPipelineByPropertyName=$true)]
	# [Parameter(Mandatory=$true, Position=1, ParameterSetName='WithDisplayString', ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.ModifierKeys]$Modifiers
, 
	[Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
   [System.String]$DisplayString 
,
   [Parameter(ValueFromRemainingArguments=$true)]
   [string[]]$DependencyProps
)
## Preload the assembly if it's not already loaded


if( [Array]::BinarySearch(@(Get-BootsAssemblies), 'PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) -lt 0 ) {
   $null = [Reflection.Assembly]::Load( 'PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) 
}
if($ExecutionContext.SessionState.Module.Guid -ne (Get-BootsModule).Guid) {
	Write-Debug "KeyGesture not invoked in PowerBoots context. Attempting to reinvoke."
   $scriptParam = $PSBoundParameters
   return iex "& (Get-BootsModule) '$($MyInvocation.MyCommand.Path)' `@PSBoundParameters"
}
# Write-Host "KeyGesture in module $($executioncontext.sessionstate.module) context!" -fore Green


function Global:New-System.Windows.Input.KeyGesture {
<#
.Synopsis
   Create a new KeyGesture object
.Description
   Generates a new System.Windows.Input.KeyGesture object, and allows setting all of it's properties
.Parameter Key
   The name of the key to bind to this gesture. (can be just a letter, like "W")
.Parameter Modifiers
   The modifier keys to modify this gesture. The possible enumeration values are: None, Alt, Control, Shift, Windows. Defaults to None.
   You can pass this as an array of strings, or as a single string with multiple modifiers joined by +:
   -Modifiers Control
   -Modifiers Control+Shift
   -Modifiers Control, Shift
   
.Parameter DisplayString
   Optionally, an alternate string to display as the gesture.
   For example, if you specify the Key "F4" and the Modifiers "Ctrl", "Alt" ... the default display string is: "Ctrl+Alt+F4", so if you would like to see, for instance: Control+Alt, F4 then you can specify it in this parameter.
.Notes
 AUTHOR:    Joel Bennett http://HuddledMasses.org
 LASTEDIT:  04/22/2010 16:58:33
#>
 
[CmdletBinding(DefaultParameterSetName='KeyOnly')]
PARAM(
	[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.Key]$Key
,
	[Parameter(Mandatory=$true, Position=1, ParameterSetName='WithModifier', ValueFromPipelineByPropertyName=$true)]
	# [Parameter(Mandatory=$true, Position=1, ParameterSetName='WithDisplayString', ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.ModifierKeys]$Modifiers
, 
	[Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
   [System.String]$DisplayString 
,
   [Parameter(ValueFromRemainingArguments=$true)]
   [string[]]$DependencyProps
)
BEGIN {
   $All = Get-Parameter New-System.Windows.Input.KeyBinding | ForEach-Object { $_.Key } | Sort
}
PROCESS {
   switch($PSCmdlet.ParameterSetName) {
      "WithModifier" {
         if($DisplayString){
            $DObject = New-Object System.Windows.Input.KeyGesture $Key, $Modifiers, $DisplayString
         } else {
            $DObject = New-Object System.Windows.Input.KeyGesture $Key, $Modifiers
         }
      }
      "KeyOnly" {
         $DObject = New-Object System.Windows.Input.KeyGesture $Key
      }
   }

   $null = $PSBoundParameters.Remove("Key")
   $null = $PSBoundParameters.Remove("Modifiers")
   $null = $PSBoundParameters.Remove("DisplayString")

   Set-PowerBootsProperties $PSBoundParameters ([ref]$DObject) $All
   Microsoft.PowerShell.Utility\Write-Output $DObject
} #Process
}

Set-Alias KeyGesture New-System.Windows.Input.KeyGesture
New-System.Windows.Input.KeyGesture @PSBoundParameters
