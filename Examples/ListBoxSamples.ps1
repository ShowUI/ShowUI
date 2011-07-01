New-ListBox {1..100 } -MaxHeight 300 -show
New-ListBox -SelectionMode Multiple {1..100 | Sort-Object -Descending} -MaxHeight 300 -show
New-ListBox {1..100} -On_KeyDown { if ($_.Key -eq "Enter") { $window.Close() } } -show