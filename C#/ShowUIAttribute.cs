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
    using System.Windows.Input;

    public class ShowUICommands
    {
        private static RoutedCommand backgroundPowerShellCommand = new RoutedCommand();

        public static RoutedCommand BackgroundPowerShellCommand
        {
            get
            {
                return backgroundPowerShellCommand;
            }
        }
    }
}