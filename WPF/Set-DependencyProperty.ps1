function Set-DependencyProperty
{
    <#
    .Synopsis
        Sets the dependency properties on an object.
    .Description
        Sets the dependency properties on an object.
        Dependency properties are used in WPF to attach 
        auxilliary information to an object that other UI components 
        may use.
    .Parameter Target
        The object to set dependency properties on.
    .Parameter Property
        The Dependency Properties to set.  Properties must be qualified
        dependency properties (i.e. [Windows.Window]::ContentProperty)
    .Parameter Name
        Use this parameter instead of Property to provide a short name for
        the dependency properties (i.e. Content)
    .Parameter Value
        The value to set on the dependency properties
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [Windows.DependencyObject[]]
    $Target,
    
    # The Dependency Property to Set
    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true, ParameterSetName="Property")]
    [Windows.DependencyProperty[]]
    [ValidateNotNullOrEmpty()]
    $Property,
    
    # The name of the depencency property to set.  The dependency property must exist on the current object.
    [Parameter(Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true, ParameterSetName="Name")]
    [ValidateNotNullOrEmpty()]
    [String[]]
    $Name,
    

    # The value or values to use.
    [Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true, ParameterSetName="Name")]
    [Parameter(Mandatory=$true, Position=2, ValueFromPipelineByPropertyName=$true, ParameterSetName="Property")]
    [ValidateNotNullOrEmpty()]
    [Array]
    $Value
    )
    
    process {    
        foreach ($t in $target) {
            switch ($psCmdlet.ParameterSetName) {
                Name {
                    for ($i = 0; $i -lt $name.Count; $i++) {
                        $dp = $t.GetType()::($name[$i] + "Property")
                        if (-not $dp) { continue }
                        $t.SetValue($dp, $value[$i] -as $dp.PropertyType)
                    }                            
                }
                Property {
                    for ($i = 0; $i -lt $property.Count; $i++) {
                        $t.SetValue($property[$i], $value[$i] -as $property[$i].PropertyType)
                    }
                }                
            }
        }
    }
} 
