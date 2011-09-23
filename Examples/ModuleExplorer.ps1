New-Grid -Columns ('Auto', '1*') -Rows ('1*','Auto') -Resource @{
    'Import-ModuleData' = {
        $modules = @(Get-Module) + @(Get-Module -ListAvailable) | 
            Select-Object Name, Path, ExportedCommands -Unique | 
            Sort-Object Name
        foreach ($m in $modules) {
            New-TreeViewItem -Header $m.Name -DataContext $m -ItemsSource @(
                $m.ExportedCommands.Values | Sort-Object Name
            ) 
        }                            
    }
} {
    New-TreeView -FontSize 24 -Name ModuleTree -On_loaded {        
        ${Import-ModuleData} | Add-ChildControl -parent $this -Clear
    } -On_SelectedItemChanged {         
        $remove.IsEnabled = -not ($this.SelectedItem -is [Management.Automation.CommandInfo])        
        $ShowHelp.IsEnabled = ($this.SelectedItem -is [Management.Automation.CommandInfo])        
    }    
    New-UniformGrid -Row 1 -ColumnSpan 2 -Columns 3 {
        New-Button -FontSize 18 -Row 1 -Name "Import" "_Import-Module" -On_Click {
            $name = $moduleTree.SelectedItem.Header
            Import-Module $name -Force -Global
            $null = $moduleTree.Items.Clear()        
            ${Import-ModuleData} | Add-ChildControl -parent $moduleTree -Clear
        }
        New-Button -FontSize 18 -Row 1 -Column 1 -Name "Remove" "_Remove-Module" -On_Click {        
            $name = $moduleTree.SelectedItem.Header
            Remove-Module $name -Force                
            ${Import-ModuleData} | Add-ChildControl -parent $moduleTree -Clear
        }    
        New-Button -FontSize 18 -Row 1 -Column 2 -Name "ShowHelp" "Get-_Help" -On_Click {
            
            $name = $moduleTree.SelectedItem.Name
            $helpContainer.Child = Show-Help $name        
        }
    }
    
    New-Border -Name HelpContainer -Column 1
} -show
 
