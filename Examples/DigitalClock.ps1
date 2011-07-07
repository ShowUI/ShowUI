New-Label -FontSize 24 -On_Loaded {
    Register-PowerShellCommand -scriptBlock {     
        $window.Content.Content = (Get-Date | Out-String).Trim()
    } -run -in "0:0:0.5"
} -asjob
