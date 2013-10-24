namespace ShowUI
{
    using System;
    using System.Collections.Generic;
    using System.Text;
    using System.ComponentModel;
    using System.Collections.ObjectModel;
    using System.Management.Automation;
    using System.Windows;
    using System.Collections;
    using System.Management.Automation.Runspaces;
    using System.Timers;
    using System.Windows.Threading;
    using System.Threading;

    public class PowerShellDataSource : INotifyPropertyChanged
    {
        Hashtable resources = new Hashtable();

        public Hashtable Resources
        {
            get { return this.resources; }
        }

        public Dispatcher Dispatcher
        {
            get;
            set;
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
            SynchronizationContext sync = new DispatcherSynchronizationContext(Dispatcher);
            if (sync == null) { return null; }
            if (asynchronous)
            {
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

            }
            else
            {
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


        public Object Parent
        {
            get { return this.parent; }
            set
            {
                this.parent = value;
                if (this.parent != null &&
                        this.parent.GetType().GetProperty("Dispatcher") != null)
                {
                    Dispatcher = this.parent.GetType().GetProperty("Dispatcher").GetValue(this.parent, null) as Dispatcher;
                }
            }
        }


        private Object parent;

        public PSObject[] Output
        {
            get
            {
                PSObject[] returnValue = new PSObject[outputCollection.Count];
                outputCollection.CopyTo(returnValue, 0);
                return returnValue;
            }
        }
 
 
        PSObject lastOutput;
        public PSObject LastOutput
        {
            get
            {
                return lastOutput;
            }
        }

        public ErrorRecord[] Error
        {
            get
            {
                ErrorRecord[] returnValue = new ErrorRecord[powerShellCommand.Streams.Error.Count];
                powerShellCommand.Streams.Error.CopyTo(returnValue, 0);
                return returnValue;
            }
        }
 
        ErrorRecord lastError;
        public ErrorRecord LastError
        {
            get
            {
                return this.lastError;
            }
        }

        public WarningRecord[] Warning
        {
            get
            {
                WarningRecord[] returnValue = new WarningRecord[powerShellCommand.Streams.Warning.Count];
                powerShellCommand.Streams.Warning.CopyTo(returnValue, 0);
                return returnValue;
            }
        }
 
        WarningRecord lastWarning;
 
        public WarningRecord LastWarning
        {
            get
            {
                return lastWarning;
            }
        }

        public VerboseRecord[] Verbose
        {
            get
            {
                VerboseRecord[] returnValue = new VerboseRecord[powerShellCommand.Streams.Verbose.Count];
                powerShellCommand.Streams.Verbose.CopyTo(returnValue, 0);
                return returnValue;
            }
        }
 
        VerboseRecord lastVerbose;
        public VerboseRecord LastVerbose
        {
            get
            {
                return lastVerbose;
            }
        }


        public DebugRecord[] Debug
        {
            get
            {
                DebugRecord[] returnValue = new DebugRecord[powerShellCommand.Streams.Debug.Count];
                powerShellCommand.Streams.Debug.CopyTo(returnValue, 0);
                return returnValue;
            }
        }
 
        DebugRecord lastDebug;
        public DebugRecord LastDebug
        {
            get
            {
                return lastDebug;
            }
        }


        public ProgressRecord[] Progress
        {
            get
            {
                ProgressRecord[] returnValue = new ProgressRecord[powerShellCommand.Streams.Progress.Count];
                powerShellCommand.Streams.Progress.CopyTo(returnValue, 0);
                return returnValue;
            }
        }

        public PSObject[] TimeStampedOutput
        {
            get
            {
                PSObject[] returnValue = new PSObject[timeStampedOutput.Count];
                timeStampedOutput.CopyTo(returnValue, 0);
                return returnValue;
            }
        }

        private PSObject lastTimeStampedOutput;

        public PSObject LastTimeStampedOutput
        {
            get
            {
                return this.lastTimeStampedOutput;
            }
        }


        ProgressRecord lastProgress;
 
        public ProgressRecord LastProgress
        {
            get
            {
                return lastProgress;
            }
        }
        
        public PowerShell Command
        {
            get {
                return powerShellCommand;
            }
        }

        public bool IsFinished
        {
            get
            {
                return (powerShellCommand.InvocationStateInfo.State == PSInvocationState.Completed ||
                        powerShellCommand.InvocationStateInfo.State == PSInvocationState.Failed ||
                        powerShellCommand.InvocationStateInfo.State == PSInvocationState.Stopped);
            }
        }

        public bool IsRunning
        {
            get
            {
                return (powerShellCommand.InvocationStateInfo.State == PSInvocationState.Running ||
                    powerShellCommand.InvocationStateInfo.State == PSInvocationState.Stopping);
            }
        }


        string script;

        PSDataCollection<PSObject> timeStampedOutput;

        public string Script
        {
            get
            {
                return script;
            }
            set
            {
                script = value;
                try
                {
                    powerShellCommand.Commands.Clear();
                    powerShellCommand.AddScript(script, false);
                    lastDebug = null;
                    lastError = null;
                    lastTimeStampedOutput = null;
                    outputCollection.Clear();
                    timeStampedOutput.Clear();
                    lastOutput = null;
                    lastProgress = null;
                    lastVerbose = null;
                    lastWarning = null;
                    powerShellCommand.BeginInvoke<Object, PSObject>(null, outputCollection);
                }
                catch
                {
 
                }
            }
        }

        void powerShellCommand_InvocationStateChanged(object sender, PSInvocationStateChangedEventArgs e)
        {
            if (e.InvocationStateInfo.State == PSInvocationState.Failed)
            {
                ErrorRecord err = new ErrorRecord(e.InvocationStateInfo.Reason, "PowerShellDataSource.TerminatingError", ErrorCategory.InvalidOperation, powerShellCommand);
                powerShellCommand.Streams.Error.Add(err);
            }
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyInvocationStateChanged();
                            return null;
                        }),
                        true);
            }
            else
            {

                NotifyInvocationStateChanged();
            }


        }

        PowerShell powerShellCommand;
        PSDataCollection<PSObject> outputCollection;
        public PowerShellDataSource()
        {
            powerShellCommand =  PowerShell.Create();
            Runspace runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();
            powerShellCommand.Runspace = runspace;
            outputCollection = new PSDataCollection<PSObject>();
            timeStampedOutput = new PSDataCollection<PSObject>();
            powerShellCommand.InvocationStateChanged += new EventHandler<PSInvocationStateChangedEventArgs>(powerShellCommand_InvocationStateChanged);
            outputCollection.DataAdded += new EventHandler<DataAddedEventArgs>(outputCollection_DataAdded);
            timeStampedOutput.DataAdded += new EventHandler<DataAddedEventArgs>(timeStampedOutput_DataAdded);
            powerShellCommand.Streams.Debug.DataAdded += new EventHandler<DataAddedEventArgs>(Debug_DataAdded);
            powerShellCommand.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(Error_DataAdded);
            powerShellCommand.Streams.Verbose.DataAdded += new EventHandler<DataAddedEventArgs>(Verbose_DataAdded);
            powerShellCommand.Streams.Progress.DataAdded += new EventHandler<DataAddedEventArgs>(Progress_DataAdded);
            powerShellCommand.Streams.Warning.DataAdded += new EventHandler<DataAddedEventArgs>(Warning_DataAdded);
        }

        public PowerShellDataSource(string name) : this()
        {
            this.Name = name;
        }

        public string Name { get; private set; }

        #region Notification Methods
        void NotifyTimeStampedOutputChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("TimeStampedOutput"));
            }

            if (TimeStampedOutputChanged != null)
            {
                TimeStampedOutputChanged(sender, new PropertyChangedEventArgs("TimeStampedOutput"));
            }
        }

        void NotifyInvocationStateChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("IsFinished"));
                PropertyChanged(sender, new PropertyChangedEventArgs("IsRunning"));
            }

            if (IsFinishedChanged != null)
            {
                IsFinishedChanged(sender, new PropertyChangedEventArgs("IsFinished"));
            }

            if (IsRunningChanged != null)
            {
                IsRunningChanged(sender, new PropertyChangedEventArgs("IsRunning"));
            }
        }

        void NotifyErrorChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Error"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastError"));
            }

            if (ErrorChanged != null)
            {
                ErrorChanged(sender, new PropertyChangedEventArgs("Error"));
            }
        }
        void NotifyDebugChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Debug"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastDebug"));
            }

            if (DebugChanged != null)
            {
                DebugChanged(sender, new PropertyChangedEventArgs("Debug"));
            }
        }

        void NotifyOutputChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Output"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastOutput"));
            }

            if (OutputChanged != null)
            {
                OutputChanged(sender, new PropertyChangedEventArgs("Output"));
            }
        }

        void NotifyWarningChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Warning"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastWarning"));
            }

            if (WarningChanged != null)
            {
                WarningChanged(sender, new PropertyChangedEventArgs("Warning"));
            }
        }

        void NotifyVerboseChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Verbose"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastVerbose"));
            }

            if (VerboseChanged != null)
            {
                VerboseChanged(sender, new PropertyChangedEventArgs("Verbose"));
            }
        }

        void NotifyProgressChanged()
        {
            object sender;
            if (this.Parent != null)
            {
                sender = this.Parent;
            }
            else
            {
                sender = this;
            }

            if (PropertyChanged != null)
            {
                PropertyChanged(sender, new PropertyChangedEventArgs("Progress"));
                PropertyChanged(sender, new PropertyChangedEventArgs("LastProgress"));
            }

            if (ProgressChanged != null)
            {
                ProgressChanged(sender, new PropertyChangedEventArgs("Progress"));
            }
        }

        #endregion


        void timeStampedOutput_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<PSObject> collection = sender as PSDataCollection<PSObject>;
            lastTimeStampedOutput = collection[e.Index];
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyTimeStampedOutputChanged();
                            return null;
                        }),
                        true);
            }
            else
            {

                NotifyTimeStampedOutputChanged();
            }

        }
 
        void Debug_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<DebugRecord> collection = sender as PSDataCollection<DebugRecord>;
            lastDebug = collection[e.Index];
            PSObject psObj = new PSObject(lastDebug);
            PSPropertyInfo propInfo = new PSNoteProperty("TimeStamp", DateTime.Now);
            psObj.Properties.Add(new PSNoteProperty("Stream", "Debug"));
            psObj.Properties.Add(propInfo);
            timeStampedOutput.Add(psObj);

            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyDebugChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyDebugChanged();
            }

        }
 
        void Error_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<ErrorRecord> collection = sender as PSDataCollection<ErrorRecord>;
            this.lastError = collection[e.Index];
            PSObject psObj = new PSObject(lastError);
            PSPropertyInfo propInfo = new PSNoteProperty("TimeStamp", DateTime.Now);
            psObj.Properties.Add(new PSNoteProperty("Stream", "Error"));
            psObj.Properties.Add(propInfo);
            timeStampedOutput.Add(psObj);

            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyErrorChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyErrorChanged();
            }

        }
 
        void Warning_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<WarningRecord> collection = sender as PSDataCollection<WarningRecord>;
            lastWarning = collection[e.Index];
            PSObject psObj = new PSObject(lastWarning);
            psObj.Properties.Add(new PSNoteProperty("TimeStamp", DateTime.Now));
            psObj.Properties.Add(new PSNoteProperty("Stream", "Warning"));
            timeStampedOutput.Add(psObj);
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyWarningChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyWarningChanged();
            }


        }


        void Verbose_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<VerboseRecord> collection = sender as PSDataCollection<VerboseRecord>;
            lastVerbose = collection[e.Index];
            PSObject psObj = new PSObject(lastVerbose);
            PSPropertyInfo propInfo = new PSNoteProperty("TimeStamp", DateTime.Now);
            psObj.Properties.Add(new PSNoteProperty("Stream", "Verbose"));
            psObj.Properties.Add(propInfo);
            timeStampedOutput.Add(psObj);
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyVerboseChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyVerboseChanged();
            }
        }
 
        void Progress_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<ProgressRecord> collection = sender as PSDataCollection<ProgressRecord>;
            lastProgress = collection[e.Index];
            PSObject psObj = new PSObject(lastProgress);
            PSPropertyInfo propInfo = new PSNoteProperty("TimeStamp", DateTime.Now);
            psObj.Properties.Add(new PSNoteProperty("Stream", "Progress"));
            psObj.Properties.Add(propInfo);
            timeStampedOutput.Add(psObj);
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyProgressChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyProgressChanged();
            }
        }
 
        void outputCollection_DataAdded(object sender, DataAddedEventArgs e)
        {
            PSDataCollection<PSObject> collection = sender as PSDataCollection<PSObject>;
            lastOutput = collection[e.Index];
            PSObject psObj = new PSObject(lastOutput);
            PSPropertyInfo propInfo = new PSNoteProperty("TimeStamp", DateTime.Now);
            psObj.Properties.Add(new PSNoteProperty("Stream", "Output"));
            psObj.Properties.Add(propInfo);
            timeStampedOutput.Add(psObj);
            if (Dispatcher != null)
            {
                RunOnUIThread(
                        new DispatcherOperationCallback(
                        delegate
                        {
                            NotifyOutputChanged();
                            return null;
                        }),
                        true);
            }
            else
            {
                NotifyOutputChanged();
            }
        }


        public event PropertyChangedEventHandler PropertyChanged;

        public event PropertyChangedEventHandler OutputChanged;
        public event PropertyChangedEventHandler ErrorChanged;
        public event PropertyChangedEventHandler WarningChanged;
        public event PropertyChangedEventHandler DebugChanged;
        public event PropertyChangedEventHandler VerboseChanged;
        public event PropertyChangedEventHandler ProgressChanged;
        public event PropertyChangedEventHandler IsFinishedChanged;
        public event PropertyChangedEventHandler IsRunningChanged;
        public event PropertyChangedEventHandler TimeStampedOutputChanged;
    }
}
