namespace PoshWpf.Data {
   using System;
   using System.Collections.Generic;
   using System.Collections.Specialized;
   using System.Management.Automation;
   using System.Management.Automation.Runspaces;
   using System.Windows.Data;
   using System.Windows.Threading;
   using System.Collections.ObjectModel;

   [Cmdlet(VerbsCommon.New, "ScriptDataSource")]
   public class NewScriptDataSourceCommand : Cmdlet {
      [Parameter(Mandatory = true, Position = 0, HelpMessage = "A scriptblock to execute")]
      public ScriptBlock Script { get; set; }

      [Parameter(Mandatory = false, Position = 1, ParameterSetName = "Interval", HelpMessage = "Delay between re-running the script")]
      [Alias("TimeSpan","Every","Each")]
      public TimeSpan Interval { get; set; }

      [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Performance", "CA1819:PropertiesShouldNotReturnArrays"),
       Parameter(Mandatory = false, Position = 10, HelpMessage = "Input parameters to the ScriptBlock", ValueFromRemainingArguments = true, ValueFromPipeline = true)]
      [Alias("IO")]
      public PSObject[] InputObject { get; set; }

      [Parameter(Mandatory = false)]
      public SwitchParameter AccumulateOutput { get; set; }

      [Parameter(Mandatory = false)]
      public SwitchParameter LongRunning { get; set; }

      private List<PSObject> _input;
      protected override void BeginProcessing() {
         _input = new List<PSObject>();
         base.BeginProcessing();
      }
      protected override void ProcessRecord() {
         if (InputObject != null)
            _input.AddRange(InputObject);

         base.ProcessRecord();
      }

      [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Reliability", "CA2000:Dispose objects before losing scope")]
      protected override void EndProcessing() {
         WriteObject(new ScriptDataSource(Script, _input, Interval, AccumulateOutput.ToBool(), LongRunning.ToBool()));

         base.EndProcessing();
      }
   }

   public class ScriptDataSource : PSDataCollection<PSObject>, INotifyCollectionChanged {
      private readonly PowerShell _powerShellCommand;
      private readonly DispatcherTimer _timer;

      public ListCollectionView Progress { get; private set; }
      public ListCollectionView Verbose { get; private set; }
      public ListCollectionView Warning { get; private set; }
      public ListCollectionView Error { get; private set; }

      protected bool AccumulateOutput { get; set; }

      protected TimeSpan TimeSpan { get; set; }

      protected ScriptBlock Script { get; set; }

      public ScriptDataSource(ScriptBlock script)
         : this(script, null, new TimeSpan(), false, false) { }

      public ScriptDataSource(ScriptBlock script, IList<PSObject> input, TimeSpan interval, bool accumulateOutput, bool longRunning)
         : base() {

         Script = script;
         TimeSpan = TimeSpan.Zero;
         AccumulateOutput = accumulateOutput;

         _powerShellCommand = PowerShell.Create().AddScript(Script.ToString());
         if (longRunning) {
            var runspace = RunspaceFactory.CreateRunspace();
            runspace.Open();
            _powerShellCommand.Runspace = runspace;
         }

         Error = new ListCollectionView(_powerShellCommand.Streams.Error);
         Warning = new ListCollectionView(_powerShellCommand.Streams.Warning);
         Verbose = new ListCollectionView(_powerShellCommand.Streams.Verbose);
         Progress = new ListCollectionView(_powerShellCommand.Streams.Progress);

         if (!longRunning) {
            Invoke(input).AsyncWaitHandle.WaitOne();
         }

         if (TimeSpan.Zero < interval) {
            TimeSpan = interval;
            _timer = new DispatcherTimer(interval, DispatcherPriority.Normal, Invoke, Dispatcher.CurrentDispatcher);
            _timer.Start();
         }
      }

      public void Start() {
         if (_timer != null)
            _timer.Start();
      }

      public void Stop() {
         if (_timer != null)
            _timer.Stop();
      }

      private void Invoke(object sender, EventArgs e) {
         if (PSInvocationState.Completed == _powerShellCommand.InvocationStateInfo.State ||
             PSInvocationState.Stopped == _powerShellCommand.InvocationStateInfo.State ||
             PSInvocationState.NotStarted == _powerShellCommand.InvocationStateInfo.State ||
             PSInvocationState.Failed == _powerShellCommand.InvocationStateInfo.State) {
            Console.WriteLine("Tick");
            Invoke(null);
         }
         else {
            Console.WriteLine("No Tick");
            // string invocationSkipped = "Skipped Invocation Because the current InvocationState is " + _powerShellCommand.InvocationStateInfo.State + " (" + _powerShellCommand.InvocationStateInfo.Reason + ")";
            if (Warning.CanAddNew) {
               var w = Warning.AddNew();
               Console.WriteLine(w.GetType().FullName);
               Warning.CancelNew();
            }
         }
      }

      public IAsyncResult Invoke(IList<PSObject> input) {
         using (var inputCollection = (input != null && input.Count > 0) 
                    ? new PSDataCollection<PSObject>(input)
                    : new PSDataCollection<PSObject>()) {
            Console.WriteLine("There were " + this.Count);

            if (!AccumulateOutput) {
               Clear();
            }

            return _powerShellCommand.BeginInvoke<PSObject, PSObject>(inputCollection, this, new PSInvocationSettings(), (e) => {
               if (CollectionChanged != null) {
                  Console.WriteLine("There are " + this.Count);
                  CollectionChanged(this, new NotifyCollectionChangedEventArgs(NotifyCollectionChangedAction.Reset));
               }
            }, null);
         }
      }

      public event NotifyCollectionChangedEventHandler CollectionChanged;
   }
}
