function Set-Resource
{
    <#
    .Synopsis
        Sets a Resource that will be available across different handlers
        for a control.
    .Description
        Writing user interfaces effectively is about sharing information
        in between multiple controls.  To do this, each control has a 
        dictionary of resources, and a pointer to the parent control.
        
        Set-Resource puts items into the resource dictionary, so that 
        other controls may access the items.  You can use this to share
        data between controls.
        
        Set-Resource also allows you to store data at various depths.
        The default depth is 0.  To store the information in the parent control,
        use -1.  To store information in the grandparent control, use -2, etc.
        
        The greater the level that the resource is stored, the more universally
        it will be available.  To find a resource, use the Get-Resource cmdlet.
        
        It is also useful to use Set-Resource to store references to controls so
        that other controls can access them.  For instance, if there is 
        a textbox, a button, and a listbox, you will need each control 
        to be able to refer to the other controls in order to add items to 
        the listbox that are typed into the textbox.
        
        The example demonstrates this technique.
        
        
    .Link
        Get-Resource
    .Example
        New-Grid -Rows '1*', 'Auto' {
            New-ListBox -On_Loaded {
                # When this Listbox is loaded, make it the resource "List" in 
                # grid
                Set-Resource "List" $this -1
            }
            New-Button -Row 1 "_Add" -On_Click {
                # Get the resource List (the Grid will have it) and add an item
                # to it
                $list = Get-Resource "List"
                $list.ItemsSource += @(Get-Random)
            }
        } -Show
    #>
    param(
    [String]$Name,
    $Value,
    [ValidateRange(-2147483648,0)]
    [Int]
    $Depth = 0,   
    $Visual
    )
    
    process {
        if (-not $visual) { $visual = $this } 
        for ($i =0; $i -gt $Depth; $i--) {
            $Visual = $Visual.Parent
            if (-not $Visual) { break } 
        }
        if (-not $Visual) { return } 
        $Visual.Resources.$Name = $Value
    }    
}
