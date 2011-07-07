function Select-Date
{
    [OutputType([Windows.Controls.Border], [DateTime])]
    param(
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
	
    begin {
        Add-Type -AssemblyName 'System.Windows.Forms'
    }
    
	process {
		$uiParameters = @{} + $psBoundParameters
		New-Border -ControlName Select-Date -CornerRadius 15 -Padding 15 @uiParameters -On_Loaded {
			if ($this.Parent -is [Windows.Window]) {
                $this.CornerRadius = 0
                $this.Padding =0
            }
		} -Resource @{
			# The Resource dictionary is used to store information 
			# and default settings
			Cmdlet = $psCmdlet
			PSBoundParameters = $PSBoundParameters
			Args = $args			
		} -Child {
            New-WindowsFormsHost -Child {
                $monthCalendar = New-Object System.Windows.Forms.MonthCalendar -Property @{
                    MaxSelectionCount = 1
                }                
                
                $monthCalendar.add_dateSelected({
                    $window | 
                        Get-ChildControl -ByControlName Select-Date -PeekIntoNestedControl |
                        Where-Object { 
                            $_.Uid -eq $this.Tag
                        } |
                        ForEach-Object {
                            $_.Tag = $this.SelectionStart
                        }
                        
                })
                
                $monthCalendar
            } -On_Loaded {
                $this.Child.Tag = Get-ParentControl | 
                Select-Object -ExpandProperty Uid
            }
        }
	}
}
