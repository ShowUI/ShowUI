#function Format-PoshTable {
#.Synopsis
#  Format-PoshTable puts the output in a WPF DataGrid (inline in PoshConsole)
#.Description 
#  Outputs a WPF datagrid of the objects (and properties) specified. 
#  This grid can be sorted, rearranged, etc
	[CmdletBinding()]
	param(
      [parameter(ValueFromPipeline=$true)]
      [Array]$InputObject
   ,
      [Parameter(Position=1)]
      [String[]]$Property = "*"
   ,
      [Parameter(Position=2)][Alias("Type")]
      [Type]$BaseType # a type to use as the generic in the collection
   ,
      [Parameter()]
      [Switch]$Popup = (![bool]$Host.PrivateData.WpfConsole)
	)
	Begin
	{
      $global:theFormatPoshTableDataGrid = $null
		if (!(Get-Command datagrid) )
		{
			Import-Module PowerBoots
         Add-BootsFunction 'C:\Program Files (x86)\WPF Toolkit\*\WPFToolkit.dll'
		}
	}
	Process
	{
      # Create the window here instead of in BEGIN because we need to know the TYPE for the datagrid
		if(!$global:theFormatPoshTableDataGrid) {
         if(!$BaseType) { $BaseType = $InputObject[0].GetType().FullName }
         # We're going to create a special collection ... 
			$global:ObservableCollection = new-object System.Collections.ObjectModel.ObservableCollection[$BaseType]
         if(!$ObservableCollection) { throw "Couldn't create an ObservableCollection[$BaseType]" }
         foreach($i in $InputObject) { $ObservableCollection.Add($i) > $null }
         boots {
            Param($ItemCollection, $Property)
				datagrid -RowBackground "AliceBlue" -AlternatingRowBackground "LightBlue" -On_AutoGeneratingColumn {
               Param($Source,$SourceEventArgs) 
               $header = $SourceEventArgs.Column.Header.ToString()
               $Cancel = $true
               # If it matches any of the properties, don't cancel it.
               foreach($h in $Source.Tag) {  if($header -like $h) {  $Cancel = $false } }
               $SourceEventArgs.Cancel = $Cancel
            }  -ColumnHeaderStyle {
					Style -Setters {
						Setter -Property ([System.Windows.Controls.ListView]::FontWeightProperty) -Value ([System.Windows.FontWeights]::ExtraBold)
					}
				} -ItemsSource $ItemCollection -ov global:theFormatPoshTableDataGrid -tag $Property
         } $ObservableCollection $Property -Inline:(!$Popup) -Async:$Popup  -Popup:$Popup 
		} else {
         @($global:theFormatPoshTableDataGrid)[0].Dispatcher.Invoke( "Normal", ([Action]{  foreach($i in @($InputObject)) { $global:ObservableCollection.Add($i) > $null } }) )  
		}
	}
#}
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUY2zQnw+ekpTQWqVnkiEOIjJa
# RgGgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTEwMDUxNDAwMDAwMFoXDTExMDUxNDIzNTk1OVowgZUx
# CzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUwNjg1MDEUMBIGA1UECAwLQ29ubmVjdGlj
# dXQxEDAOBgNVBAcMB05vcndhbGsxFjAUBgNVBAkMDTQ1IEdsb3ZlciBBdmUxGjAY
# BgNVBAoMEVhlcm94IENvcnBvcmF0aW9uMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfUdxwiuWDb8zId
# KuMg/jw0HndEcIsP5Mebw56t3+Rb5g4QGMBoa8a/N8EKbj3BnBQDJiY5Z2DGjf1P
# n27g2shrDaNT1MygjYfLDntYzNKMJk4EjbBOlR5QBXPM0ODJDROg53yHcvVaXSMl
# 498SBhXVSzPmgprBJ8FDL00o1IIAAhYUN3vNCKPBXsPETsKtnezfzBg7lOjzmljC
# mEOoBGT1g2NrYTq3XqNo8UbbDR8KYq5G101Vl0jZEnLGdQFyh8EWpeEeksv7V+YD
# /i/iXMSG8HiHY7vl+x8mtBCf0MYxd8u1IWif0kGgkaJeTCVwh1isMrjiUnpWX2NX
# +3PeTmsCAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBTK0OAaUIi5wvnE8JonXlTXKWENvTAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAWGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAEss8yuj+rZvx2UFAgkz/DueB8gwqUTzFbw2prxqee
# zdCEbnrsGQMNdPMJ6v9g36MRdvAOXqAYnf1RdjNp5L4NlUvEZkcvQUTF90Gh7OA4
# rC4+BjH8BA++qTfg8fgNx0T+MnQuWrMcoLR5ttJaWOGpcppcptdWwMNJ0X6R2WY7
# bBPwa/CdV0CIGRRjtASbGQEadlWoc1wOfR+d3rENDg5FPTAIdeRVIeA6a1ZYDCYb
# 32UxoNGArb70TCpV/mTWeJhZmrPFoJvT+Lx8ttp1bH2/nq6BDAIvu0VGgKGxN4bA
# T3WE6MuMS2fTc1F8PCGO3DAeA9Onks3Ufuy16RhHqeNcMYICTDCCAkgCAQEwgaow
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIQKQm90jYWUDdv7EgFkuELajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUjLst6vfQ
# +XEm6Fz2x5tQpWK/bcIwDQYJKoZIhvcNAQEBBQAEggEAcRMH2/zGxQ9ysV4U2H4O
# JQPCxbJlWMK7IKaoGWW4UZhHkvmbdCIgHut6oPe5k337o8hNYQAWEG3YwfN6ZZ0r
# lG1fQP5MXDLkBHFMw5ioN++zfR7d6A4IQDJ97ClDlF729MeTb1kVuukDn3Xz5O/+
# dD7boFffhixlhEFJoVQrRfo4psD7D8qu0VQL9clvDEFMZAD8YJA0cGkbPxKkQaxJ
# ZaDYGKtOO0e/xIr6nBjEhrJoauWopUWZ/d5TC5aIIwYeOV6SQFEjT+uUttGgeYP7
# hoYGIvi8MmSBtRYuqIlIUHqCqZv0LpkEnGb2Ful2IO+nUOrFqiLxZCXuM4QljYBw
# 1A==
# SIG # End signature block
