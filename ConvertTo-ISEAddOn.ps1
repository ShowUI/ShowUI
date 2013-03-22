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
    $Visible,

    [Switch]
    $Force
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
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Media;
    using System.Windows.Data;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;
    using System.Threading;
    using System.Windows.Threading;
    using System.ComponentModel;
    using System.Collections.Generic;
    using System.Collections;
    using System.Collections.ObjectModel;
    using System.Collections.Generic;
    using Microsoft.PowerShell.Host.ISE;
    using System.Windows.Input;
    using System.Text;
    using System.Threading;
    using System.Windows.Threading;



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
            if (this.hostObject.CurrentPowerShellTab.CanInvoke) {
                if (this.Content != null && this.Content is UIElement ) {                     
                    (this.Content as UIElement).IsEnabled = true; 
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
                rs.SessionStateProxy.SetVariable("psIse", this.HostObject);
            }
            
            PowerShell psCmd = PowerShell.Create().AddScript(@"
$($ScriptBlock.ToString().Replace('"','""'))
");
            psCmd.Runspace = Runspace.DefaultRunspace;
            try { 
                FrameworkElement ui = psCmd.Invoke<FrameworkElement>()[0];
                this.Content = ui;
                if (ui.GetValue(Control.WidthProperty) != null) {
                    this.Width = ui.Width;
                }
                if (ui.GetValue(Control.HeightProperty) != null) {
                    this.Height = ui.Height;
                }
                if (ui.GetValue(Control.MinWidthProperty) != null) {
                    this.MinWidth = ui.MinWidth;
                }
                if (ui.GetValue(Control.MinHeightProperty) != null) {
                    this.MinHeight = ui.MinHeight;
                }
                if (ui.GetValue(Control.MaxWidthProperty) != null) {
                    this.MaxWidth = ui.MaxWidth;
                }
                if (ui.GetValue(Control.MaxHeightProperty) != null) {
                    this.MaxHeight = ui.MaxHeight;
                }                 
            } catch { 
            } 
            
        }        


        public PSObject[] InvokeScript(string script, object parameters)
        {
            return (PSObject[])RunOnUIThread(
            new DispatcherOperationCallback(
            delegate
            {
                PowerShell psCmd = PowerShell.Create();
                Runspace.DefaultRunspace.SessionStateProxy.SetVariable("this", this);
                psCmd.Runspace = Runspace.DefaultRunspace;
                psCmd.AddScript(script);
                if (parameters is IDictionary)
                {
                    psCmd.AddParameters(parameters as IDictionary);
                }
                else
                {
                    if (parameters is IList)
                    {
                        psCmd.AddParameters(parameters as IList);
                    }
                }
                Collection<PSObject> results = psCmd.Invoke();
                if (psCmd.InvocationStateInfo.Reason != null)
                {
                    throw psCmd.InvocationStateInfo.Reason;
                }
                PSObject[] resultArray = new PSObject[results.Count + psCmd.Streams.Error.Count];
                int count = 0;
                if (psCmd.Streams.Error.Count > 0)
                {
                    foreach (ErrorRecord err in psCmd.Streams.Error)
                    {
                        resultArray[count++] = new PSObject(err);
                    }
                }
                foreach (PSObject r in results)
                {
                    resultArray[count++] = r;
                }
                return resultArray;
            }),
            false);
            
        }

        object RunOnUIThread(DispatcherOperationCallback dispatcherMethod, bool async)
        {
            if (Application.Current != null)
            {
                if (Application.Current.Dispatcher.Thread == Thread.CurrentThread)
                {
                    // This avoids dispatching to the UI thread if we are already in the UI thread.
                    // Without this runing a command like 1/0 was throwing due to nested dispatches.
                    return dispatcherMethod.Invoke(null);
                }
            }

            Exception e = null;
            object returnValue = null;
            SynchronizationContext sync = new DispatcherSynchronizationContext(this.Dispatcher);
            if (async) {
                sync.Post(
                    new SendOrPostCallback(delegate(object obj)
                    {
                        try
                        {
                            returnValue = dispatcherMethod.Invoke(obj);
                        }
                        catch (Exception uiException)
                        {
                            e = uiException;
                        }
                    }),
                    null);

            } else {
                sync.Send(
                    new SendOrPostCallback(delegate(object obj)
                    {
                        try
                        {
                            returnValue = dispatcherMethod.Invoke(obj);
                        }
                        catch (Exception uiException)
                        {
                            e = uiException;
                        }
                    }),
                    null);

            }

            if (e != null)
            {
                throw new System.Reflection.TargetInvocationException(e.Message, e);
            }
            return returnValue;
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
$t = add-type -TypeDefinition $addOnType -ReferencedAssemblies $systemManagementAutomation,$presentationFramework,$presentationCore,$windowsBase,$gPowerShell,$systemXaml -ignorewarnings -PassThru |
    Select-Object -First 1 
if ($addHorizontally) {
    $exists=  $psISE.CurrentPowerShellTab.HorizontalAddOnTools | Where-Object { $_.Name -eq "$displayName" } 
    if ($Exists -and $Force) {
        $null = $psISE.CurrentPowerShellTab.HorizontalAddOnTools.Remove($exists)
    }
    $psISE.CurrentPowerShellTab.HorizontalAddOnTools.Add("$displayName",$t,$true)
} elseif ($addVertically) {
    $exists=  $psISE.CurrentPowerShellTab.VerticalAddOnTools | Where-Object { $_.Name -eq "$displayName" } 
    if ($Exists -and $Force) {
        $null = $psISE.CurrentPowerShellTab.VerticalAddOnTools.Remove($exists)
    }

    $psISE.CurrentPowerShellTab.VerticalAddOnTools.Add("$displayName",$t,$true)
} else {
    $t
}

            
    }
}


