   $window =  Window {
      StackPanel -Margin 10 {
         TextBlock "The Question" -FontSize 42 -FontWeight Bold -Foreground "#FF0088"
         TextBlock -FontSize 24 {
            Hyperlink {
               Bold "Q. "
               "Can PowerBoots do debugging?"
            } -NavigateUri " " -On_RequestNavigate {
               if($global:Answer.Visibility -eq 2) { 
                  $global:Answer.Visibility = "Visible"
               } else {
                  $global:Answer.Visibility = "Collapsed"
               }
            }
         }
         TextBlock -FontSize 16 {
            Span "A. " -FontSize 24 -FontWeight Bold 
            "Oh yes we can!"
         } -Visibility Collapsed | Tee -Variable global:Answer
      }
   }
   $window.ShowDialog()