#requires -Modules @{ModuleName="ShowUI"; ModuleVersion="1.5"}

Write-Host "Loading some data for example"

$data = Get-Command Get-* -Type Cmdlet -ListAvailable | 
            Select-Object *, @{ Name="Description"; Exp={(Get-Help $_.Name -ErrorAction Ignore).Synopsis} }

Write-Host "Building a StackPanel with a DataContext consisting of $($data.Count) items"

StackPanel {
    StackPanel -Orientation Horizontal {
        Label Name
        Label { Binding Name }
    }
    StackPanel -Orientation Horizontal {
        Label Description
        Label { Binding Description }
    }

    StackPanel -Orientation Horizontal {

        button "First" -name next -On_Click {
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this.DataContext )
            $view.MoveCurrentToFirst()
        }
        button "Prev" -name next -On_Click {
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this.DataContext )
            $view.MoveCurrentToPrevious()
            # http://msdn.microsoft.com/en-us/library/system.windows.data.collectionview.iscurrentbeforefirst.aspx
            if ($view.IsCurrentBeforeFirst) { $view.MoveCurrentToFirst() }
        }
        button "Next" -name next -On_Click {
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this.DataContext )
            $view.MoveCurrentToNext()
            # http://msdn.microsoft.com/en-us/library/system.windows.data.collectionview.iscurrentafterlast.aspx
            if ($view.IsCurrentAfterLast) { $view.MoveCurrentToLast() }
        }
        button "Last" -name next -On_Click {
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $this.DataContext )
            $view.MoveCurrentToLast()
        }
    }
} -Show -DataContext @($data)

