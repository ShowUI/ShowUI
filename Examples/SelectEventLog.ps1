New-Grid -Rows (@('Auto') * 2) -Columns 2 -ControlName 'Get-EventLogInput' {
    "After" 
    Select-Date -Column 1 -Name "After"
    New-Button -Row 1 "Ok" -IsDefault -On_Click { 
        Get-ParentControl | 
            Set-UIValue -PassThru |
            Close-Control
    } 
} -asjob
