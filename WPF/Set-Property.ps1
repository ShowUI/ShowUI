function Set-Property
{
    <#
    .Synopsis
        Sets properties on an object or subscribes to events
    .Description
        Set-Property is used by each parameter in the automatically generated
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
        $window | Set-Property @{Width=100;Height={200}} 
        $window | show-Window
    #>
    param(    
    [Parameter(ValueFromPipeline=$true)]    
    [Object[]]$inputObject,
    
    [Parameter(Position=0)] 
    [Hashtable]$property,
    
    [switch]$AllowXaml,
    
    [switch]$doNotAutoCreateLabel,
    
    [Switch]$PassThru
    )
       
    process {
        foreach($object in $inputObject) {
            $inAsJob  = $host.Name -eq 'Default Host'
            if ($object.GetValue -and 
                ($object.GetValue([ShowUI.ShowUISetting]::StyleNameProperty))) {
                # Since Set-Property will be called by Set-UIStyle, make sure to check the callstack
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
                # Write-Verbose "Setting $($property.Keys -join ',') on $object"
                $p = $property
                foreach ($k in $p.Keys) {
                    $realKey = $k
                    if ($k.StartsWith("On_")) {
                        $realKey = $k.Substring(3)
                    }

                    if ($object.GetType().GetEvent($realKey)) {
                        # It's an Event!
                        foreach ($sb in $p[$k]) {
                            Add-EventHandler $object $realKey $sb
                        } 
                        continue
                    }
                    
                    $realItem  = $object.psObject.Members[$realKey]
                    if (-not $realItem) { 
                        continue 
                    }

                    $itemName = $realItem.Name
                    if ($realItem.MemberType -eq 'Property') {
                        if ($realItem.Value -is [Collections.IList]) {
                            $v = $p[$realKey]
                            # Write-Host "$itemName is collection on $object " -fore cyan -nonewline
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
                                # Write-Host "`n`tAdding $ri to $object.$itemName" -fore cyan -nonewline
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
                                Write-Debug "Control: $($object.GetType().FullName)"
                                Write-Debug "Type: $(@($v)[0].GetType().FullName)"
                                Write-debug "Property: $($realItem.TypeNameOfValue)"
                            }

                            # Two Special cases: Templates and Bindings
                            if([System.Windows.FrameworkTemplate].IsAssignableFrom( $realItem.TypeNameOfValue -as [Type]) -and 
                               $v -isnot [System.Windows.FrameworkTemplate]) {
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "TEMPLATING: $object" -fore Yellow
                                }
                                $Template = $v | ConvertTo-DataTemplate -TemplateType ( $realItem.TypeNameOfValue -as [Type])
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "TEMPLATING: $([System.Windows.Markup.XamlWriter]::Save( $Template ))" -fore Yellow
                                }
                                $object.$itemName = $Template

                            } elseif(@($v)[0] -is [System.Windows.Data.Binding] -and 
                                    (($realItem.TypeNameOfValue -eq "System.Object") -or 
                                    !($realItem.TypeNameOfValue -as [Type]).IsAssignableFrom([System.Windows.Data.BindingBase]))
                            ) {
                                $Binding = @($v)[0];
                                if($debugPreference -ne 'SilentlyContinue') {
                                    Write-Debug "BINDING: $($object.GetType()::"${realKey}Property")" -fore Green
                                }

                                if(!$Binding.Source -and !$Binding.ElementName) {
                                    $Binding.Source = $object.DataContext
                                }
                                if($object.GetType()::"${realKey}Property" -is [Windows.DependencyProperty]) {
                                    try {
                                        # $object.Resources.Clear()
                                        $null = $object.SetBinding( ($object.GetType()::"${realKey}Property"), $Binding )
                                    } catch {
                                        Write-Debug "Nope, was not able to set it." -fore Red
                                        Write-Debug $_ -fore Red
                                        Write-Debug $this -fore DarkRed
                                    }
                                } else {
                                    $object.$itemName = $v
                                }
                            } else {
                                $object.$itemName = $v
                            }
                        }
                    } elseif ($realItem.MemberType -eq 'Method') {
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