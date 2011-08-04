function Initialize-EventHandler
{
    param(
        $resource = $(try { Get-Resource -ErrorAction SilentlyContinue } catch { Write-Debug "$_" }),
        $parent = $(try { Get-ParentControl -ErrorAction SilentlyContinue } catch { Write-Debug "$_" })
    )
    $scope = 2
    while($scope -ge 0) {
      try {
         Set-Variable -Name "zzz12456879" -Value 42 -Scope $scope
         Remove-Variable "zzz12456879" -Scope $scope
         break
      } catch [System.Management.Automation.PSArgumentOutOfRangeException] { 
         $scope = $scope - 1
      }
    }
    
    
    if ($parent) {
        $namedControls = Get-ChildControl -OutputNamedControl -Control $parent
        if ($namedControls) { 
            foreach ($nc in $namedControls.GetEnumerator()) {
                Set-Variable -Name $nc.Key -Value $nc.Value -Scope $scope
            }
        }
        if ($parent.Name) { 
            Set-Variable -Name $parent.Name -Value $parent -Scope $scope
        }
        if ($parent.GetValue -and
            $($controlname = $parent.GetValue([ShowUI.ShowUISetting]::ControlNameProperty);$controlName))
        {
            Set-Variable -Name $controlname -Value $parent -Scope $scope
            Remove-Variable -Name ControlName
        }
    } 
    if ($resource) {
        foreach ($nc in $resource.GetEnumerator()) {
            if ($nc.Key -and 
                'Scripts', 'Timers', 'EventHandlers' -notcontains $nc.Key) {
                if ($nc.Value -is [ScriptBlock]) {
                    $lines = $nc.Value.ToString().Split([Environment]::NewLine, [StringSplitOptions]'RemoveEmptyEntries')
                    if ($lines[0,1] -like "*function*") {
                        $null = New-Module -ScriptBlock $nc.Value
                        continue
                    }
                }
                Set-Variable -Name $nc.Key -Value $nc.Value -Scope $scope
            }
        }
    }
}
