IpMo ShowUI
IpMo Reflection, PowerTest, Wasp

test Update-WPFJob {
   arrange {
      $job = New-StackPanel -ControlName 'Get-PersonalInformation' -Columns 1 -Children {            
          New-Label "What is your first name?"            
          New-TextBox -Name Firstname -Uid Firstname
          New-Label "What is your last name?"            
          New-TextBox -Name Lastname            
          New-Label "When were you born?"            
          Select-Date -Name Birthdate -Uid SelectDate
      } -asjob  
   }
   act{
      $job | Update-WPFJob { $firstname.Text = "Russell" }
   }
   assert {
      Assert-That {
         Select-UIElement Get-PersonalInformation | 
            Select-UIElement -AutomationId SelectDate | 
            Select-UIElement -ClassName WindowsForms10.SysMonthCal32*
      } -FailMessage "Didn't find SysMonthCal32 in Select-Date"
         
      Select-UIElement Get-PersonalInformation | 
         Select-UIElement -AutomationId FirstName | 
         Assert-That { $_.Text -eq "Russell" } -FailMessage "FirstName text wasn't set"
   }
}



