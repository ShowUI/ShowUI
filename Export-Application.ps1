function Export-Application
{
    <#
    .Synopsis
        Exports a WPK script into an executable
    .Description
        Exports a WPK script into an executable.
        Embeds all needed scripts within the executable, an
    .Example
        # Creates an .exe at the current path that runs digitalclock.ps1
        $clock = Get-Command $env:UserProfile\Documents\WindowsPowerShell\Modules\WPK\Examples\DigitalClock.ps1
        $clock | Export-Application 
    .Parameter Command
        The Command to turn into an application.
        The command should either be a function or an external script
    .Parameter Name
        The name of the .EXE to produce.  By default, the name will be the
        command name with an .EXE extension instead of a .PS1 extension
    .Parameter ReferencedAssemblies
        Additional Assemblies to Reference when compilign.
    .Parameter OutputPath
        If set, will output the executable into this path.
        By default, executables are outputted to the current directory.
    .Parameter TopModule
        The top level module to import.
        By default, this is the module that is exporting Export-Application
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Management.Automation.CommandInfo]
    $Command,    
    [string]
    $Name,    
    [Reflection.Assembly[]]
    $ReferencedAssemblies = @(),
    [String]$OutputPath,
    [switch]$DoNotEmbed,
    [string]$TopModule = $myInvocation.MyCommand.ModuleName 
    ) 

    process {       
        $optimize = $true
        Set-StrictMode -Off
        if (-not $name) {
            $name = $command.Name
            if ($name -like "*.ps1") {
                $name = $name.Substring(0, $name.LastIndexOf("."))
            }
        }
        
        $referencedAssemblies+= [PSObject].Assembly
        $referencedAssemblies+= [Windows.Window].Assembly
        $referencedAssemblies+= [System.Windows.Threading.DispatcherFrame].Assembly
        $referencedAssemblies+= [System.Windows.Media.Brush].Assembly
        
        if (-not $outputPath)  {
            $outputPath = "$name.exe"
        }
        
        $initializeChunk = ""
        foreach ($r in $referencedAssemblies) {
            if ($r -notlike "*System.Management.Automation*") {
                $initializeChunk += "
          #      [Reflection.Assembly]::LoadFrom('$($r.Location)')
                "
            }
        }
        
        if ($optimize) {
            $iss = [Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
            $builtInCommandNames = $iss.Commands | 
                Where-Object { $_.ImplementingType } | 
                Select-Object -ExpandProperty Name         

            $aliases = @{}
            $outputChunk = "" 
            $command | 
                Get-ReferencedCommand | 
                ForEach-Object {
                    if ($_ -is [Management.Automation.AliasInfo]) {
                        $aliases.($_.Name) = $_.ResolvedCommand
                        $_.ResolvedCommand
                    }
                    $_        
                } | Foreach-Object {
                    if ($_ -is [Management.Automation.CmdletInfo]) {
                        if ($builtInCommandNames -notcontains $_.Name) {
                            $outputChunk+= "
                            Import-Module '$($_.ImplementingType.Assembly.Location)'
                            "
                        }
                    }
                    $_        
                } | ForEach-Object {
                    if ($_ -is [Management.Automation.FunctionInfo]) {
                        $outputChunk += "function $($_.Name) {
                            $($_.Definition)
                        }
                        "
                    }
                }
                
                $outputChunk += $aliases.GetEnumerator() | ForEach-Object {
                    "
                    Set-Alias $($_.Key) $($_.Value)
                    "
                }                
            $initializeChunk += $outputChunk
        } else {
            $initializeChunk += "
            Import-Module '$topModule'
            "
        }
        if (-not $DoNotEmbed) {
            if ($command.ScriptContents) {
                $base64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command.ScriptContents))
            } else {
                if ($command.Definition) {
                    $base64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command.Definition))
                }
            }
            $argsSection = @"
                sb.Append(System.Text.Encoding.Unicode.GetString(Convert.FromBase64String("$base64")));
"@        
        } else {
            $argsSection = @'
                if (args.Length == 2) {
                    if (String.Compare(args[0],"-encoded", true) == 0) {
                        sb.Append(System.Text.Encoding.Unicode.GetString(Convert.FromBase64String(args[1])));
                    }
                } else {
                    foreach (string a in args) {
                        sb.Append(a);
                        sb.Append(" ");                
                    }            
                }
'@        
        }
        
        $initBase64 = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($initializeChunk))
        
      
        $applicationDefinition = @"
    
    using System;
    using System.Text;
    using System.Management.Automation;
    using System.Management.Automation.Runspaces;
        
    public static class $name {
        public static void Main(string[] args) {
            StringBuilder sb = new StringBuilder();

            $argsSection

            PowerShell psCmd = PowerShell.Create();
            Runspace rs = RunspaceFactory.CreateRunspace();
            rs.ApartmentState = System.Threading.ApartmentState.STA;
            rs.ThreadOptions = PSThreadOptions.ReuseThread;
            rs.Open();
            psCmd.Runspace =rs;
            psCmd.AddScript(Encoding.Unicode.GetString(Convert.FromBase64String("$initBase64")), false).Invoke();
            psCmd.Invoke();            
            psCmd.Commands.Clear();           
            psCmd.AddScript(sb.ToString());
            try {
                psCmd.Invoke();
            } catch (Exception ex) {
                System.Windows.MessageBox.Show(ex.Message, ex.GetType().FullName);                
                rs.Close();
                rs.Dispose();     
            }
            foreach (ErrorRecord err in psCmd.Streams.Error) {
                System.Windows.MessageBox.Show(err.ToString());
            }
            rs.Close();
            rs.Dispose();                        
        }
    }   
"@   
        Write-Verbose $applicationDefinition
        Add-Type $applicationDefinition -IgnoreWarnings -ReferencedAssemblies $referencedAssemblies `
            -OutputAssembly $outputPath -OutputType WindowsApplication
    }
}
