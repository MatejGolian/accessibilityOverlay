#Requires AutoHotkey v2.0

Class CodeParser {
    
    Lines := Array()
    SkipSequences := Array(
    "```"",
    )
    Tags := Map(
    "`"", "`"",
    "(", ")",
    "[", "]",
    "{", "}",
    )
    Vars := Map()
    
    CheckSegment(Segment) {
        If RegExMatch(Segment, "^([A-Za-z_][0-9A-Za-z_]*)\s*:=\s*([A-Za-z_][0-9A-Za-z_]*.*)", &Match)
        Return {Type: "Assign", Match: Match}
        If RegExMatch(Segment, "^([A-Za-z_][0-9A-Za-z_]*)\.([A-Za-z_][0-9A-Za-z_]*.*)", &Match)
        Return {Type: "Assign", Match: Match}
        If RegExMatch(Segment, "^([A-Za-z_][0-9A-Za-z_]*)\((.*)\)", &Match)
        Return {Type: "Func", Match: Match}
        If RegExMatch(Segment, "^([A-Za-z_][0-9A-Za-z_]*)", &Match)
        Return {Type: "Var", Match: Match}
        Return {Type: False, Match: False}
    }
    
    GetLines() {
        Return This.Lines
    }
    
    GetVar(VarName) {
        For Name, Value In This.Vars
        If Name = VarName
        Return Value
        Return False
    }
    
    Join(Segments, Subpattern := "") {
        Segment := ""
        For Index, Value In Segments {
            If Not Index = Segments.Length
            Value .= Subpattern
            Segment .= Value
        }
        Return Segment
    }
    
    ParseSegment(Segment) {
        Result := This.CheckSegment(Segment)
        If Result.Type
        Return Process%Result.Type%(Result.Match)
        Return False
        ProcessAssign(Match) {
            Param1 := Trim(Match[1])
            Param2 := Trim(Match[2])
            Param1Type := This.CheckSegment(Param1).Type
            Param2Type := This.CheckSegment(Param2).Type
            If Param1Type = "Var" {
                If Not This.Vars.Has(Param1)
                This.Vars.Set(Param1, [])
                Subpatterns := This.Split(Param2, ".")
                For Index, Subpattern In Subpatterns {
                    Subpattern := This.ParseSegment(Subpattern)
                    If Subpattern {
                        If Index = 1
                        This.Vars[Param1].Push([])
                        This.Vars[Param1][This.Vars[Param1].Length].Push(Subpattern)
                    }
                }
                If Param2Type = "Assign"
                This.ParseSegment(Param2)
                If This.Vars[Param1].Length > 0 {
                    ReturnArray := Array()
                    ReturnArray.Push(This.ParseSegment(Param1), This.Vars[Param1][This.Vars[Param1].Length]*)
                    Return ReturnArray
                }
            }
            Return False
        }
        ProcessFunc(Match) {
            Name := Trim(Match[1])
            Params := Trim(Match[2])
            SplitParams := This.Split(Params, ",")
            Params := Array()
            For Key, Value In SplitParams {
                Value := Trim(Value)
                If Value
                Params.Push(Value)
            }
            Return {Type: "Func", Name: Name, Params: Params}
        }
        ProcessVar(Match) {
            Name := Trim(Match[1])
            If Not This.Vars.Has(Name)
            This.Vars.Set(Name, [])
            Return {Type: "Var", Name: Name}
        }
    }
    
    ParseString(Value) {
        Value := StrReplace(Trim(Value), "`r`n", "`n")
        This.Lines := Array()
        This.Vars := Map()
        Lines := StrSplit(Value, "`n")
        If Not Lines Is Array
        Lines := Array(Lines)
        TrimmedLines := Array()
        For Line In Lines
        If Line
        TrimmedLines.Push(Trim(Line))
        Lines := TrimmedLines
        For Line In Lines
        If Line And Not SubStr(Line, 1, 1) = ";"
        If This.CheckSegment(Line).Type = "Assign"
        This.Lines.Push(This.ParseSegment(Line))
        Else {
            Subpatterns := This.Split(Line, ".")
            TrimmedSubpatterns := Array()
            For Subpattern In Subpatterns
            If Subpattern
            TrimmedSubpatterns.Push(Trim(Subpattern))
            Subpatterns := TrimmedSubpatterns
            ReturnArray := Array()
            For Subpattern In Subpatterns
            If Subpattern
            ReturnArray.Push(This.ParseSegment(Subpattern))
            If ReturnArray.Length > 0
            This.Lines.Push(ReturnArray)
        }
    }
    
    Split(Segment, Subpattern) {
        If Not InStr(Segment, Subpattern)
        Return Array(Segment)
        CurrentSegment := Segment
        ExpectedClosures := Array()
        Pointer := 1
        Subpatterns := Array()
        SubpatternLength := StrLen(Subpattern)
        While Pointer <= StrLen(CurrentSegment) {
            If SubStr(CurrentSegment, Pointer, SubpatternLength) = Subpattern And ExpectedClosures.Length = 0 {
                Subpatterns.Push(SubStr(CurrentSegment, 1, Pointer - 1))
                CurrentSegment := SubStr(CurrentSegment, Pointer + SubpatternLength)
                Pointer := 1
                Continue
            }
            If Pointer = StrLen(CurrentSegment) {
                Subpatterns.Push(CurrentSegment)
                Break
            }
            For Sequence In This.SkipSequences
            If SubStr(CurrentSegment, Pointer, StrLen(Sequence)) = Sequence {
                Pointer := Pointer + StrLen(Sequence)
                Continue 2
            }
            For TagOpening, TagClosure In This.Tags {
                If ExpectedClosures.Length > 0 And ExpectedClosures[1] = "`""
                Break
                If SubStr(CurrentSegment, Pointer, StrLen(TagOpening)) = TagOpening {
                    ExpectedClosures.InsertAt(1, TagClosure)
                    Pointer := Pointer + StrLen(TagOpening)
                    Continue 2
                }
            }
            For TagOpening, TagClosure In This.Tags
            If SubStr(CurrentSegment, Pointer, StrLen(TagClosure)) = TagClosure And ExpectedClosures.Length > 0 And ExpectedClosures[1] = TagClosure {
                ExpectedClosures.RemoveAt(1)
                Pointer := Pointer + StrLen(TagClosure)
                Continue 2
            }
            Pointer++
        }
        Return Subpatterns
    }
    
}
