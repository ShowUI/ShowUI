ipmo showui
$person = New-Object -TypeName PSObject -Property @{ lname ="john"; fname = "smith" }
# It is possible to refer to controls even in a non-module function, but you have to use 
# a reference to the module, and the call operator:
function write-fname() {  
    $_fname = &(Get-Module ShowUI){ $fname }
    Write-Host ($_fname -eq $null)
    Write-Host $_fname.Content
}

Stackpanel -Margin 5 {   
    Label -Name lname -DataBinding @{ Content = Binding -Path lname -Source $person -UpdateSourceTrigger PropertyChanged } 
    Label -Name fname -DataBinding @{ Content  = Binding -Path fname -Source $person -UpdateSourceTrigger PropertyChanged } 

    ## Call a function (we don't use the parameters in event handlers, so you can just do this)
    Button "echo first name" -On_Click { write-fname }

    # question 2. how to make the label $fname2 reflect whatever values are filled in TextBox $tbx?   
    # When the window closes, $person is updated, but $tbx is updated as we edit ...
    TextBox -name tbx -DataBinding @{ Text  = Binding -Path fname -Source $person -UpdateSourceTrigger PropertyChanged } -OV tbx
    Label -name fname2
} -On_Load {
    # Sometimes we want to bind to the control, instead of the underlying data
    Set-Property -Input $fname2 -Property @{ Text = Binding -Element tbx -Path Text -UpdateSourceTrigger PropertyChanged }
} -show 
