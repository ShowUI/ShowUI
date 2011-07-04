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
            $Parameters = 
                New-Object "$LinkedListType[Management.Automation.ParameterMetaData]"
            $BeginBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            $ProcessBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            $EndBlocks = 
                New-Object "$LinkedListType[ScriptBlock]"
            if ($PSVersionTable.BuildVersion.Build -lt 7100) {
                $CmdletBinding = "[CmdletBinding()]"
            } else {
                $CmdletBinding = ""
            }
            try {
                $Help = @{
                    Parameter = @{}
                }
                $Verb = ""
                $Noun = ""
                
                $BaseType = $t            

                foreach ($rule in $CodeGenerationRuleOrder) {
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
            } catch {
                Write-Error "Problem building $t"
                Write-Error $_
            }
            
            if ((-not $Noun) -or (-not $Verb)) {
                continue
            }
            
            ## A hack to get a list of constructor cmdlets
            if($Verb -eq "New" -and (Test-Path Variable:ConstructorCmdletNames)) {
               $ConstructorCmdletNames.Value += $Noun
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
        }
        process {
            $ProcessBlocks
        }
        end {
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
// using ShowUI;

")                
                $propertyBlock = New-Object Text.StringBuilder
                $fieldBlock = New-Object Text.StringBuilder
                
                $null = $fieldBlock.Append(@"
        /// <summary>
        /// A Field to store the pipeline used to invoke the commands
        /// </summary>
        private Pipeline pipeline;    
"@)
                
                $defaultParameterPosition =0 
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
                    if (-not $parameterType) { $parameterType = [PSObject] } 
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
                        $parameterAttributes += "[Parameter(Position=$defaultParameterPosition)]"
                        $defaultParameterPosition++
                    }
                    $ofs = [Environment]::NewLine
                    $ParameterDeclaration = "$parameterAttributes"            
                    $null = $fieldBlock.Append("
")               

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
                $beginProcessingCode = ""
                
                if ($beginBlocks)  {
                    $ofs = [Environment]::NewLine                
                    $fullBeginBlock = "
$parameterDeclaration
$beginBlocks".Replace('"','""')

                    $ofs =','
                
                    $beginProcessingCode = @"
                    System.Collections.Generic.Dictionary<string,Object> BoundParameters = this.MyInvocation.BoundParameters;
this.InvokeCommand.InvokeScript(@"
$fullBeginBlock
", new Object[] { $pNames } );
"@                

                }
                
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
                    
                    pipeline.Commands.AddScript(@"
$fullEndBlock
", true);

                    foreach (System.Collections.Generic.KeyValuePair<string,Object> param in this.MyInvocation.BoundParameters) {
                        pipeline.Commands[0].Parameters.Add(param.Key, param.Value);                    
                    }
                    
                    try {
                        this.WriteObject(
                            pipeline.Invoke(),
                            true);

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
"@)                    
                    foreach ($param in $parameterNames) {
                        $null = $EndProcessingCode.Append(@"
this.SessionState..PSVariable.Remove("$param");
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
                    
                    pipeline.Commands.AddScript(@"
$fullProcessBlock
", true);

                    foreach (System.Collections.Generic.KeyValuePair<string,Object> param in this.MyInvocation.BoundParameters) {
                        pipeline.Commands[0].Parameters.Add(param.Key, param.Value);                    
                    }
                    
                    try {
                        this.WriteObject(
                            pipeline.Invoke(),
                            true);

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
        
        protected override void BeginProcessing()
        {
            pipeline = Runspace.DefaultRunspace.CreateNestedPipeline();
                
            $BeginProcessingCode
        }    

        protected override void ProcessRecord() 
        {
            pipeline.Commands.Clear();            
            $ProcessRecordCode
        }

        protected override void EndProcessing() 
        {
            $EndProcessingCode
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
