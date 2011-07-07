function Set-UIStyle {
    <#
    .Synopsis
        Set-UIStyle
    .Description
        Set-UIStyle will set the UI Style on a given control, 
        or will change the settings for a given style
    .Example
        $this | Set-UIStyle "Midnight"
    .Example
        Set-UIStyle "Midnight" @{
            Background = 'DarkBlue'
            Foreground = 'White'
        }
    #>
    [CmdletBinding(DefaultParameterSetName="ApplyStyle")]
    param (
    [Parameter(ParameterSetName="ApplyStyle", 
        ValueFromPipelineByPropertyName=$true,
        Mandatory=$true,
        Position=0)]
    
    [Parameter(ParameterSetName="SetStyle", 
        ValueFromPipelineByPropertyName=$true,
        Mandatory=$true,
        Position=0)]
    [Alias('Name')]
    [string]    
    $StyleName,

    [Parameter(ValueFromPipeline=$true, 
        ParameterSetName="ApplyStyle", 
        Mandatory=$true)]
    [Windows.Media.Visual]
    $Visual,
        
    [Parameter(ParameterSetName="SetStyle",
        ValueFromPipelineByPropertyName=$true)]        
    [Type[]]
    $ForType,
    
    [Parameter(ParameterSetName="SetStyle",
        ValueFromPipelineByPropertyName=$true)]
    [string[]]
    $ForName,
    
    [Parameter(ParameterSetName="SetStyle",
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
    [Alias('Property')]
    [Hashtable]
    $Style
    )    
    
    process {
        if ($psCmdlet.ParameterSetName -eq 'ApplyStyle') {
            $styleSettings = Get-UIStyle -Name $StyleName
            if (-not $styleSettings) { return } 
            if ($styleSettings.ForType) {
                # Return if the style doesn't apply to this type
                $typeMatched = $false
                foreach ($ft in $styleSettings.ForType) {
                    # Return if the style doesn't apply to this name
                    $rt = $ft -as [Type]
                    
                    if ($rt -and $visualType -as $rt) {
                        $typeMatched = $true
                        break
                    }                        
                }
                if (-not $typeMatched) { return }                                             
            }
            if ($styleSettings.ForName) {
                $nameMatched = $false
                foreach ($fn in $styleSettings.ForName) {
                    # Return if the style doesn't apply to this name
                    if ($Visual.Name -like $fn) {
                        $nameMatched = $true
                        break
                    }
                }
                if (-not $nameMatched) { return }                                             
            }
            
            $toSkip = @()
            foreach ($item in $visual.GetLocalValueEnumerator()) {
                if ($styleSettings.Contains($item.Property.Name)) {
                    $toSkip = $styleSettings
                }
            }
            
            foreach ($ts in $toSkip) {
                $null = $styleSettings.Remove($ts)
            }
            
            $objectAfterChanges = Set-Property -inputObject $visual -property $StyleSettings -passThru
            
        } elseif ($psCmdlet.ParameterSetName -eq 'SetStyle') {
            if ($ForName) {
                $Style.ForName = $ForName
            }
            if ($ForType) {
                $Style.ForType = $ForType
            }
            $script:UiStyles.$StyleName = $Style                                    
            try {
                if (-not (Test-Path $psScriptRoot\Styles)) {
                    $ni = New-Item -ItemType Directory -Path $psScriptRoot\Styles -ErrorAction Stop                    
                }
                $null = Export-Clixml -InputObject $script:UIStyles -Path $psScriptRoot\Styles\Current.style
                $tempStyle = $null
                $timeSpentWaitingForWriteToFinish = Measure-Command { 
                    while (-not $tempStyle) {
                        try {
                            $tempStyle  =  Import-Clixml -Path $psScriptRoot\Styles\Current.style                    
                        } catch {
                        }
                    } 
                }
                Write-Debug "Spent $timeSpentWaitingForWriteToFinish waiting for style to be exported."
            } catch {
                if (-not $script:ToldYouAtLeastOnceAlready) {
                    $_ | Write-Error
                    Write-Warning "Could not save style settings.  Styles will not work in jobs."
                    $script:ToldYouAtLeastOnceAlready = $true
                }
            }
            
        }
    }
}
