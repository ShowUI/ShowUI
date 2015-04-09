function Get-UIValue {
#.Synopsis
#   Get the UIValue from a control
#.Description
#   Returns the Tag, SelectedItems, or Text from a control, or collects it from the child controls.
[CmdletBinding(DefaultParameterSetName="Recurse")]
param(
    # The UI FrameworkElement to get the value from
    [Parameter(ValueFromPipeline=$true,Position=0)]
    [Windows.FrameworkElement]
    $Ui,

    # If the SingleValue switch isn't set, include entries for child controls without values
    [Parameter(ParameterSetName="Recurse")]
    [Switch]
    $IncludeEmptyValue,

    # Disables setting the "UI" property on the UI FrameworkElement
    [switch]
    $DoNotAddUINoteProperty,

    # If the SingleValue switch isn't set, converts the child item hashtable into an object
    [Parameter(ParameterSetName="Recurse")]
    [switch]
    $AsObject,

    # Disables recursing the child controls if this control has no intrinsic value
    [Parameter(ParameterSetName="IgnoreChildControls")]
    [switch]
    $IgnoreChildControls
)
begin {
    Set-StrictMode -Off
    function MaybeAddUIProperty {
        param($ui)
        if (-not $DoNotAddUINoteProperty) {
            $newValue = Add-Member -InputObject $newValue NoteProperty UI $Ui -PassThru 
        }
    }
     
}

process {
    if($UI -eq $Null) { return $null }
    
    # If Tag is not null, return that.
    if ($UI.Tag -ne $Null) {
        $newValue = $UI.Tag
        . MaybeAddUIProperty $ui
        return $newValue
    # If SelectedItems exist, return them
    } elseif ($Ui.SelectedItems -ne $null -and $Ui.SelectedItems.Count -gt 0) {
        $newValue = $UI.SelectedItems
        . MaybeAddUIProperty $ui
        return $newValue
    # If SelectedItem exists, return that
    } elseif ($Ui.SelectedItem -ne $null) {
        $newValue = $UI.SelectedItem
        . MaybeAddUIProperty $ui
        return $newValue
    # If SelectedDates exist, return those
    } elseif ($Ui.SelectedDates -ne $null -and $Ui.SelectedDates.Count -gt 0) {
        $newValue = $UI.SelectedDate
        . MaybeAddUIProperty $ui
        return $newValue
    # If SelectedDate exists, return that
    } elseif ($Ui.SelectedDate -ne $null) {
        $newValue = $UI.SelectedDate
        . MaybeAddUIProperty $ui
        return $newValue
    # If SelectedValue exists, return that
    } elseif ($Ui.SelectedValue -ne $null) {
        $newValue = $UI.SelectedValue
        . MaybeAddUIProperty $ui
        return $newValue
    # If this has an IsChecked property, return True or False based on that
    } elseif ($ui.GetType().GetProperty("IsChecked")){ 
        $newValue = $UI.IsChecked
        . MaybeAddUIProperty $ui
        return $newValue
    # If this has a Text property, return that
    } elseif ($ui.Text -and (
        -not $ui.Resources.OriginalText -or
        ($ui.Text -ne $ui.Resources.OriginalText))) {
        $newValue = $UI.Text
        . MaybeAddUIProperty $ui
        return $newValue
    # If we're allowed to recurse, collect the values of the child controls
    } elseif (!$IgnoreChildControls) {
        $uiValues = @{} + (Get-ChildControl -OutputNamedControl -Control $ui)
        foreach ($keyName in @($uiValues.Keys)) {
            # Note: We're setting -IgnoreChildControls to prevent deep recursion (and maintain backwards output compatibility)
            $uiValues[$keyName] = Get-UIValue -Ui ($uiValues[$keyName]) -DoNotAddUINoteProperty:$DoNotAddUINoteProperty -IgnoreChildControls
            
            if ($uiValues[$keyName] -eq $null -and -not $IncludeEmptyValue) {
                $null = $uiValues.Remove($keyName)
            }
        }
        if($AsObject) {
            New-Object PSObject -Property $uiValues
        } else {
            return $uiValues
        }
    } else {
        return $null
    }
}
}
