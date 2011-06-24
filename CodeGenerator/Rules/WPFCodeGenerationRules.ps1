# Editing this file is not recommended.

# This file contains a series of rules which will help convert the types WPF
# interacts with the most to Script Cmdlets in PowerShell.  The rules are processed 
# in the order that they appear
Add-CodeGenerationRule -Filter {    
    $_.Fullname -like "*Commands"    
} -Change {
    $verb = "Get"
    $Noun = $baseType.Name.TrimEnd("s")

    # Give it a little bit of help
    $help.Synopsis = "Gets WPF Commands for $Noun" 
    $help.Description = "Gets WPF Commands for $Noun.
    These Commands are static properties from [$($baseType.FullName)]"
    $help.Example = @()
    $help.Example += "Get-$Noun"
    
    
    foreach ($prop in ($baseType | Get-Member -Static -MemberType Properties)) {
        $param = New-Object Management.Automation.ParameterMetaData $prop.Name, ([Switch])
        $null = $parameters.AddLast($param)
    }
    
    $null = $processBlocks.AddFirst(
        ([ScriptBlock]::Create("
        `$Type = '$($BaseType.FullName)' -as [Type]
        if (-not `$Type) { return }             
        "))
    )
    
    $null = $processBlocks.AddAfter($processBlocks.First, {
        
        foreach ($k in $psBoundParameters.Keys) {
            if (-not $k) {                 
                continue 
            }
            $type::$k
        }})            
}


Add-CodeGenerationRule -Filter {
    if ($_.IsAbstract) {
        throw "Cannot create New- Script Cmdlets for Abstract Types"
    }
    # This rule applies when there are no constructors for the given object
    $constructors = $_.GetConstructors()
    foreach ($c in $constructors) {
        if (-not $c) { return $false } 
        if (-not $c.GetParameters()) { return $true }
    }
    
} -Change {
    # Start with the basics, name the command
    $Verb = "New"
    $Noun = $BaseType.Name
    
    # Give it a little bit of help
    $help.Synopsis = "Creates a new $($BaseType.FullName)" 
    $help.Description = "Creates a new $($BaseType.FullName)"
    $help.Example = @()
    $help.Example += "New-$Noun"

    
    # The first thing the command will need to do is construct the object
    $null = $ProcessBlocks.AddFirst(([ScriptBlock]::Create("
        try {
        `$Object = New-Object $($BaseType.FullName)
        } catch {
            throw `$_
            return
        } ")))
    
    # Before it outputs the object, it needs to set the properties
    if (-not $script:SetPropertyScriptBlock) {
        $script:SetPropertyScriptBlock = {
        Set-Property -property $psBoundParameters -inputObject $Object}
    }
    $null = $ProcessBlocks.AddLast(($script:SetPropertyScriptBlock))
    
    # The last thing the command should do is output the object
    $null = $ProcessBlocks.AddLast(([ScriptBlock]::Create("
        `$Object")))
    
    
    # Collect all of the parameters for the type and add them to the parameters to the command    
    $params = @(ConvertTo-ParameterMetaData -type $BaseType)
    foreach ($p in $params) {
        $null = $parameters.AddLast($p)
    }
    
    # Add The Output Xaml Parameter
    $help.Parameter.OutputXaml = "If Set, will output the object as XAML instead of creating it"    
    $help.Example += "New-$Noun -OutputXaml"
    if (-not $script:OutputXamlParameter) {
        $script:OutputXamlParameter = 
            New-Object Management.Automation.ParameterMetaData "OutputXaml",([Switch]) 
    }
    $null = $parameters.AddLast($Script:OutputXamlParameter)
    if (-not $script:OutputXamlScriptBock) {
        $script:OutputXamlScriptBlock = {
        if ($outputXaml) {                
            $strWrite = New-Object IO.StringWriter
            ([xml]([Windows.Markup.XamlWriter]::Save($Object))).Save($strWrite)
            return "$strWrite"
        }}
    }    
    $null = $processBlocks.AddBefore($processBlocks.Last, $script:OutputXamlScriptBlock)
}

$ResourceChange = {
    # Change the type of the Resources Parameter
    $Resources = $Parameters | 
        Where-Object { $_.Name -eq "Resources" }
    if ($Resources) {
        $null = $Parameters.Remove($Resources)
    }
    if (-not $script:CachedResourcesParameter) {
        $script:CachedResourcesParameter = New-Object Management.Automation.ParameterMetaData "Resource", ([Hashtable])
    }        
    $null = $Parameters.AddLast($script:CachedResourcesParameter)        

    $Help.Parameter.Resource = "
    A Dictionary of Resources.  Use this dictionary to store information that 
    the rest of the user interface needs to access.
    "
    
    if (-not $script:ResourceBlock) {
        $Script:ResourceBlock = {
        if ($psBoundParameters.ContainsKey("Resource")) {
            foreach ($kv in $resource.GetEnumerator())
            {
                $null = $object.Resources.Add($kv.Key, $kv.Value)
            }            
            $null=$psBoundParameters.Remove("Resource")
        }}
    }
    
    $null = $ProcessBlocks.AddAfter($ProcessBlocks.First, $Script:ResourceBlock)        
}

Add-CodeGenerationRule -Type ([Windows.FrameworkTemplate]) -Change $ResourceChange

Add-CodeGenerationRule -Type ([Windows.FrameworkElement]) -Change ([ScriptBlock]::Create(
    "" +
    $ResourceChange +
    {
    if (-not $script:CachedDataBindingParameter) {
        $script:CachedDataBindingParameter = 
            New-Object Management.Automation.ParameterMetaData "DataBinding", ([Hashtable])
    }
    
    $null = $parameters.AddLast($script:CachedDataBindingParameter)
    
    if (-not $script:CachedDataBindingHandler) {
        $script:CachedDataBindingHandler = {
        if ($psBoundParameters.ContainsKey("DataBinding")) {
            $null = $psBoundParameters.Remove("DataBinding")
            foreach ($db in $DataBinding.GetEnumerator()) {
                if ($db.Key -is [Windows.DependencyProperty]) {
                    $Null = $Object.SetBinding($db.Key, $db.Value)
                } else {
                    $Prop = $Object.GetType()::"$($db.Key)Property"
                    if ($Prop) {
                        Write-Debug (
                        $Object.SetBinding(
                            $Prop,
                            $db.Value) | Out-String
                        ) 
                    }
                }
            }
        }}
    }
    
    $null = $processBlocks.AddAfter($processBlocks.First,  
        $script:CachedDataBindingHandler)
        
    if (-not $script:CachedUidGenerationHandler) {
        $script:CachedUidGenerationHandler = {
            $Object.Uid = [GUID]::NewGuid()
        }
    }

    $null = $processBlocks.AddAfter($processBlocks.First,  
        $script:CachedUidGenerationHandler)

    if (-not $script:CachedBuiltinResources) {
        $script:CachedBuiltinResources = {
    $Object.Resources.Timers = 
        New-Object Collections.Generic.Dictionary["string,Windows.Threading.DispatcherTimer"]
    $Object.Resources.TemporaryControls = @{}
    $Object.Resources.Scripts =
        New-Object Collections.Generic.Dictionary["string,ScriptBlock"]
    }}

    $null = $processBlocks.AddAfter($processBlocks.First,
        $script:CachedBuiltInResources)

}))

Add-CodeGenerationRule -Filter {
    $_.GetInterface("ICommandSource") 
} -Change {
    if (-not $script:CommandShortScriptBlock) {
        $script:CommandShortscriptBlock ={
        if ($command -is [string]) {
            $module =$myInvocation.MyCommand.Module.ModuleName
            $cmd = 
                Get-Command "Get-*Command" -Module $module | 
                    Where-Object {  $_.Parameters.$Command } 
            if ($cmd) {
                $params = @{$Command = $true}
                $psBoundParameters.Command = & $cmd @Params
            }
        }}
    }
    
    $null = $processBlocks.AddAfter($processBlocks.First, 
        $script:CommandShortscriptBlock)
}

Add-CodeGenerationRule -Type ([Windows.UIElement]) -Change {
    if (-not $Script:CachedRoutedEventParameter) {
        $Script:CachedRoutedEventParameter =
            New-Object Management.Automation.ParameterMetaData "RoutedEvent", 
                ([Hashtable])
        
    }
    $null = $parameters.AddLast($script:CachedRoutedEventParameter)
    if (-not $Script:CachedRoutedEventBlock) {
        $script:CachedRoutedEventBlock = {
        if ($PsBoundParameters.ContainsKey("RoutedEvent")) {
            $null = $PsBoundParameters.Remove("RoutedEvent")
            foreach ($re in $RoutedEvent.GetEnumerator()) {
                if ($re.Key -is [Windows.RoutedEvent]) {
                    $Null = $Object.AddHandler($re.Key, $re.Value -as $re.Key.HandlerType)
                } else {
                    $Event = $object.GetType()::"$($re.Key)Event"
                    if ($Event) {
                        $null = $Object.AddHandler(
                            $Event,
                            $re.Value -as $Event.HandlerType
                        ) 
                    }
                }
            }
        }}
    }
    $null = $processBlocks.AddAfter($ProcessBlocks.First, 
        $script:CachedRoutedEventBlock)
}

Add-CodeGenerationRule -Type ([Windows.Controls.Grid]) -Change {
    if (-not $Script:CachedGridParameters) {
        $Script:CachedGridParameters = @()
        $Script:CachedGridParameters +=
            New-Object Management.Automation.ParameterMetaData "Columns"
        $Script:CachedGridParameters += 
            New-Object Management.Automation.ParameterMetaData "Rows"
    }
    
    foreach ($gp in $Script:CachedGridParameters) {
        $null = $parameters.AddAfter($parameters.First, $gp)
    }
    
    $help.Parameter.Rows = "
    The Rows used in the Grid control.
    
    Rows can either be a number of rows of the same size (i.e. -Rows 2), 
    or a sequence of row sizes, such 'Auto', '2*', '1*', 40
    
    The above sequence would create a Grid with 4 rows, the first would be
    autosized, the second would be 2x of the remaining available space, the third
    would be 1x of the remaining available space, and the forth would be 40 pixels.
    "

    $help.Parameter.Columns = "
    The Columns used in the Grid control.
    
    Columns can either be a number of Columns of the same size (i.e. -Columns 2), 
    or a sequence of row sizes, such 'Auto', '2*', '1*', 40
    
    The above sequence would create a Grid with 4 Columns, the first would be
    autosized, the second would be 2x of the remaining available space, the third
    would be 1x of the remaining available space, and the forth would be 40 pixels.
    "
    
    $help.Example += 
@'
New-Grid -Rows 'Auto', 'Auto', 'Auto', '1*', 'Auto' `
    -Resource @{Items=@()} `
    -MinHeight 200 -Columns 1 -Children {
    New-Label -Content "Computer Name" -Row 0 -Column 0
    New-TextBox -MaxLength 100 -Row 1
    New-Button "_Add" -Row 2
    New-ListBox -Row 3
    New-Button "_Remove" -Row 4
} -show
'@
        
    if (-not $Script:CachedGridHandlerBlock) {
        $Script:CachedGridHandlerBlock = {
        if ($psBoundParameters.ContainsKey("Columns")) {
            $realColumns = ConvertTo-GridLength $columns
            foreach ($rc in $realColumns) {        
                $null = $Object.ColumnDefinitions.Add((
                    New-Object Windows.Controls.ColumnDefinition -Property @{
                        Width = $rc
                    }))       
            }
            $Null =$PsBoundParameters.Remove("Columns")
        }
        if ($psBoundParameters.ContainsKey("Rows")) {
            $realRows = ConvertTo-GridLength $rows
            foreach ($rr in $realRows) {        
                $null = $Object.RowDefinitions.Add((
                    New-Object Windows.Controls.RowDefinition -Property @{
                        Height = $rr
                    }))       
            }
            $Null =$PsBoundParameters.Remove("Rows")
        }}
    }
    
    $null = $ProcessBlocks.AddAfter($ProcessBlocks.First, $Script:CachedGridHandlerBlock)
}

Add-CodeGenerationRule -Type ([Windows.DependencyObject]) -Change {
    if (-not $Script:CachedDependencyPropertyParameter) {
        $script:CachedDependencyPropertyParameter = 
            New-Object Management.Automation.ParameterMetaData "DependencyProperty", 
                ([Hashtable])
    }
    $null = $parameters.AddLast($script:CachedDependencyPropertyParameter)
    if (-not $Script:CachedDependencyPropertyBlock) {
        $script:CachedDependencyPropertyBlock = {
        if ($PsBoundParameters.ContainsKey("DependencyProperty")) {
            $null = $PsBoundParameters.Remove("DependencyProperty")
            foreach ($dp in $dependencyProperty.GetEnumerator()) {
                if ($dp.Key -is [Windows.DependencyProperty]) {
                    $Null = $Object.SetValue($dp.Key, $dp.Value)
                } else {
                    $Prop = $Object.GetType()::"$($dp.Key)Property"
                    if ($Prop) {
                        $null = $Object.SetValue(
                            $Prop,
                            $dp.Value -as $Prop.PropertyType
                        ) 
                    }
                }
            }
        }}
    }
    $null = $processBlocks.AddAfter($ProcessBlocks.First, 
        $script:CachedDependencyPropertyBlock)   
}

Add-CodeGenerationRule -Type ([Windows.Controls.ItemsControl]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Items' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
} 

Add-CodeGenerationRule -Type ([Windows.Controls.Panel]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Children' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}


Add-CodeGenerationRule -Type ([Windows.Controls.ContentControl]) -Change {   
        $param = $parameters | Where-Object { $_.Name -eq 'Content' }
        $null = $parameters.Remove($param)
        $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.HeaderedContentControl]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Header' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.HeaderedItemsControl]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Header' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Documents.Paragraph]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Inlines' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Documents.Span]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Inlines' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Documents.FlowDocument]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Blocks' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.Primitives.TextBoxBase]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Text' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.Border]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Child' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}


Add-CodeGenerationRule -Type ([Windows.Media.GradientBrush]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'GradientStops' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.GridViewColumn]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Header' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
    $param = $parameters | Where-Object { $_.Name -eq 'DisplayMemberBinding' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddAfter($parameters.First, $param)
    
    if (-not $script:CachedGridViewColumnScriptBlock) {
        $script:CachedGridviewColumnScriptBlock = {
        if ($psBoundParameters.ContainsKey("DisplayMemberBinding")) {
            if ($psBoundParameters.DisplayMemberBinding -is [string]) {
                $psBoundParameters.DisplayMemberBinding =
                    New-Object Windows.Data.Binding $DisplayMemberBinding            
            }
        } else {
            $psBoundParameters.DisplayMemberBinding =
                New-Object Windows.Data.Binding $Header 
        }}
    }
    
    $null = $processBlocks.AddAfter($processBlocks.First, 
        $script:CachedGridViewColumnScriptBlock)
}

Add-CodeGenerationRule -Type ([Windows.Data.BindingBase]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Path' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

<#
Add-CodeGenerationRule -Filter {
    $_.GetProperty("Source")    
} -Change {    
    $ProcessBlocks.AddFirst({
        Write-Debug "Trying to Set Source: $($psBoundParameters.Source)"
        if ($psBoundParameters.Source) {
            Write-Debug "Source: $($psBoundParameters.Source)"
            $asUri = $psBoundParameters.Source -as [uri]
            if ($asUri -and ('http', 'https' -notcontains $asUri.Scheme)) {
                Write-Debug "Resolving Path $($psBoundParameters.Source)"
                $resolvedSource = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($psBoundParameters.Source)                
                Write-Debug "Path Resolved $resolvedSource"
                if ($resolvedSource) { 
                    $psBoundParameters.Source = $resolveSource
                }
            }            
        }
    })
}
#>

Add-CodeGenerationRule -Type ([Windows.Media.Visual]) -Change {
    # First make sure to clear Show before Set-Property gets it
    $null = $ProcessBlocks.AddAfter($ProcessBlocks.First, {
        $null = $psBoundParameters.Remove("Show")})        

    if (-not $script:CustomControlNameParameter) {
        $Script:CustomControlNameParameter = 
            New-Object Management.Automation.ParameterMetaData "ControlName", ([string])
    }
    
    $null = $Parameters.AddLast($script:CustomControlNameParameter)
    # Add the -ControlName block
    if (-not $script:CustomControlNameBlock) {
        $script:CustomControlNameBlock= {
            if ($ControlName) {
                $object.SetValue([ShowUI.ShowUISetting]::ControlNameProperty, $ControlName)
            }        
        }
    }
       
    $null = $ProcessBlocks.AddBefore($ProcessBlocks.Last, $CustomControlNameBlock)        

    if (-not $script:StyleNameParameter) {
        $Script:StyleNameParameter = 
            New-Object Management.Automation.ParameterMetaData "VisualStyle", ([string])
    }
    $null = $Parameters.AddLast($script:StyleNameParameter)
    # Add the -VisualStyle block
    if (-not $script:StyleNameBlock) {
        $script:StyleNameBlock= {
            if ($PSBoundParameters.ContainsKey("VisualStyle")) {
                $Object.SetValue([ShowUI.ShowUISetting]::StyleNameProperty, $PSBoundParameters.VisualStyle)
                $Null = $PSBoundParameters.Remove("VisualStyle")
            }
        }
    }
       
    $null = $ProcessBlocks.AddAfter($ProcessBlocks.First, $StyleNameBlock)      
    
    # Add the -Show parameter, caching the little parameter metadata object so the 
    # generator runs more quickly
    if (-not $script:CachedShowParameter) {
        $Script:CachedShowParameter = 
            New-Object Management.Automation.ParameterMetaData "Show", ([Switch])
    }
    $null = $Parameters.AddLast($script:CachedShowParameter)
    
    if (-not $script:CachedShowUIParameter) {
        $Script:CachedShowUIParameter = 
            New-Object Management.Automation.ParameterMetaData "ShowUI", ([Switch])
    }
    $null = $Parameters.AddLast($script:CachedShowUIParameter)

    
    
    
    # Add the -show block
    if (-not $script:CachedShowBlock) {
        $script:CachedShowBlock = {
        if ($show -or $showUI) {
            return Show-Window $Object 
        }}        
    }
    $null = $ProcessBlocks.AddBefore($ProcessBlocks.Last, $Script:CachedShowBlock)        
    
    
    $help.Parameter.Show = "
    If Set, will show the visual in a new window
    "
    $help.Example += "New-$Noun -Show"    
    
    if (-not $script:CachedGridAndZIndexParameters) {
        $script:CachedGridAndZIndexParameters = @()
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "Row", ([Int])
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "Column", ([Int])
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "RowSpan", ([Int])
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "ColumnSpan", ([Int])
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "ZIndex", ([Int])
        $script:CachedGridAndZIndexParameters +=
            New-Object Management.Automation.ParameterMetaData "Dock", ([Windows.Controls.Dock])

    }
    
    foreach ($gp in $script:CachedGridAndZindexParameters) {
        $node = $parameters.First
        $found = $false
        while ($node.Next) {
            if ($node.Value.Name -eq $gp.Name) { 
                # If one of the build in parameters is already there, 
                # make sure to get rid of it
                $null = $parameters.AddAfter($node, $gp)
                $null = $parameters.Remove($node)
                $found = $true
                break
            }
            $node = $node.Next
        }
        if (-not $found) {
            $null = $parameters.AddLast($gp)
        }
    }
    
    
    # Add support for the Grid Options
    if (-not $Script:CachedGridAndZIndexBlock) {
        $script:CachedGridAndZIndexBlock = {
        if ($PSBoundParameters.ContainsKey("Row")) {
            $Object.SetValue([Windows.Controls.Grid]::RowProperty, $row)
            $Null = $PSBoundParameters.Remove("Row")
        }
        if ($PSBoundParameters.ContainsKey("Column")) {
            $Object.SetValue([Windows.Controls.Grid]::ColumnProperty, $column)
            $Null = $PSBoundParameters.Remove("Column")
        }
        if ($PSBoundParameters.ContainsKey("RowSpan")) {
            $Object.SetValue([Windows.Controls.Grid]::RowSpanProperty, $rowSpan)
            $Null = $PSBoundParameters.Remove("RowSpan")
        }
        if ($PSBoundParameters.ContainsKey("ColumnSpan")) {
            $Object.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, $columnSpan)
            $Null = $PSBoundParameters.Remove("ColumnSpan")
        }
        if ($PSBoundParameters.ContainsKey("ZIndex")) {
            $Object.SetValue([Windows.Controls.Panel]::ZIndexProperty, $ZIndex)
            $Null = $PSBoundParameters.Remove("ZIndex")
        }
        if ($PSBoundParameters.ContainsKey("Dock")) {
            $Object.SetValue([Windows.Controls.DockPanel]::DockProperty, $Dock)
            $Null = $PSBoundParameters.Remove("Dock")
        }}
    }
    
    
    $null = $processBlocks.AddAfter($processBlocks.First, 
        $Script:CachedGridAndZIndexBlock)
    # Check for a Top Parameter, and add blocks for Top if none exist
    $TopFound = $false 
    foreach ($p in $parameters) {
        if ($p.Name -eq "Top") { 
            $TopFound = $true
            break
        }
    }
    
    if (-not $TopFound) {
        if (-not $script:CachedTopParameter) {
            $script:CachedTopParameter = New-Object Management.Automation.ParameterMetaData "Top", ([Double])
        }
        $null = $parameters.AddLast($Script:CachedTopParameter)
        if (-not $script:CachedTopScriptBlock) {
            $Script:CachedTopScriptBlock = {
        if ($PSBoundParameters.ContainsKey("Top")) {            
            $object.SetValue([Windows.Controls.Canvas]::TopProperty, $top)
            $Null = $PSBoundParameters.Remove("Top")
        }}
        }
        $null = $processBlocks.AddAfter($processBlocks.First, 
            $Script:CachedTopScriptBlock)
    }
    

    # Check for a Left Parameter, and add blocks for Left if none exist
    $LeftFound = $false 
    foreach ($p in $parameters) {
        if ($p.Name -eq "Left") { 
            $LeftFound = $true
            break
        }
    }
    
    if (-not $LeftFound) {
        if (-not $script:CachedLeftParameter) {
            $script:CachedLeftParameter = New-Object Management.Automation.ParameterMetaData "Left", ([Double])
        }
        $null = $parameters.AddLast($Script:CachedLeftParameter)
        if (-not $script:CachedLeftScriptBlock) {
            $Script:CachedLeftScriptBlock = {
        if ($PSBoundParameters.ContainsKey("Left")) {            
            $object.SetValue([Windows.Controls.Canvas]::LeftProperty, $Left)
            $Null = $PSBoundParameters.Remove("Left")
        }}
        }
        $null = $processBlocks.AddAfter($processBlocks.First, 
            $Script:CachedLeftScriptBlock)
    }
    
    # Add the -AsJob Parameter
    if (-not $Script:CachedAsJobParameter) {
        $Script:CachedAsJobParameter =
            New-Object Management.Automation.ParameterMetaData "AsJob", ([Switch])
    }
    $null = $Parameters.AddLast($Script:CachedAsJobParameter) 
    
    if (-not $Script:CachedJobSection) {
        $Script:CachedJobSection = {
        if ($PSBoundParameters.ContainsKey("AsJob")) {
            $null = $psBoundParameters.Remove("AsJob")
            $ScriptBlock = $MyInvocation.MyCommand.ScriptBlock
            $Command = $MyInvocation.InvocationName
            if (-not $Command) {
                $Command = "Start-WPFJob"
            }
            $Parameters = $PSBoundParameters
            
            $AdditionalContext = @(Get-PSCallstack)[1].InvocationInfo.MyCommand.Definition
            
            
            if (-not $AdditionalContext) { $AdditionalContext += {} }
            if ($AdditionalContext -like "*.ps1") { 
                $AdditionalContext = [ScriptBlock]::Create(
                    [IO.File]::ReadAllText($AdditionalContext)
                )
            } else {
                $AdditionalContext = [ScriptBlock]::Create($AdditionalContext)
            }

            
            $JobParameters = @{
                ScriptBlock = $MyInvocation.MyCommand.ScriptBlock
                Command = $Command
                AdditionalContext = $AdditionalContext
                Name = $Name
            }
            
            if (-not $JobParameters.Name) {
                $JobParameters.Name = $MyInvocation.InvocationName
            }

            if ($Parameters) {
                Start-WPFJob @JobParameters -Parameter $Parameters         
            } else {
                Start-WPFJob @JobParameters
            }
            return
        }}
    }

    $help.Parameter.AsJob = "
    If Set, will show the visual in a background WPF Job
    "
    $help.Example += "New-$Noun -AsJob"    
 
    
    $null = $ProcessBlocks.AddFirst($Script:CachedJobSection)
}

Add-CodeGenerationRule -Type ([Windows.Shapes.Shape]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Fill' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Shapes.Path]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'Data' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddFirst($param)
}

Add-CodeGenerationRule -Type ([Windows.Controls.Button]) -Change {
    $param = $parameters | Where-Object { $_.Name -eq 'On_Click' }
    $null = $parameters.Remove($param)
    $null = $parameters.AddAfter($parameters.First, $param)
}

