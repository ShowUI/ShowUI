using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Collections.ObjectModel;

namespace WPK {
    public class GetReferencedCommand {
        public static IEnumerable<CommandInfo> GetReferencedCommands(ScriptBlock scriptBlock,  EngineIntrinsics executionContext, PSCmdlet cmdlet)
        {
            Dictionary<CommandInfo, bool> resolvedCommandCache = new Dictionary<CommandInfo, bool>();
            Queue<PSToken> tokenQueue = new Queue<PSToken>();
            Collection<PSParseError> errors;
            foreach (PSToken token in PSParser.Tokenize(new object[] { scriptBlock }, out errors))
            {
                tokenQueue.Enqueue(token);
            }
            if (tokenQueue.Count == 0) { 
                yield return null;
            }
            while (tokenQueue.Count > 0)
            {
                PSToken token = tokenQueue.Dequeue();
                if (token.Type == PSTokenType.Command)
                {
                    CommandInfo cmd = null;
                    cmd = executionContext.SessionState.InvokeCommand.GetCommand(token.Content, CommandTypes.Alias);
                    if (cmd == null)
                    {
                        cmd = executionContext.SessionState.InvokeCommand.GetCommand(token.Content, CommandTypes.Function);
                        if (cmd == null)
                        {
                            cmd = executionContext.SessionState.InvokeCommand.GetCommand(token.Content, CommandTypes.Cmdlet);
                        }
                    }
                    else
                    {
                        while (cmd != null && cmd is AliasInfo)
                        {
                            AliasInfo alias = cmd as AliasInfo;
                            if (!resolvedCommandCache.ContainsKey(alias))
                            {
                                yield return alias;
                                resolvedCommandCache.Add(alias, true);
                            }
                            cmd = alias.ReferencedCommand;
                        }
                    }
                    if (cmd == null) { continue; }
                    if (cmd is FunctionInfo)
                    {
                        if (! resolvedCommandCache.ContainsKey(cmd))
                        {
                            FunctionInfo func = cmd as FunctionInfo;
                            yield return cmd;
                            foreach (PSToken t in PSParser.Tokenize(new object[] { func.ScriptBlock }, out errors))
                            {
                                tokenQueue.Enqueue(t);
                            }
                            resolvedCommandCache.Add(cmd, true);
                        }
                    } else {
                        if (!resolvedCommandCache.ContainsKey(cmd))
                        {
                            yield return cmd;
                            resolvedCommandCache.Add(cmd, true);
                        }
                    }
                }
            }
        }
    }
}
