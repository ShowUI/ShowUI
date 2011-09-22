uniformgrid -ControlName "Get-FirstNameLastNameAndAge" -Columns 2 {
    "Age" 
    textBox -Name "Age" 18
    "First Name"
    textBox -Name "FirstName" John 
    "Last Name"
    textBox -Name "LastName" Smith
    
    button -Content "Cancel" -IsCancel -On_Click {
        Get-ParentControl | 
            Close-Control
    }    
    button "Ok" -IsDefault -On_Click {
        Get-ParentControl | 
            Set-UIValue -passThru | 
            Close-Control
    }
} -show
