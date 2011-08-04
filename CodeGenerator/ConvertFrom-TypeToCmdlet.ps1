function ConvertFrom-TypeToScriptCmdlet
{
    <#
    .Synopsis
        Converts .NET Types into Windows PowerShell Script Cmdlets
        according to a number of rules. that have been added with Add-CodeGeneration rule
    .Description
        Converts .NET Types into Windows PowerShell Script Cmdlets
        according to a number of rules.
        
        Rules are added with Add-CodeGenerationRule                  
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Type[]]$Type,
       
    [Switch]$AsScript,
        
    [Switch]$AsCSharp,
    
    [ref]$ConstructorCmdletNames
    )        
    
    begin {
        $LinkedListType = "Collections.Generic.LinkedList"
        Set-StrictMode -Off
        # Default as Script
        if(!$AsScript) {
            $AsCSharp = $true
        }
    }
    
    process {
        foreach ($t in $type) {
            trap { Write-Warning "Error Converting $t to Cmdlet:`n$($_|Out-String)" }
            $Parameters = 
                New-Object "$LinkedListType[Management.Automation.ParameterMetaData]"
            $BeginBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            $ProcessBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            $EndBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            ## Output Blocks are the ones which we'll magically put in the right place based on IsUIContentCollector
            $OutputBlocks  = 
                New-Object "$LinkedListType[ScriptBlock]" (,[ScriptBlock[]]@({}))
            ## You shouldn't need to mess with the Constructor Blocks unless you don't want constructors
            $AutoConstructor = [bool]($t.GetConstructor(@()))
            
            if ($PSVersionTable.BuildVersion.Build -lt 7100) {
                $CmdletBinding = "[CmdletBinding()]"
            } else {
                $CmdletBinding = ""
            }

            $Help = @{
                Parameter = @{}
            }
            $Verb = ""
            $Noun = ""
            
            ## These are the core which allows us to generate pipeline enabled cmdlets
            ## But the UIContentProperty has to be set by a code generation rule for anything to happen
            $BaseType = $t | Add-Member -Passthru -Type NoteProperty   -Name UIContentProperty    -Value $null |
                             Add-Member -Passthru -Type ScriptProperty -Name IsUIContentCollector -Value {
                                ($this.UIContentProperty -ne $null) -and ($this.GetProperty($this.UIContentProperty).PropertyType.GetInterface([System.Collections.IList]) -ne $null)
                             }

            foreach ($rule in $CodeGenerationRuleOrder) {
                trap { Write-Warning "Error Converting $t to Cmdlet`n$($_|Out-String)`nIn Rule:`n$rule" }

                if (-not $rule) { continue } 
                if ($rule -is [Type] -and 
                    (($t -eq $rule) -or ($t.IsSubclassOf($rule)))) {
                    $nsb = $ExecutionContext.InvokeCommand.NewScriptBlock($codeGenerationCustomizations[$rule])
                    $null = . $nsb 
                } else {
                    if ($rule -is [ScriptBlock] -and
                        ($t | Where-Object -FilterScript $rule)) {
                        $nsb = $ExecutionContext.InvokeCommand.NewScriptBlock($codeGenerationCustomizations[$rule])
                        $null = . $nsb 
                    }
                }
            }
            
            if ((-not $Noun) -or (-not $Verb)) {
                continue
            }
            
            ## A hack to get a list of constructor cmdlets
            if($Verb -eq "New" -and (Test-Path Variable:ConstructorCmdletNames)) {
               $ConstructorCmdletNames.Value.Add( $Noun )
            }
            
            $cmd = New-Object Management.Automation.CommandMetaData ([PSObject])
            foreach ($p in $parameters) {
                $null = $cmd.Parameters.Add($p.Name, $p)
            }
            
            if ($AsScript) {
                #region Generate the Script Parameter Block
                $parameterBlock = [Management.Automation.ProxyCommand]::GetParamBlock($cmd)

                #endregion
                
                #region Generate the Help                                
                $oldOfs = $ofs
                $ofs = ""
                $helpBlock = New-Object Text.StringBuilder
                $parameterNames = "Parameter", 
                    "ForwardHelpTargetName",
                    "ForwardHelpCategory",
                    "RemoteHelpRunspace",
                    "ExternalHelp",
                    "Synopsis",
                    "Description",
                    "Notes",
                    "Link",
                    "Example",
                    "Inputs",
                    "Outputs",
                    "Component",
                    "Role",
                    "Functionality"
                if ($help.Synopsis -and $help.Description) {
                    foreach ($key in $help.Keys) {
                        if ($parameterNames -notcontains $key) {
                            Write-Error "Could not generate help for $t.  The Help dictionary contained a key ($key) that is not a valid help section"
                            break
                        }                
                    }                
                    foreach ($kv in $help.GetEnumerator()) {
                        switch ($kv.Key) {
                            Parameter {
                                foreach ($p in $kv.Value.GetEnumerator()) {
                                    if (-not $p) { continue } 
                                        $null = $helpBlock.Append(
        "
        .Parameter $($p.Key)
            $($p.Value)")
                                }                        
                            }
                            Example {
                                foreach ($ex in $kv.Value) {
                                    $null = $helpBlock.Append(
        "
        .Example
            $ex")                        
                                
                                }
                            }
                            default {
                                $null = $helpBlock.Append(
        "
        .$($kv.Key)
            $($kv.Value)")                        
                            }
                        }
                    }
                }
                $helpBlock = "$helpBlock"
                if ($helpBlock) {
                    $helpBlock = "
        <#
        $HelpBlock
        #>
    "
                }
                
                #endregion

                #region Generate Final Script Code
@"
    function $Verb-$Noun {
        $HelpBlock
        
        $CmdletBinding
        param(
            $parameterBlock
        )
        begin {
            $BeginBlocks
            $(if($AutoConstructor -and $BaseType.IsUIContentCollector){ '$outputObject = New-Object ' + $BaseType.FullName })
        }
        process {
            $(if($AutoConstructor -and !$BaseType.IsUIContentCollector){ '$outputObject = New-Object ' + $BaseType.FullName })
            $ProcessBlocks
            $(if(!$BaseType.IsUIContentCollector){ 
                $OutputBlocks 
                "Write-Output (,`$Object)"
            })
        }
        end {
            $(if($BaseType.IsUIContentCollector){ 
                $OutputBlocks 
                "Write-Output (,`$Object)"
            })
            $EndBlocks
        }
    }
"@            
                #endregion 
            } elseif ($AsCSharp) {
                
                #region Generate the C# Parameter Block
                $usingBlock = New-Object Text.StringBuilder
                $null = $usingBlock.Append("
using System;
using System.Collections;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

")                
                $propertyBlock = New-Object Text.StringBuilder
                $fieldBlock = New-Object Text.StringBuilder
                
                $null = $fieldBlock.Append(@"
        /// <summary>
        /// A Field to store the pipeline used to invoke the commands
        /// </summary>
        private Pipeline pipeline;    
"@)
                
                $namespaces = "$usingBlock" -split ([Environment]::NewLine) | 
                    Where-Object { $_ } | 
                    ForEach-Object { $_.Trim().Replace("using ", "").Replace(";","") 
                } 
                
                $parameterNames = $parameters | Select-Object -ExpandProperty Name

                foreach ($p in $parameters) {
                    if (-not $p) { continue } 
                    # declare the field
                    $parameterName = $fieldName = $p.Name
                    
                    $fieldName = $fieldName.ToCharArray()[0].ToString().ToLower() + 
                        $fieldName.Substring(1)
                    $PropertyName = $fieldName.ToCharArray()[0].ToString().ToUpper() + 
                        $fieldName.Substring(1)
                                                            
                    $parameterType = $p.ParameterType
                    if (-not $parameterType) { $parameterType = [Object] } 
                    $parameterTypeFullName = $parameterType.Fullname
                    $parameterNamespace = $parameterType.Namespace    
                    
                    if ($namespaces -notcontains $parameterNamespace) {
                        $null = $usingBlock.AppendLine("using $parameterNamespace;")
                        $namespaces = "$usingBlock" -split ([Environment]::NewLine) | 
                            Where-Object { $_ } | 
                            ForEach-Object { $_.Trim().Replace("using ", "").Replace(";","") 
                        } 
                    }                     
                    $fieldType = $p.Property
                    
                    $parameterAttributes = $p.Attributes | 
                        Where-Object { 
                            $_ -is [Management.Automation.ParameterAttribute] 
                        } |
                        ForEach-Object {
                            $attributeParts = @()
                            $item = $_
                            if ($item.Position -ge 0) { 
                                $attributeParts+="Position=$($item.Position)"
                            }
                            if ($item.ParameterSetName -ne '__AllParameterSets') {
                                $attributeParts+="ParameterSetName=$($item.ParameterSetName)"
                            }
                            if ($item.Mandatory) {
                                $attributeParts+="Mandatory=true"                            
                            }
                            if ($item.ValueFromPipeline) {
                                $attributeParts+="ValueFromPipeline=true"                            
                            }
                            if ($item.ValueFromPipelineByPropertyName) {
                                $attributeParts+="ValueFromPipelineByPropertyName=true"
                            }
                            if ($item.ValueFromRemainingArguments) {
                                $attributeParts+="ValueFromRemainingArguments=true"
                            }
                            if ($item.HelpMessage) {
                                $attributeParts+="HelpMessage=@`"$($item.HelpMessage)`""
                            }
                            if ($item.HelpMessageBaseName) {
                                $attributeParts+="HelpMessageBaseName=@`"$($item.HelpMessageBaseName)`""
                            }
                            if ($item.HelpMessageResourceId) {
                                $attributeParts+="HelpMessageResourceId=@`"$($item.HelpMessageResourceId)`""
                            }
                            $ofs = ","
                            "[Parameter($attributeParts)]"
                        }
                    
                    if (-not $parameterAttributes) {
                        # In this case, the parameter is not mandatory, 
                        # and will be marked ValueFromPipelineByPropertyName and will assume the first default position                        
                        $parameterAttributes += "[Parameter()]"
                    }
                    $ofs = [Environment]::NewLine
                    $ParameterDeclaration = "$parameterAttributes"            

                    $null = $propertyBlock.Append("
        /// <summary>
        /// Gets or sets the $PropertyName property, which holds the value for the $ParameterName
        /// </summary>
        $ParameterDeclaration
        public $parameterTypeFullName $PropertyName { get; set; }
")     
                }

                #endregion   
                
                #region Create the Begin/Process/End code chunks
                
                # The trick here is InvokeScript.  
                # Each of the Begin/Process/End effectively becomes an InvokeScript, 
                # with all of the values passed in as positional arguments                 
                
                
                $pNames=  @("BoundParameters") + $parameterNames
                $ofs = ',$'
                $parameterDeclaration = "param(`$$pNames)"
                                
                $beginBlocks = @($beginBlocks)
                $processBlocks = @($processBlocks)
                $endBlocks = @($endBlocks)
                
                if(!$BaseType.IsUIContentCollector){ 
                    $processBlocks = @($processBlocks) + @($outputBlocks)
                } else {
                    $endBlocks = @($outputBlocks) + @($endBlocks)
                }
                $beginProcessingCode = ""
                
                if ($beginBlocks)  {
                    $ofs = [Environment]::NewLine                
                    $fullBeginBlock = "
$parameterDeclaration
$beginBlocks".Replace('"','""')

                    $ofs =','
                
                    $beginProcessingCode = @"
                    System.Collections.Generic.Dictionary<string,Object> BoundParameters = this.MyInvocation.BoundParameters;
                    PSLanguageMode languageMode = this.SessionState.LanguageMode;
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = PSLanguageMode.FullLanguage;
                    }
                    try {
                        pipeline.Commands.AddScript(@"
$fullBeginBlock
", true );
                        pipeline.Commands[0].Parameters.Add("BoundParameters", BoundParameters);
                        foreach (System.Collections.Generic.KeyValuePair<string,Object> param in this.MyInvocation.BoundParameters) {
                            pipeline.Commands[0].Parameters.Add(param.Key, param.Value);
                        }
                    
                        pipeline.Invoke();

                    } catch (Exception ex) {
                        this.WriteWarning( "There was an Exception" );
                        ErrorRecord errorRec; 
                        if (ex is ActionPreferenceStopException) {
                            ActionPreferenceStopException aex = ex as ActionPreferenceStopException;
                            errorRec = aex.ErrorRecord;
                        } else {
                            errorRec = new ErrorRecord(ex, "EmbeddedProcessRecordError", ErrorCategory.NotSpecified, null);
                        }
                        if (errorRec != null) {
                            this.WriteError(errorRec);
                        }
                    }
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = languageMode;
                    }
"@                

                }
                
                $pNames=  @("BoundParameters", "OutputObject") + $parameterNames
                $ofs = ',$'
                $parameterDeclaration = "param(`$$pNames)"

                
$ofs = [Environment]::NewLine
$AsJobScript = "
$parameterDeclaration
#BEGIN ############################################################
$beginBlocks
#CONSTRUCTOR ############################################################
`$OutputObject = New-Object $($BaseType.FullName)
#PROCESS ############################################################
$ProcessBlocks
#OUTPUT ############################################################
$OutputBlocks
Write-Output (,`$OutputObject)
#END ############################################################
$endBlocks
".Replace('"','""')

                $endProcessingCode = ""
                if ($endBlocks) {
                    $ofs = [Environment]::NewLine
                    $fullEndBlock = "
$parameterDeclaration
$endBlocks".Replace('"','""')

                    $ofs =','
                
                    $EndProcessingCode = New-Object Text.StringBuilder
                    $null = $EndProcessingCode.Append(@"
System.Collections.Generic.Dictionary<string,Object> BoundParameters = this.MyInvocation.BoundParameters;
                    PSLanguageMode languageMode = this.SessionState.LanguageMode;
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = PSLanguageMode.FullLanguage;
                    }
                    try {
                        $( if($pNames -contains "AsJob" ) { "if(!AsJob){" } )
                        pipeline.Commands.AddScript(@"
$fullEndBlock
", true);
                        $( if($pNames -contains "AsJob" ) { @"
                        } else {
                        pipeline.Commands.AddScript(@"
$AsJobScript
", true);
                        }
"@ } )
                        pipeline.Commands[0].Parameters.Add("BoundParameters", BoundParameters);
                        pipeline.Commands[0].Parameters.Add("OutputObject", outputObject);

                        foreach (System.Collections.Generic.KeyValuePair<string,Object> param in this.MyInvocation.BoundParameters) {
                            pipeline.Commands[0].Parameters.Add(param.Key, param.Value);
                        }

                        $(
                        if(($pNames -contains "AsJob") -and !$BaseType.IsUIContentCollector){
                            "if(Show||ShowUI||AsJob) { WriteObject(pipeline.Invoke(), true); } else { pipeline.Invoke(); }"
                        } else {
                            "pipeline.Invoke();"
                        }
                        )

                    } catch (Exception ex) {
                        ErrorRecord errorRec; 
                        if (ex is ActionPreferenceStopException) {
                            ActionPreferenceStopException aex = ex as ActionPreferenceStopException;
                            errorRec = aex.ErrorRecord;
                        } else {
                            errorRec = new ErrorRecord(ex, "EmbeddedProcessRecordError", ErrorCategory.NotSpecified, null);
                        }
                        if (errorRec != null) {
                            this.WriteError(errorRec);
                        }
                    }
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = languageMode;
                    }
"@)
                    foreach ($param in $parameterNames) {
                        $null = $EndProcessingCode.Append(@"

this.SessionState.PSVariable.Remove("$param");
"@)                     
                    }
                }
                
                $ProcessRecordCode=""
                if ($processBlocks) {
                    $ofs = [Environment]::NewLine                
                    $fullProcessBlock = "
$parameterDeclaration
$processBlocks".Replace('"','""')

                    $ofs =','
   
                    $ProcessRecordCode = @"
                    System.Collections.Generic.Dictionary<string,Object> BoundParameters = this.MyInvocation.BoundParameters;
                    PSLanguageMode languageMode = this.SessionState.LanguageMode;
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = PSLanguageMode.FullLanguage;
                    }
                    try {
                    
                        pipeline.Commands.AddScript(@"
$fullProcessBlock
", true);
                        pipeline.Commands[0].Parameters.Add("BoundParameters", BoundParameters);
                        pipeline.Commands[0].Parameters.Add("OutputObject", outputObject);

                        foreach (System.Collections.Generic.KeyValuePair<string,Object> param in this.MyInvocation.BoundParameters) {
                            pipeline.Commands[0].Parameters.Add(param.Key, param.Value);
                        }
                        $(
                        if(($pNames -contains "AsJob") -and !$BaseType.IsUIContentCollector){
                            "if(Show||ShowUI||AsJob) { WriteObject(pipeline.Invoke(), true); } else { pipeline.Invoke(); }"
                        } else {
                            "pipeline.Invoke();"
                        }
                        )

                    } catch (Exception ex) {
                        ErrorRecord errorRec; 
                        if (ex is ActionPreferenceStopException) {
                            ActionPreferenceStopException aex = ex as ActionPreferenceStopException;
                            errorRec = aex.ErrorRecord;
                        } else {
                            errorRec = new ErrorRecord(ex, "EmbeddedProcessRecordError", ErrorCategory.NotSpecified, null);                        
                        }                       
                        if (errorRec != null) {
                            this.WriteError(errorRec);                                                
                        }
                    }
                    if (languageMode != PSLanguageMode.FullLanguage) { 
                        this.SessionState.LanguageMode = languageMode;
                    }
"@
                }
                #endregion

                #region Generate the final cmdlet
$namespaceID = Get-Random
@"
namespace AutoGenerateCmdlets$namespaceID
{
    $usingBlock

    [Cmdlet("$Verb", "$Noun")]
    [OutputType(typeof($($BaseType.FullName)))]
    public class ${Verb}${Noun}Command : PSCmdlet 
    {
        $fieldBlock
        $propertyBlock
        
        $(if($AutoConstructor) {
            "$($BaseType.FullName) outputObject;"
        } else {
            "object outputObject;"
        })
        
        protected override void BeginProcessing()
        {
            $( if($pNames -contains "AsJob" ) { "if(!AsJob){" } )
                pipeline = Runspace.DefaultRunspace.CreateNestedPipeline();
                $BeginProcessingCode
                $(if($AutoConstructor -and $BaseType.IsUIContentCollector){
                    "outputObject = new " + $BaseType.FullName + "();"
                })
                pipeline.Dispose();
            $( if($pNames -contains "AsJob" ) { "}" } )
        }

        protected override void ProcessRecord()
        {
            $( if($pNames -contains "AsJob") { "if(!AsJob){" } )
                pipeline = Runspace.DefaultRunspace.CreateNestedPipeline();
                $(if($AutoConstructor -and !$BaseType.IsUIContentCollector){ "outputObject = new " + $BaseType.FullName + "();" })
                $ProcessRecordCode
                $(if(!$BaseType.IsUIContentCollector){
                    if($pNames -contains "Show" -or $pNames -contains "ShowUI") {
                        "if(!Show&&!ShowUI&&!AsJob) { WriteObject(outputObject, true); }" 
                    } else {
                        "WriteObject(outputObject, true);"
                    }
                })
                pipeline.Dispose();
            $( if($pNames -contains "AsJob" ) { "}" } )
        }

        protected override void EndProcessing()
        {
            pipeline = Runspace.DefaultRunspace.CreateNestedPipeline();
            $EndProcessingCode
            $(if($BaseType.IsUIContentCollector){
                if($pNames -contains "AsJob") {
                    "if(!Show&&!ShowUI&&!AsJob) { WriteObject(outputObject, true); }" 
                } else {
                    "WriteObject(outputObject, true);"
                }
            })
            pipeline.Dispose();
        }
    }
}
"@
                #endregion
            }
        }        
    }
}
