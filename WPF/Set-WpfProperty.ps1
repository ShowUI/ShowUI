function Set-WpfProperty
{
    <#
    .Synopsis
        Sets properties on an object or subscribes to events
    .Description
        Set-WpfProperty is used by each parameter in the automatically generated
        controls in ShowUI.
    .Parameter InputObject
        The object to set properties on
    .Parameter Hashtable
        A Hashtable contains properties to set.
        The key is the name of the property on an object, or "On_" + the name 
        of an event you can subscribe to (i.e. On_Loaded).
        The value can either be a literal value (such as a string), a block of XAML,
        or a script block that produces the value that needs to be set.
    .Example
        $window = New-Window
        $window | Set-WpfProperty @{Width=100;Height={200}} 
        $window | show-Window
    #>
    param(    
    [Parameter(ValueFromPipeline=$true)]    
    [Object[]]$InputObject,
    
    [Parameter(Position=0)] 
    [Hashtable]$Property,
    
    [switch]$AllowXaml,
    
    [switch]$DoNotAutoCreateLabel,
    
    [Switch]$PassThru
    )
       
    process {
        Write-Verbose "Set-WpfProperty on $InputObject $(if($InputObject -eq $null) { "NULL!?"} else { $InputObject.GetType().FullName })"
        foreach($object in $InputObject | % { $_ }) {
            Write-Verbose "Set-WpfProperty on $object $(if($object -eq $null) { "NULL!?"} else { $object.GetType().FullName })"

            $inAsJob  = $host.Name -eq 'Default Host'
            if ($object.GetValue -and 
                ($object.GetValue([ShowUI.ShowUISetting]::StyleNameProperty))) {
                # Since Set-WpfProperty will be called by Set-UIStyle, make sure to check the callstack
                # rather than infinitely recurse            
                $styleName = $object.GetValue([ShowUI.ShowUISetting]::StyleNameProperty)

                if ($styleName) {
                    $setUiStyleInCallStack = foreach ($_ in (Get-PSCallStack)) { 
                        if ($_.Command -eq 'Set-UIStyle') { $_ }
                    }
                    if (-not $setUiStyleInCallStack) {
                        Set-UIStyle -Visual $object -StyleName $StyleName 
                    }
                } 
            }
                
            if ($property) {
                Write-Verbose "Setting $($property.Keys -join ',') on $object"
                $p = $property
                foreach ($k in $p.Keys) {
                    $realKey = $k                    
                    if ($k.StartsWith("On_")) {
                        $realKey = $k.Substring(3)
                    }
                    Write-Verbose "Setting $realKey on $object to $($p[$k])"

                    if ($object.GetType().GetEvent($realKey)) {
                        Write-Verbose "Setting EventHandler On_$realKey on $object"
                        # It's an Event!
                        foreach ($sb in $p[$k]) {
                            Add-EventHandler $object $realKey $sb
                        } 
                        continue
                    }
                    
                    $realItem  = $object.psObject.Members[$realKey]
                    if (-not $realItem) { 
                        # Add support for Grid Options
                        switch($realKey) {
                            "Row" {
                                Write-Verbose "Setting Grid.Row on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.Grid]::RowProperty, $p[$realKey])
                            }
                            "Column" {
                                Write-Verbose "Setting Grid.Column on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.Grid]::ColumnProperty, $p[$realKey])
                            }
                            "RowSpan" {
                                Write-Verbose "Setting Grid.RowSpan on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.Grid]::RowSpanProperty, $p[$realKey])
                            }
                            "ColumnSpan" {
                                Write-Verbose "Setting Grid.ColumnSpan on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, $p[$realKey])
                            }
                            "ZIndex" {
                                Write-Verbose "Setting Panel.ZIndex on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.Panel]::ZIndexProperty, $p[$realKey])
                            }
                            "Dock" {
                                Write-Verbose "Setting DockPanel.Dock on $($object.GetType().FullName) to $($p[$realKey])"                                
                                $Object.SetValue([Windows.Controls.DockPanel]::DockProperty, $p[$realKey])
                            }
                            default {
                                Write-Verbose "Could not set $realKey on $($object.GetType().FullName)"
                            }
                        }
                        continue
                    }

                    $itemName = $realItem.Name
                    if ($realItem.MemberType -eq 'Property') {
                        if ($realItem.Value -is [Collections.IList]) {
                            $v = $p[$realKey]
                            Write-Verbose "$itemName is collection on $($object.GetType().FullName)"
                            $collection = $object.$itemName
                            if (-not $v) { continue } 
                            if ($v -is [ScriptBlock]) { 
                                if ($inAsJob) {
                                    $v = . ([ScriptBlock]::Create($v))
                                } else {
                                    $v = . $v
                                }
                            }
                            if (-not $v) { continue } 

                            foreach ($ri in $v) {
                                Write-Verbose "`n`tAdding $ri to $object.$itemName"
                                $null = $collection.Add($ri)
                                trap [Management.Automation.PSInvalidCastException] {
                                    $label = New-Label $ri
                                    $null = $collection.Add($label)
                                    continue
                                }
                            }
                            # Write-Host
                        } else {
                            $v = $p[$realKey]
                            if ($v -is [ScriptBlock]) {
                                if ($inAsJob) {
                                    $v = . ([ScriptBlock]::Create($v))
                                } else {
                                    $v = . $v
                                }
                            }
                            Write-Verbose "Setting Property $itemName ($k) on $($realItem.GetType().FullName) to $v"

                            if ($allowXaml) {
                                $xaml = ConvertTo-Xaml $v
                                if ($xaml) {
                                    try {
                                        $rv = [Windows.Markup.XamlReader]::Parse($xaml)
                                        if ($rv) { $v = $rv } 
                                    }
                                    catch {
                                        Write-Debug ($_ | Out-String)
                                    }
                                }
                            }

                            if($debugPreference -ne 'SilentlyContinue') {
                                Write-Host
                                Write-Debug "Control: $($object.GetType().FullName)"
                                Write-Debug "Type: $(@($v)[0].GetType().FullName)"
                                Write-Debug "Property: $($realItem.TypeNameOfValue)"
                                Write-Debug "IsBinding? $(@($v)[0] -is [System.Windows.Data.Binding]) -and ( $($realItem.TypeNameOfValue -eq "System.Object") -or $(!($realItem.TypeNameOfValue -as [Type]).IsAssignableFrom([System.Windows.Data.BindingBase])) )"
                            }

                            # Two Special cases: Templates and Bindings
                            if([System.Windows.FrameworkTemplate].IsAssignableFrom( $realItem.TypeNameOfValue -as [Type]) -and 
                                $v -isnot [System.Windows.FrameworkTemplate]
                            ) {
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "TEMPLATING: $object"
                                }
                                $Template = $v | ConvertTo-DataTemplate -TemplateType ( $realItem.TypeNameOfValue -as [Type])
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "TEMPLATING: $([System.Windows.Markup.XamlWriter]::Save( $Template ))"
                                }
                                $object.$itemName = $Template

                            } elseif(@($v)[0] -is [System.Windows.Data.Binding] -and 
                                    (($realItem.TypeNameOfValue -eq "System.Object") -or 
                                    !($realItem.TypeNameOfValue -as [Type]).IsAssignableFrom([System.Windows.Data.BindingBase]))
                            ) {
                                $Binding = @($v)[0];

                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "BINDING: $($object.GetType()::"${realKey}Property") $(if($object.GetType()::"${realKey}Property" -is [Windows.DependencyProperty]){ '(A DependencyProperty)' })"
                                }

                                $Prop = $Object.GetType()::"${realKey}Property"

                                if($Prop -and $Prop -is [Windows.DependencyProperty]) {
                                    try {
                                        Write-Debug (
                                            $Object.SetBinding(
                                                $Prop,
                                                $Binding) | Out-String
                                            ) 
                                    } catch {
                                        Write-Debug "Nope, was not able to set it."
                                        Write-Debug $_
                                        Write-Debug $this
                                        $object.$itemName = $v -as $v.GetType()
                                    }
                                } else {
                                    Write-Debug "Oh Shoot, that's not a Dependency Property"
                                    $object.$itemName = $v -as $v.GetType()
                                }

                            } else {
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "Setting $($object.GetType().Name).$itemName to $($v.GetType().Name)"
                                }
                                Write-Verbose "Setting $($object.GetType().Name).$itemName to $($v.GetType().Name)"
                                $object.$itemName = $v -as $v.GetType()
                            }
                        }
                    } elseif ($realItem.MemberType -eq 'Method') {
                        Write-Verbose "Invoking Method $itemName on $($realItem.GetType().FullName) with $($p[$realKey])"
                        $object."$($itemName)".Invoke(@($p[$realKey]))
                    }
                }
            }
            
            if ($passThru) {
                $object
            }
        }
    }
}
