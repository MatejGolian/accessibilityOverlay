#Requires AutoHotkey v2.0

Class ParamHandler {
    
    Static __Call(Value, Params) {
        If Not SubStr(Value, -11) = "CustomLabel" And SubStr(Value, -5) = "Label"
        Return This.HandleLabel(Params*)
        If Params.Length = 4 {
            Name := Params[1]
            Value := Params[2]
            Expression := Params[3]
            Optional := Params[4]
            If Value = "" And Not Optional
            Return This.Error("You did not enter the " . Name . ".")
            Return Value
        }
        Return False
    }
    
    Static HandleHotspotButtonHotkeyCommand(Name, Value, Expression, Optional) {
        If Not Value = "" And Not Expression
        Return "`"" . Value . "`""
        Return Value
    }
    
    Static HandleLabel(Name, Value, Expression, Optional) {
        If Not Expression
        Return "`"" . Value . "`""
        If Value = ""
        Return "`"" . Value . "`""
        Return Value
    }
    
    Class Error {
        
        Message := ""
        
        __New(Message) {
            This.Message := Message
        }
        
    }
    
}
