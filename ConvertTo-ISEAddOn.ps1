function ConvertTo-ISEAddOn
{
    [CmdletBinding(DefaultParameterSetName="CreateOnly")]
    param(
    [Parameter(Mandatory=$true,
        ParameterSetName="DisplayNow")]
    [string]$DisplayName,

    [Parameter(Mandatory=$true,
        ParameterSetName="CreateOnly")]
    [Parameter(Mandatory=$true,
        ParameterSetName="DisplayNow")]
    [ScriptBlock]
    $ScriptBlock,

    [Parameter(ParameterSetName="DisplayNow")]
    [switch]
    $AddVertically,

    [Parameter(ParameterSetName="DisplayNow")]
    [switch]
    $AddHorizontally,

    [Parameter(Mandatory=$true,
        ParameterSetName="DisplayNow")]
    [switch]
    $Visible
    )

    begin {
        if ($psVersionTable.PSVersion -lt "3.0") {
            Write-Warning "Ise Window Add ons were not added until version 3.0."
            return
        }
    }

    process {
$addOnNumber = Get-Random
$addOnType =@"
namespace ShowISEAddOns
{
    using System;
    using System.Collections.ObjectModel;
    using System.ComponentModel;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Data;
    using Microsoft.PowerShell.Host.ISE;
    using System.Collections.Generic;
    using System.Windows.Input;
    using System.Text;

    public class ShowUIIseAddOn${addOnNumber} : UserControl, IAddOnToolHostObject
    {

        ObjectModelRoot hostObject;
            
        #region IAddOnToolHostObject Members

        public ObjectModelRoot HostObject
        {
            get
            {
                return this.hostObject;
            }
            set
            {
                this.hostObject = value;
                this.hostObject.CurrentPowerShellTab.PropertyChanged += new PropertyChangedEventHandler(CurrentPowerShellTab_PropertyChanged);
            }
        }

        private void CurrentPowerShellTab_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "CanInvoke" && this.hostObject.CurrentPowerShellTab.CanInvoke)
            {
                if (this.Content != null && this.Content is UIElement ) {                     
                    (this.Content as UIElement).IsEnabled = true; 
                }
            } else {
                if (this.Content != null && this.Content is UIElement) { 
                    (this.Content as UIElement).IsEnabled = false; 
                }
            }
        }

        public ShowUIIseAddOn${addOnNumber}() {
            if (Runspace.DefaultRunspace == null ||
                Runspace.DefaultRunspace.ApartmentState != System.Threading.ApartmentState.STA ||
                Runspace.DefaultRunspace.ThreadOptions != PSThreadOptions.UseCurrentThread) {
                InitialSessionState iss = InitialSessionState.CreateDefault();
                iss.ImportPSModule(new string[] { "ShowUI" });
                Runspace rs  = RunspaceFactory.CreateRunspace(iss);
                rs.ApartmentState = System.Threading.ApartmentState.STA;
                rs.ThreadOptions = PSThreadOptions.UseCurrentThread;
                rs.Open();
                Runspace.DefaultRunspace = rs;
            }
            
            PowerShell psCmd = PowerShell.Create().AddScript(@"
$($ScriptBlock.ToString().Replace('"','""'))
");
            psCmd.Runspace = Runspace.DefaultRunspace;
            try { 
                this.Content = psCmd.Invoke<UIElement>()[0];                 
            } catch { 
            } 
            
        }        
        
        #endregion
    }
        
}
"@

$presentationFramework = [System.Windows.Window].Assembly.FullName
$presentationCore = [System.Windows.UIElement].Assembly.FullName
$windowsBase=[System.Windows.DependencyObject].Assembly.FullName
$gPowerShell=[Microsoft.PowerShell.Host.ISE.PowerShellTab].Assembly.FullName
$systemXaml=[system.xaml.xamlreader].Assembly.FullName
$systemManagementAutomation=[psobject].Assembly.FullName
$t = add-type -TypeDefinition $addOnType -ReferencedAssemblies $systemManagementAutomation,$presentationFramework,$presentationCore,$windowsBase,$gPowerShell,$systemXaml -ignorewarnings -PassThru
if ($addHorizontally) {
    $psISE.CurrentPowerShellTab.HorizontalAddOnTools.Add("$displayName",$t,$true)
} elseif ($addVertically) {
    $psISE.CurrentPowerShellTab.HorizontalAddOnTools.Add("$displayName",$t,$true)
} else {
    $t
}

            
    }
}


