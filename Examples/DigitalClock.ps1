# Demonstrates how to get a recurring background script to update your UI:
New-Label -name Time -FontSize 24 -On_Loaded {
    Register-PowerShellCommand -scriptBlock {     
        # Note: $window works here, but $Time doesn't?
        $window.Content.Content = (Get-Date | Out-String).Trim()
    } -run -in "0:0:0.05"
} -asjob



New-Label -name Time -FontSize 24 -On_Loaded {
    Register-PowerShellCommand -scriptBlock {     
        . Initialize-EventHandler
        $Time.Content = (Get-Date | Out-String).Trim()
    } -run -in "0:0:0.05"
} -asjob

