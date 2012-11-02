function Get-ChildControl
{
    <#
    .Synopsis
        Imports variables to interact with a control's children
    .Description
        
    #>
    param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
    [Alias('Tree')]
    $Control = $Window,
    [Parameter(Position=0)][string[]]$ByName,

    [Switch]$OnlyDirectChildren,       
    [string[]]$ByControlName,
    [Type[]]$ByType,
    [string]$ByUid,
    [String]$GetProperty,        
    [switch]$OutputNamedControl,
    [Switch]$PeekIntoNestedControl
    )
    
    process {
        if ($byUid) { $PeekIntoNestedControl = $true } 
        $hasEnumeratedChildren = $false
        if (-not $Control) { return }
        $namedNestedControls = @{}
        $queue = New-Object Collections.Generic.Queue[PSObject]
        $queue.Enqueue($control)
        $hasOutputtedSomething = $false
        while ($queue.count) {
            $parent = $queue.Peek()
            
            if ('ShowUI.ShowUISetting' -as [type]) {
                $controlname = try {
                    $parent.GetValue([ShowUI.ShowUISetting]::ControlNameProperty)
                } catch {
                    $controlname  = ""
                }
            } else {
                $controlname = ""
            }
            
            if ($parent.Name) {
                $namedNestedControls[$parent.Name] = $parent
            }
            
            if (-not $OutputNamedControl) {
                if ($getProperty){
                    $__propertyExistsOnObject = $parent.psObject.Properties[$getProperty]
                    if ($__PropertyExistsOnObject) {
                        $parent.$getProperty
                    }
                } elseif ($byName) {
                    if ($ByName -contains $parent.Name) { 
                        $hasOutputtedSomething  = $true
                        $parent 
                    } 
                } elseif ($byControlName) {
                    if ($byControlName -contains $controlname) { 
                        $hasOutputtedSomething = $true
                        $parent 
                    } 
                } elseif ($ByType) {
                    foreach ($bt in $byType) {
                        if ($parent.GetType() -eq $bt -or 
                            $parent.GetType().IsSubclassOf($bt)) { 
                            $hasOutputtedSomething = $true
                            $parent 
                        } 
                    }
                } elseif ($byUid) {
                    if ($parent.Uid -eq $uid) { 
                        $hasOutputtedSomething = $true
                        $parent 
                    }
                } else {                    
                    if ((-not $hasOutputtedSomething) -and $OnlyDirectChildren) {
                        # When -OnlyDirectChildren is specified, the first item
                        # out would be the parent, so skip that
                        $hasOutputtedSomething = $true                        
                    } else {
                        $hasOutputtedSomething = $true                        
                        $parent                
                    }
                    
                }
            }
            
            
            $childCount = try {
                [Windows.Media.VisualTreeHelper]::GetChildrenCount($parent)
            } catch {
                Write-Debug $_
            }
            
            
            $shouldEnumerateChildren = $false            
            
            if ($childCount) {            
                if (-not ($hasEnumeratedChildren -and $OnlyDirectChildren)) {
                    if ((-not $HasEnumeratedChildren) -or                 
                        (-not $controlname -or $PeekIntoNestedControl)) {
                        $hasEnumeratedChildren = $true
                        for ($__i =0; $__i -lt $childCount; $__i++) {
                            $child = [Windows.Media.VisualTreeHelper]::GetChild($parent, $__i)
                            $queue.Enqueue($child)
                        }            
                    }                                        
                }
            } else {
                if ($parent -is [Windows.Controls.ContentControl]) {
                    $child = $parent.Content
                    
                    if ($child -and $child -is [Windows.Media.Visual]) {
                        $hasEnumeratedChildren = $true
                        $queue.Enqueue($child)
                    } else {
                        if (-not $outputNamedControl -and
                            -not $byType -and
                            -not $byName -and
                            -not $byUid -and 
                            -not $byControlName) {
                            $hasEnumeratedChildren = $true
                            $child
                        }
                        
                    }
                }
            }
            
            $parent = $queue.Dequeue() 
        }

        if ($OutputNamedControl) {
            $namedNestedControls
        }                                               
    }      
}
   
