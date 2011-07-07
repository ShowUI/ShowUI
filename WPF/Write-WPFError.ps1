function Write-WPFError
{
    param($err)
    $thisTypeNAme = $this.GetType().Name
    $thisName = $this.Name
    
    if ($thisName) {
        $errorLocation = "Error in $EventName Event Handler on $thisName ($thisTypeName) "
    } else {
        $errorLocation = "Error in $EventName Event Handler on $thisTypeName"
    }
    if ($host.Name -eq 'Default Host') {
        # in -AsJob
        if ($err.Exception.ErrorRecord) {
            [Windows.MessageBox]::Show("
            $($err.Exception.ErrorRecord.InvocationInfo.PositionMessage)
            $($err.Exception.ErrorRecord)            
            ", $errorLocation)
        } else {
            [Windows.MessageBox]::Show("
            $($err.InvocationInfo.PositionMessage)
            $err
            ", $errorLocation)
        }
    } else {
        Write-Host $errorLocation -ForegroundColor Red
        $err.InvocationInfo.PositionMessage | Write-Host -ForegroundColor Red
        $err | Write-Host -ForegroundColor Red        
    }
}
