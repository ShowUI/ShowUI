function Export-NamedControl {
<#
.SYNOPSIS
   Export all named controls from a WPF control tree as variables
.DESCRIPTION
   Crawls child and content elements of a WPF control and sets variables at the specified scope (defaults to the calling scope).
   
   This function is designed to be called in an event handler on the window to create variables for the window's controls.
.PARAMETER Root
   The root control to export from. Defaults to $This, and falls back to $BootsWindow if that's not defined.
.PARAMETER Prefix
   A prefix for the variable names created for each control
.PARAMETER Scope
   The scope to create the variables in. Defaults to 2, which is the callers scope.
.EXAMPLE
   New-BootsWindow -FileTemplate $PowerBootsPath\Samples\WorkingWithXaml.xaml -On_Loaded {
      Export-NamedControl $this
      $Calculate.Add_Click({ 
         $Total.Text = '${0:n2}' -f (($Miles.Text -as [Double]) / ($Mpg.Text -as [Double]) * ($Cost.Text -as [Double]))
      })
   }
   
   Description
   -----------
   Creates a new window using a Xaml file as the window definition, and in the "Loaded" event handler, exports all the named controls, and adds a click handler to one of the named controls (the "Calculate" button) using other named controls (Total, Miles, Mpg, and Cost) in the event handler.
   
#>
[CmdletBinding()]
param(
   [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$false)]
   $Root = $(if(test-path Variable::This){$this}elseif(test-path Variable::BootsWindow){$BootsWindow})
, 
   [Parameter(Mandatory=$false)]
   [String]$Prefix = ''
,
   [Parameter(Mandatory=$false)]
   [String]$Scope = '3'
)
process {
   $command = { 
      Param( [Parameter(Mandatory=$false)][String]$Prefix, [Parameter(Mandatory=$false)][String]$Scope )
      $control = $this 
      while($control) {
         $control = $control | ForEach-Object {
            $Element = $_
            if(!$Element) { return }
   
            Write-Verbose "This $($Element.GetType().Name) is $Element"
  
            if($Element.Name) {
               Write-Verbose "Defining $Prefix$($Element.Name) = $Element"
               Set-Variable "$Prefix$($Element.Name)" $Element -Scope $Scope
            }
            
            ## Return all the child/content controls ...
            foreach($prop in $Script:BootsContentProperties ) { $Element.$prop }
            # @($Element.Children) + @($Element.Child) + @($Element.Content) + @($Element.Items) + @($Element.Inlines) + @($Element.Blocks)
         }
      }
   } 
   if($Root.Dispatcher.CheckAccess()) {
      &$command $Prefix $Scope
   } else {
      Invoke-BootsWindow $Root $command $Prefix $Scope
   }
}
}
