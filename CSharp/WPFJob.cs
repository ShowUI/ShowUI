namespace ShowUI
{
    using System;
    using System.Windows;
    using System.Windows.Controls;
    using System.Windows.Media;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;
    using System.Threading;
    using System.Windows.Threading;
    using System.ComponentModel;
    using System.Collections.Generic;
    using System.Collections;
    using System.Collections.ObjectModel;


    public class WPFJob : Job, INotifyPropertyChanged
    {
        Runspace runspace;
        InitialSessionState initialSessionState;

        PowerShell powerShellCommand;
        Dispatcher JobDispatcher;
        public Window JobWindow;
        Thread jobThread;

        Hashtable namedControls;
        Runspace interopRunspace;

        Runspace GetWPFCurrentThreadRunspace(InitialSessionState sessionState)
        {
            InitialSessionState clone = sessionState.Clone();
            clone.ThreadOptions = PSThreadOptions.UseCurrentThread;
            SessionStateVariableEntry window = new SessionStateVariableEntry("Window", JobWindow, "");
            SessionStateVariableEntry namedControls = new SessionStateVariableEntry("NamedControls", this.namedControls, "");
            clone.Variables.Add(window);
            clone.Variables.Add(namedControls);
            return RunspaceFactory.CreateRunspace(clone);
        }


        delegate Collection<PSObject> RunScriptCallback(string script);
        delegate Collection<PSObject> RunScriptWithParameters(string script, Object parameters);

        public PSObject[] InvokeScriptInJob(string script, object parameters, bool asynchronous)
        {
            if (this.JobStateInfo.State == JobState.Running)
            {
                for (int i = 0; i < 10; i++)
                {
                    if (JobWindow != null) { break; }
                    Thread.Sleep(50);
                }

                if (JobWindow == null)
                {
                    return null;
                }
                return (PSObject[])RunOnUIThread(
                    new DispatcherOperationCallback(
                    delegate
                    {
                        PowerShell psCmd = PowerShell.Create();
                        if (interopRunspace == null)
                        {
                            interopRunspace = GetWPFCurrentThreadRunspace(this.initialSessionState);
                            interopRunspace.Open();
                        }
                        psCmd.Runspace = interopRunspace;
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
                    asynchronous);
            }
            else
            {
                return null;
            }
        }

        object RunOnUIThread(DispatcherOperationCallback dispatcherMethod, bool asynchronous)
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
            SynchronizationContext sync = new DispatcherSynchronizationContext(JobWindow.Dispatcher);
            if (sync == null) { return null; }
            if (asynchronous) {
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


        public static InitialSessionState GetSessionStateForCommands(CommandInfo[] commands)
        {
            InitialSessionState iss = InitialSessionState.CreateDefault();
            Dictionary<string, SessionStateCommandEntry> commandCache = new Dictionary<string, SessionStateCommandEntry>();
            foreach (SessionStateCommandEntry ssce in iss.Commands)
            {
                commandCache[ssce.Name] = ssce;
            }
            iss.ApartmentState = ApartmentState.STA;
            iss.ThreadOptions = PSThreadOptions.ReuseThread;
            if (commands.Length == 0)
            {
                return iss;
            }
            foreach (CommandInfo cmd in commands)
            {
                if (cmd.Module != null)
                {                    
                        string manifestPath = cmd.Module.Path.Replace(".psm1",".psd1").Replace(".dll", ".psd1");
                        if (System.IO.File.Exists(manifestPath)) {  
                            iss.ImportPSModule(new string[] { manifestPath });
                        } else {
                            iss.ImportPSModule(new string[] { cmd.Module.Path });
                        }
                        
                        continue;
                }
                if (cmd is AliasInfo)
                {
                    CommandInfo loopCommand = cmd;
                    while (loopCommand is AliasInfo)
                    {
                        SessionStateAliasEntry alias = new SessionStateAliasEntry(loopCommand.Name, loopCommand.Definition);
                        iss.Commands.Add(alias);
                        loopCommand = (loopCommand as AliasInfo).ReferencedCommand;
                    }
                    if (loopCommand is FunctionInfo)
                    {
                        SessionStateFunctionEntry func = new SessionStateFunctionEntry(loopCommand.Name, loopCommand.Definition);
                        iss.Commands.Add(func);
                    }
                    if (loopCommand is CmdletInfo)
                    {
                        CmdletInfo cmdletData = loopCommand as CmdletInfo;
                        SessionStateCmdletEntry cmdlet = new SessionStateCmdletEntry(cmd.Name,
                                cmdletData.ImplementingType,
                                cmdletData.HelpFile);
                        iss.Commands.Add(cmdlet);
                    }
                }
                if (cmd is FunctionInfo)
                {
                    SessionStateFunctionEntry func = new SessionStateFunctionEntry(cmd.Name, cmd.Definition);
                    iss.Commands.Add(func);
                }
                if (cmd is CmdletInfo)
                {
                    CmdletInfo cmdletData = cmd as CmdletInfo;
                    SessionStateCmdletEntry cmdlet = new SessionStateCmdletEntry(cmd.Name,
                            cmdletData.ImplementingType,
                            cmdletData.HelpFile);
                    iss.Commands.Add(cmdlet);
                }
            }
            return iss;
        }

        public WPFJob(string name, string command, ScriptBlock scriptBlock)
            : base(command, name)
        {
            this.initialSessionState = InitialSessionState.CreateDefault();
            Start(scriptBlock, new Hashtable());
        }

        private WPFJob(ScriptBlock scriptBlock)
        {
            Start(scriptBlock, new Hashtable());
        }
        
        public WPFJob(string name, string command, ScriptBlock scriptBlock, InitialSessionState initalSessionState)
            : base(command, name)
        {
            this.initialSessionState = initalSessionState;
            Start(scriptBlock, new Hashtable());
        }
        
        public WPFJob(string name, string command, ScriptBlock scriptBlock, InitialSessionState initalSessionState, Hashtable parameters)
            : base(command, name)
        {
            this.initialSessionState = initalSessionState;
            Start(scriptBlock, parameters);
        }

        private WPFJob(string name, string command, ScriptBlock scriptBlock, InitialSessionState initalSessionState, Hashtable parameters, bool isChildJob)
            : base(command, name)
        {
            this.initialSessionState = initalSessionState;
            if (isChildJob)
            {
                Start(scriptBlock, parameters);
            }
            else
            {
                WPFJob childJob = new WPFJob(name, command, scriptBlock, initalSessionState, parameters, true);
                childJob.StateChanged += new EventHandler<JobStateEventArgs>(childJob_StateChanged);
                this.ChildJobs.Add(childJob);
            }
        }


        void childJob_StateChanged(object sender, JobStateEventArgs e)
        {
            this.SetJobState(e.JobStateInfo.State);            
        }

        /// <summary>
        /// Synchronizes Job State with Background Runspace
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        void powerShellCommand_InvocationStateChanged(object sender, PSInvocationStateChangedEventArgs e)
        {
            try
            {
                if (e.InvocationStateInfo.State == PSInvocationState.Completed)
                {
                    runspace.Close();
                }
                if (e.InvocationStateInfo.State == PSInvocationState.Failed)
                {
                    ErrorRecord err = new ErrorRecord(e.InvocationStateInfo.Reason, "JobFailed", ErrorCategory.OperationStopped, this);
                    Error.Add(err);
                    runspace.Close();
                }
                JobState js = (JobState)Enum.Parse(typeof(JobState), e.InvocationStateInfo.State.ToString(), true);
                this.SetJobState(js);
            }
            catch
            {
            }
        }


        void Start(ScriptBlock scriptBlock, Hashtable parameters)
        {
            SessionStateAssemblyEntry windowsBase = new SessionStateAssemblyEntry(typeof(Dispatcher).Assembly.ToString());
            SessionStateAssemblyEntry presentationCore = new SessionStateAssemblyEntry(typeof(UIElement).Assembly.ToString());
            SessionStateAssemblyEntry presentationFramework = new SessionStateAssemblyEntry(typeof(Control).Assembly.ToString());
            initialSessionState.Assemblies.Add(windowsBase);
            initialSessionState.Assemblies.Add(presentationCore);
            initialSessionState.Assemblies.Add(presentationFramework);
            initialSessionState.Assemblies.Add(presentationFramework);
            runspace = RunspaceFactory.CreateRunspace(this.initialSessionState);
            runspace.ThreadOptions = PSThreadOptions.ReuseThread;
            runspace.ApartmentState = ApartmentState.STA;
            runspace.Open();
            powerShellCommand = PowerShell.Create();
            powerShellCommand.Runspace = runspace;
            jobThread = powerShellCommand.AddScript("[Threading.Thread]::CurrentThread").Invoke<Thread>()[0];

            powerShellCommand.Streams.Error = this.Error;
            this.Error.DataAdded += new EventHandler<DataAddedEventArgs>(Error_DataAdded);
            powerShellCommand.Streams.Warning = this.Warning;
            this.Warning.DataAdded += new EventHandler<DataAddedEventArgs>(Warning_DataAdded);
            powerShellCommand.Streams.Verbose = this.Verbose;
            this.Verbose.DataAdded += new EventHandler<DataAddedEventArgs>(Verbose_DataAdded);
            powerShellCommand.Streams.Debug = this.Debug;
            this.Debug.DataAdded += new EventHandler<DataAddedEventArgs>(Debug_DataAdded);
            powerShellCommand.Streams.Progress = this.Progress;
            this.Progress.DataAdded += new EventHandler<DataAddedEventArgs>(Progress_DataAdded);
            this.Output.DataAdded += new EventHandler<DataAddedEventArgs>(Output_DataAdded);
            powerShellCommand.Commands.Clear();
            powerShellCommand.Commands.AddScript(scriptBlock.ToString(), false);
            if (parameters.Count > 0)
            {
                powerShellCommand.AddParameters(parameters);
            }
            Collection<Visual> output = powerShellCommand.Invoke<Visual>();
            if (output.Count == 0)
            {
                return;
            }
            powerShellCommand.Commands.Clear();
            powerShellCommand.Commands.AddCommand("Show-Window").AddArgument(output[0]).AddParameter("OutputWindowFirst");
            Object var = powerShellCommand.Runspace.SessionStateProxy.GetVariable("NamedControls");
            if (var != null && ((var as Hashtable) != null))
            {
                namedControls = var as Hashtable;
            }
            JobDispatcher = Dispatcher.FromThread(jobThread);
            JobDispatcher.UnhandledException += new DispatcherUnhandledExceptionEventHandler(jobDispatcher_UnhandledException);
            powerShellCommand.InvocationStateChanged += new EventHandler<PSInvocationStateChangedEventArgs>(powerShellCommand_InvocationStateChanged);
            powerShellCommand.BeginInvoke<Object, PSObject>(null, this.Output);
            DateTime startTime = DateTime.Now;
            if (output[0] is FrameworkElement)
            {

                while (JobWindow == null)
                {
                    if ((DateTime.Now - startTime) > TimeSpan.FromSeconds(30))
                    {
                        this.SetJobState(JobState.Failed);
                        return;
                    }
                    System.Threading.Thread.Sleep(25);
                }
            }


        }

        void jobDispatcher_UnhandledException(object sender, DispatcherUnhandledExceptionEventArgs e)
        {
            ErrorRecord err = new ErrorRecord(e.Exception, "UnhandledException", ErrorCategory.OperationStopped, this);
            this.Error.Add(err);
            StopJob();
        }

        void Output_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<PSObject> output = sender as PSDataCollection<PSObject>;
            if (output == null)
            {
                return;
            }
            if (output[e.Index].BaseObject is Window)
            {
                JobWindow = output[e.Index].BaseObject as Window;
            }
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Output"));
            }
        }

        void Progress_DataAdded(object sender, DataAddedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Progress"));
            }
        }

        void Debug_DataAdded(object sender, DataAddedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Debug"));
            }
        }

        void Verbose_DataAdded(object sender, DataAddedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Verbose"));
            }
        }

        void Warning_DataAdded(object sender, DataAddedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Warning"));
            }
        }

        void Error_DataAdded(object sender, DataAddedEventArgs e)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs("Error"));
            }
        }

        /// <summary>
        /// If the comamnd is running, the job indicates it has more data
        /// </summary>
        public override bool HasMoreData
        {
            get
            {
                if (powerShellCommand.InvocationStateInfo.State == PSInvocationState.Running)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public override string Location
        {
            get
            {
                if (this.JobStateInfo.State == JobState.Running && (JobWindow != null))
                {

                    return (string)RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            return "Left: " + JobWindow.Left +
                                " Top: " + JobWindow.Top +
                                " Width: " + JobWindow.ActualWidth +
                                " Height: " + JobWindow.ActualHeight;
                        }),
                        false);
                }
                else
                {
                    return " ";
                }
            }
        }


        public override string StatusMessage
        {
            get { return string.Empty; }
        }

        public override void StopJob()
        {
            Dispatcher dispatch = Dispatcher.FromThread(jobThread);
            if (dispatch != null)
            {
                if (!dispatch.HasShutdownStarted)
                {
                    dispatch.InvokeShutdown();
                }
            }
            powerShellCommand.Stop();
            runspace.Close();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                powerShellCommand.Dispose();
                runspace.Close();
                runspace.Dispose();
            }
            base.Dispose(disposing);
        }

        #region INotifyPropertyChanged Members

        public event PropertyChangedEventHandler PropertyChanged;

        #endregion
    }
}
