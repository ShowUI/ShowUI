if( [Array]::BinarySearch(@(Get-BootsAssemblies), 'PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) -lt 0 ) {
  $null = [Reflection.Assembly]::Load( 'PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) 
}
if($ExecutionContext.SessionState.Module.Guid -ne (Get-BootsModule).Guid) {
	Write-Warning "BitmapFrame not invoked in PowerBoots context."
}

function New-System.Windows.Media.Imaging.BitmapFrame {
#.Synopsis
#   Create a new BitmapFrame object
#.Description
#   Generates a new System.Windows.Media.Imaging.BitmapFrame object, and allows setting all of it's properties.
#   (From the PresentationCore assembly)
#.Notes
# This is an attempt to faithfully represent a method overload: http://msdn.microsoft.com/en-us/library/ms609573.aspx
# ASSEMBLY  : PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
# FULLPATH  : C:\Windows\Microsoft.Net\assembly\GAC_64\PresentationCore\v4.0_4.0.0.0__31bf3856ad364e35\PresentationCore.dll
[CmdletBinding(DefaultParameterSetName='BitmapSource')]
PARAM(

   [Parameter(Position=1,ParameterSetName="BitmapSource",Mandatory=$true,ValueFromPipeline=$true)]
   [System.Windows.Media.Imaging.BitmapSource]$BitmapSource
,
   [Parameter(Position=2,ParameterSetName="BitmapSource")]
   [System.Windows.Media.Imaging.BitmapSource]$ThumbnailSource
,
   [Parameter(Position=3,ParameterSetName="BitmapSource")]
   [System.Windows.Media.Imaging.BitmapMetadata]$Metadata
,
   [Parameter(Position=4,ParameterSetName="BitmapSource")]
   [System.Collections.ObjectModel.ReadOnlyCollection[System.Windows.Media.ColorContext]]$ColorContext
,

   [Parameter(Position=1,ParameterSetName="Uri",Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
   [Alias("Path","FullName")]
   [System.Uri]$Uri
,
   [Parameter(Position=2,ParameterSetName="Stream")]
   [Parameter(Position=2,ParameterSetName="Uri")]
   [System.Windows.Media.Imaging.BitmapCreateOptions]$CreateOptions
,
   [Parameter(Position=3,ParameterSetName="Stream")]
   [Parameter(Position=3,ParameterSetName="Uri")]
   [System.Windows.Media.Imaging.BitmapCacheOption]$CacheOptions
,
   [Parameter(ParameterSetName="Uri")]
   [System.Net.Cache.RequestCachePolicy]$RequestCachePolicy
,

   [Parameter(Position=1,ParameterSetName="Stream",Mandatory=$true)]
   [System.IO.Stream]$Stream

,	[Parameter()]
	[PSObject]${On_Changed}
,	[Parameter()]
	[PSObject]${On_DecodeFailed}
,	[Parameter()]
	[PSObject]${On_DownloadCompleted}
,	[Parameter()]
	[PSObject]${On_DownloadFailed}
,	[Parameter()]
	[PSObject]${On_DownloadProgress}
,	[Parameter(ValueFromRemainingArguments=$true)]
	[string[]]$DependencyProps
)
BEGIN {
   $All = @('Changed','Changed__','DecodeFailed','DecodeFailed__','DownloadCompleted','DownloadCompleted__','DownloadFailed','DownloadFailed__','DownloadProgress','DownloadProgress__')  
}
PROCESS {
   switch($PSCmdlet.ParameterSetName) {
      "BitmapSource" {
         if(!$ThumbnailSource) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($BitmapSource)
         }
         elseif($ThumbnailSource -and (!$BitmapMetadata -and !$ColorContext)) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($BitmapSource,$ThumbnailSource)
         }
         elseif($ThumbnailSource -and $BitmapMetadata -and $ColorContext) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($BitmapSource,$ThumbnailSource,$BitmapMetadata,$ColorContext)
         } else {
            throw 'Invalid Parameter Combination. Please use one of the following sets:
$BitmapSource
$BitmapSource,$ThumbnailSource
$BitmapSource,$ThumbnailSource,$BitmapMetadata,$ColorContext
'
         }
      }
      "Uri" {
         if(!$RequestCachePolicy -and (!$CreateOptions -and !$CacheOptions)) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Uri)
         }
         elseif($RequestCachePolicy -and (!$CreateOptions -and !$CacheOptions)) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Uri,$RequestCachePolicy)
         }
         elseif(!$RequestCachePolicy -and $CreateOptions -and $CacheOptions) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Uri,$CreateOptions,$CacheOptions)
         }
         elseif($RequestCachePolicy -and $CreateOptions -and $CacheOptions) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Uri,$CreateOptions,$CacheOptions,$RequestCachePolicy)
         } else {
            throw 'Invalid Parameter Combination. Please use one of the following sets:
$Uri
$Uri,$RequestCachePolicy
$Uri,$CreateOptions,$CacheOptions
$Uri,$CreateOptions,$CacheOptions,$RequestCachePolicy
'
         }
      }
      "Stream" {
         if(!$CreateOptions -and !$CacheOptions) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Stream)
         } elseif($CreateOptions -and $CacheOptions) {
            $DObject = [System.Windows.Media.Imaging.BitmapFrame]::Create($Stream,$CreateOptions,$CacheOptions)
         } else {
            throw 'Invalid Parameter Combination. Please use one of the following sets:
$Stream
$Stream,$CreateOptions,$CacheOptions
'
         }
      }
   }

foreach($key in @($PSBoundParameters.Keys) | where { $PSBoundParameters[$_] -is [ScriptBlock] }) {
   $PSBoundParameters[$key] = $PSBoundParameters[$key].GetNewClosure()
}
Set-PowerBootsProperties @($PSBoundParameters.GetEnumerator() | Where { [Array]::BinarySearch($All,($_.Key -replace "^On_(.*)",'$1__')) -gt 0 } ) ([ref]$DObject)
   Microsoft.PowerShell.Utility\Write-Output $DObject
} #Process
}

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGD4FiSUmwxb1XUBRhgFz4pcn
# 8Q2gggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUkQuv5VhN
# cA0RRZGAe1iVNt2EGm4wDQYJKoZIhvcNAQEBBQAEggEAAVAT3pKMSqra1/aEV5xg
# FcCFP6gEXrUUfPpbnAmwSIc7fs8MVpiSjXFs3mxxAaatDdxuWAF9MZ8ZZMTkPGkY
# mkK9fEkE+RF07K9FjQBw5pCVQWQJapvBDh8ai5A2iHpwnHS2vAhWsB0pCFcmhfFZ
# h9qnhCfIFgxldJX5I7ilntpclGWvHPa0Q//WRYcSOYI07wzdS1ElIootC7rsu24o
# 7mm167B2hZDHKXiZwR0EDof/DYmnow+qAHJBSk8cBoVO8+ASWRgDddE5lMvgIiUK
# 57/pCTQKjitYTN1TJWR5cKaVFcXJNlLv87Mfj2pCGZQ1adCA9lhF759YV+RZvuAe
# 3Q==
# SIG # End signature block
