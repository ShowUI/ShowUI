$getCommandInput = UniformGrid -ControlName 'Get-InputForGetCommand' -Columns 2 {
    "Command Name"
    New-TextBox -Name Name
    "Verb"
    New-TextBox -Name Verb
    "Noun"
    New-TextBox -Name Noun
    "In Module"
    New-TextBox -Name Module  
    " " # Some Empty Space
    New-Button "Get Command" -On_Click {
        Get-ParentControl |
            Set-UIValue -passThru | 
            Close-Control
    }
} -show

Get-Command @getCommandInput
