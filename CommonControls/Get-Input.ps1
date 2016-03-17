function Get-Input
{
    <#
    .Synopsis
        Collects user input
    .Description
        Get-Input collects a series of fields, and returns a hashtable of user-entered values
    .Example
        Get-Input ([ordered]@{
              FirstName = "John"
              LastName = "Doe"
              BirthDate = "DatePicker"
              UserName = "JDoe"
           }) -Show

        Name                           Value
        ----                           -----
        BirthDate                      5/26/1960 12:00:00 AM
        UserName                       JoeUser
        FirstName                      John
        LastName                       Smith
        
        This shows one way to prompt the user for a full name, birthdate (using a DatePicker) and username.

        Note that only USER-ENTERED values are returned. If the user enters nothing, you'll get nothing back.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            $in = $_
            $badKeys = $in.Keys | Where-Object { $_ -isnot [string] }
            if( $badKeys ) {
                throw "Not all field names were strings.  All field names must be strings."
            }
            
            $badValues = $in.Values |
                Where-Object {
                    $_ -isnot [Type] -and
                    $_ -isnot [System.Management.Automation.ScriptBlock] -and
                    $_ -isnot [System.String] -and
                    $_ -isnot [Windows.Media.Visual]
                } | % { $_.GetType().FullName }
            if ($badValues) {
                throw "Not all values were strings, types, or script blocks.  All values must be strings, types or script blocks.`n$badValues"
            }   
            return $true             
        })]
        [System.Collections.IDictionary]$Field,    
        [string[]]$Order,
        [switch]$HideOKCancel,    
        # The name of the control        
        [string]$Name,
        # If the control is a child element of a Grid control (see New-Grid),
        # then the Row parameter will be used to determine where to place the
        # top of the control.  Using the -Row parameter changes the 
        # dependency property [Windows.Controls.Grid]::RowProperty
        [Int]$Row,
        # If the control is a child element of a Grid control (see New-Grid)
        # then the Column parameter will be used to determine where to place
        # the left of the control.  Using the -Column parameter changes the
        # dependency property [Windows.Controls.Grid]::ColumnProperty
        [Int]$Column,
        # If the control is a child element of a Grid control (see New-Grid)
        # then the RowSpan parameter will be used to determine how many rows
        # in the grid the control will occupy.   Using the -RowSpan parameter
        # changes the dependency property [Windows.Controls.Grid]::RowSpanProperty 
        [Int]$RowSpan,
        # If the control is a child element of a Grid control (see New-Grid)
        # then the RowSpan parameter will be used to determine how many columns
        # in the grid the control will occupy.   Using the -ColumnSpan parameter
        # changes the dependency property [Windows.Controls.Grid]::ColumnSpanProperty
        [Int]$ColumnSpan,
        # The -Width parameter will be used to set the width of the control
        [Int]$Width, 
        # The -Height parameter will be used to set the height of the control
        [Int]$Height,
        # If the control is a child element of a Canvas control (see New-Canvas),
        # then the Top parameter controls the top location within that canvas
        # Using the -Top parameter changes the dependency property 
        # [Windows.Controls.Canvas]::TopProperty
        [Double]$Top,
        # If the control is a child element of a Canvas control (see New-Canvas),
        # then the Left parameter controls the left location within that canvas
        # Using the -Left parameter changes the dependency property
        # [Windows.Controls.Canvas]::LeftProperty
        [Double]$Left,
        # If the control is a child element of a Dock control (see New-Dock),
        # then the Dock parameter controls the dock style within that panel
        # Using the -Dock parameter changes the dependency property
        # [Windows.Controls.DockPanel]::DockProperty
        [Windows.Controls.Dock]$Dock,
        # If Show is set, then the UI will be displayed as a modal dialog within the current
        # thread.  If the -Show and -AsJob parameters are omitted, then the control should be 
        # output from the function
        [Switch]$Show,
        # If AsJob is set, then the UI will displayed within a WPF job.
        [Switch]$AsJob
    )
    
    $UIParameters=  @{} + $psBoundParameters
    $null = $uiParameters.Remove('Field')
    $null = $uiParameters.Remove('Order')
    $null = $uiParameters.Remove('HideOKCancel')
    New-Grid -Columns 'Auto', 1* -Rows ($field.Count + 3) -MinWidth 300 -ControlName Get-Input @UIParameters {
        $row = 0        

        if (-not $Order) {
            $Order = @($field.Keys)
            if($field -isnot [System.Collections.Specialized.IOrderedDictionary]){
                $Order = $Order | Sort-Object
            }
        }       

        foreach ($key in $Order) {            
            if ($field[$key]) {
                $value = $field[$key]
                New-Label $key -Row $row # | Add-ChildControl -parent $this

                $Properties = @{ Name = $key; Row = $row; Column = 1; Margin = 4 }
                         
                $cueText = ""
                $validatePattern = ""
                $expectedType = [PSObject]                                     
                if ($value -is [ScriptBlock]) {
                    if ($value.Render) {
                        # If Render is set, the ScriptBlock creates the contents of a stackpanel
                        # otherwise, the scriptblock is the validation
                        $command = $value
                    } else {
                        if ($value.AllowScriptEntry) {
                        }
                    }
                } elseif ($value -is [string]) {
                    # We now support using control names, if you're very specific:
                    $commands = @(Get-UICommand $value -Recurse -ErrorAction Ignore)
                    if($commands.Count -eq 1) { 
                        $command = $commands[0]
                    } else {
                        # Otherwise, the string is treated as cue text
                        $expectedType = if ($value.ExpectedType -as [Type]) { $value.ExpectedType } else {[PSObject] }
                        $command = $null
                    }
                } elseif ($value -is [Type]) {
                    # If a type is provided, try to find a match                     
                    $commands = @(Get-UICommand | 
                        Where-Object {
                            $outputTypes = ($_.OutputType | Select-Object -ExpandProperty Type)
                            (($outputTypes -contains $value) -or
                            ($outputTypes | Where-Object { $value.IsSubclassOf($_) })) 
                        })
                        
                    $useTextBox = $true
                                       
                    if (-not $commands) {
                        # No match, default to primitives
                        if ($value.CueText) {
                            $cueText =  $value.CueText
                        }
                        $expectedType = $value -as [type]
                        
                        if (@([bool], [switch]) -contains $value) 
                        {
                            $useTextBox = $false
                            if ($cueText) {
                                $checkBox = New-CheckBox -Margin 5 -Content "$cueText" -FontStyle Italic -Name $key -Row $row -Column 1 
                                $this.Children.Add($checkBox)
                            } else {
                                $this.Children.Add((New-CheckBox -Margin 5 -Name $key -Row $row -Column 1))
                            }
                            $row++
                            continue
                        }
                    } elseif ($commands.Count -gt 1) {
                        $getKeyMatch = foreach ($_ in $commands) { 
                            if ($_.Name -eq "Get-$Key") { $_ }                                                         
                        }
                        $editKeyMatch = foreach ($_ in $commands) {
                            if ($_.Name -eq "Edit-$Key") { $_ } 
                        }
                        if ($getKeyMatch) {
                            $command = $getKeyMatch
                        } elseif ($editKeyMatch) {
                            $command = $editKeyMatch
                        } else {
                            $command = $commands | Select-Object -First 1 
                        }                     
                    } else {
                        # Only one match, use it
                        $command = $commands[0]
                    }
                } elseif ($value -is [Windows.Media.Visual]) {
                    $InputControl = $value
                }

                if($value.Properties -is [Hashtable]) {
                    $Properties += $value.Properties
                }

                if($command) {
                    #& $command | Set-WpfProperty -Property $Properties -PassThru #| Add-ChildControl -parent $this
                    & $command @Properties -ControlName $key
                } else {
                    New-TextBox @Properties -VisualStyle CueText -Resource @{
                        ExpectedType=$expectedType
                    } -Text $value -On_PreviewTextInput { 
                        if ((($this.Text + $_.Text) -as $expectedType)) {
                            $this.ClearValue([Windows.Controls.Control]::EffectProperty)
                            $toRemove = $errorList.Items | Where-Object { $_.Tag -eq $this } 
                            if ($toRemove) {
                                $errorList.Items.Remove($toRemove)                        
                            }
                            if (-not $errorList.Items.Count) { 
                                $errorList.Visibility = 'Collapsed'
                                if ($okButton) {
                                    $okButton.IsEnabled = $true
                                }
                            }                         
                        } else {
                            $toUpdate = $errorList.Items | Where-Object { $_.Tag -eq $this } 
                            $errorMessage ="$($this.Name): Can't convert $($this.Text) to $($expectedType.Fullname)"
                            if ($toUpdate) {
                                $toUpdate.Content = $errorMessage
                            } else {
                                $errorLabel = New-Label -Tag $this -Content $errorMessage -Foreground Red                                                
                                $null = $errorList.Items.Add($errorLabel)
                            }
                            $errorList.Visibility = 'Visible'
                            $okButton.IsEnabled = $false
                            $this.Effect = New-DropShadowEffect -Color Red
                        }
                    } #| Add-ChildControl -parent $this
                }
                $row++
            }
        }

        New-ListBox -ColumnSpan 2 -Row $row -Name 'ErrorList' -Visibility Collapsed
        
        if (-not $HideOKCancel) {
            $row++
            New-StackPanel -Row $row -ColumnSpan 2 -Orientation Horizontal -HorizontalAlignment Right {
                Button "_OK" -Margin "8,8,0,8" -Padding "20,4" -IsDefault -On_Click {
                    Get-ParentControl | 
                        Set-UIValue -passThru | 
                        Close-Control
                }
                Button "Cancel" -Margin 8 -Padding "20,4" -IsCancel
            }
        }
    }
} 
