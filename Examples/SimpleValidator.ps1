Grid -Columns Auto,* -Rows 3 -On_Load { $UserName.Focus() } {

    function global:Test-Auth  {
        param($UserName, $Password)
        return $Password -eq "Password"
    }

    Label "UserName"
    TextBox -Name UserName -Text UserName -Column 1 -VisualStyle CueText -Margin 1

    Label "Password" -Row 1
    PasswordBox -Name Password -Row 1 -Column 1 -Margin 1

    New-StackPanel -Row 2 -ColumnSpan 2 -Orientation Horizontal -HorizontalAlignment Right {
        Button "_OK" -Margin "8,8,0,8" -Padding "20,4" -IsDefault -On_Click {
            if(Test-Auth $UserName.Text $Password.Password){
                Set-UIValue $Window -Value @{ 
                    Name = $UserName.Text
                    Password = $Password.SecurePassword 
                } -Passthru | Close-Control
            } else {
                $UserName.Effect = New-DropShadowEffect -Color Red
            }
        }
        Button "Cancel" -Margin 8 -Padding "20,4" -IsCancel
    }        
} -Show