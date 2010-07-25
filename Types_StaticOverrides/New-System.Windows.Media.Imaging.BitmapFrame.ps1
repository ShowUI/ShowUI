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
