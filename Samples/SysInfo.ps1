# Update-TypeData; Update-FormatData; 
ipmo PowerBoots\PoshWpf; ipmo PowerBoots

##  A simple example of how to use data templates to make it easy to convert an object to a GUI;

Add-BootsTemplate C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\XamlTemplates\SysInfo.xaml

$properties = @"
public string Hostname { get; set; }
public string Domain { get; set; }
"@
$asm = Add-Type -MemberDefinition $properties -name "ComputerInfo" -namespace SysInfo -Language CSharpVersion3 -OutputType Library -OutputAssembly Computer.dll -passThru
$pc = new-object SysInfo.ComputerInfo -Prop @{ Hostname = $Env:COMPUTERNAME; Domain = $Env:USERDOMAIN }

New-BootsWindow { $pc }.GetNewClosure()

#  $type = Add-Type -Type "namespace PowerBoots.SysInfo { public class Computer {
#  public string Hostname;
#  } }" -PassThru | %{$_.Assembly.FullName -split "," | select -first 1}
