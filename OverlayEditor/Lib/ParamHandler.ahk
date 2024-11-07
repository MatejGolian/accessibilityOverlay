#Requires AutoHotkey v2.0

Class ParamHandler {
    
    Static __Call(Value, Properties) {
        If Properties.Length = 4 {
            Name := Properties[1]
            Value := Properties[2]
            Expression := Properties[3]
            Optional := Properties[4]
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
    
    Static HandleHotspotButtonLabel(Name, Value, Expression, Optional) {
        If Not Expression
        Return "`"" . Value . "`""
        If Value = ""
        Return "`"" . Value . "`""
        Return Value
    }
    
    Static HandleHotspotButtonHotkeyLabel(Name, Value, Expression, Optional) {
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
