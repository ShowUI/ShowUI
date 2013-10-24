Show-UI -Xaml $PSScriptRoot\VisualStudioDesigner.xaml -On_Loaded {
	Add-EventHandler $Calculate Click {
      $Total.Text = '${0:n2}' -f (($Miles.Text -as [Double]) / ($Mpg.Text -as [Double]) * ($Cost.Text -as [Double]))
    }
}