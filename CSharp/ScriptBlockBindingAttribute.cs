namespace ShowUI
{
	using System;
	using System.ComponentModel;
	using System.Management.Automation;
	using System.Collections.ObjectModel;
	using System.Collections.Generic;
	using System.Text.RegularExpressions;

	[AttributeUsage(AttributeTargets.Field | AttributeTargets.Property)]
	public class ScriptBlockBindingAttribute : ArgumentTransformationAttribute {

	   public enum PathType { Simple, Provider, Drive, Relative }

	   public PathType ResolveAs { get; set; }

	   public override string ToString() {
	      return "[ShowUI.ScriptBlockBinding()]";
	   }

	   public override Object Transform( EngineIntrinsics engine, Object inputData) {
	      // standard workaround for the initial bind when pipeline data hasn't arrived
	      if(inputData == null) {  return null; }
	      var output = new Collection<PSObject>();

	      if(inputData is ScriptBlock) {
		      try {
		      	output = engine.InvokeCommand.InvokeScript( engine.SessionState, (ScriptBlock)inputData, null );
		      } catch (ArgumentTransformationMetadataException) {
		         throw;
		      } catch (Exception e) {
		         throw new ArgumentTransformationMetadataException(string.Format("Script Argument threw an exception ('{0}'). See `$Error[0].Exception.InnerException.InnerException for more details.",e.Message), e);
		      }
		  }
	      return output;
	   }

		// # $inAsJob  = $host.Name -eq 'Default Host'
		// # if ($v -is [ScriptBlock]) {
		// #     if ($inAsJob) {
		// #         $v = . ([ScriptBlock]::Create($v))
		// #     } else {
		// #         $v = . $v
		// #     }
		// # }
	}
}