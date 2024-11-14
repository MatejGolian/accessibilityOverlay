#Requires AutoHotkey v2.0

Class CodeParser {
    
    ItemMap := Map()
    Lines := Array()
    MasterOverlay := False
    SkipSequences := Array(
    "```"",
    )
    StartingLine := False
    TempItem := False
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
    
    ImportOverlay(OverlayCode) {
        This.MasterOverlay := False
        This.StartingLine := False
        This.TempItem := False
        If Not Editor.ItemDefinitions.Has("CodeParserTemp") {
            CodeParserTemp := {Type: "CodeParserTemp", CanAdd: [], Expand: True, EditorParams: [{Expression: 2, Name: "CustomLabel", Optional: True, Value: ""}, {Expression: 2, Name: "VarName", Optional: False, Value: "CodeParserTemp"}], ConstructorParams: [], HotkeyParams: []}
            For ItemName, ItemDefinition In Editor.ItemDefinitions
            If ItemDefinition Is Object And ItemDefinition.CanAdd And ItemDefinition.CanAdd Is Array
            For ItemType In ItemDefinition.CanAdd {
                For Value In CodeParserTemp.CanAdd
                If Value = ItemType
                Continue 2
                CodeParserTemp.CanAdd.Push(ItemType)
            }
            Editor.ItemDefinitions.Set("CodeParserTemp", CodeParserTemp)
        }
        This.ParseString(OverlayCode)
        If This.Lines.Length = 0 Or This.Vars.Count = 0 {
            MsgBox "Nothing to import.", "Error"
            Return False
        }
        For Name, Value In This.Vars
        This.ItemMap.Set(Name, {ID: "", Type: ""})
        For LineNumber, Line In This.Lines
        If Line.Length > 1 And Line[1].Type = "Var" And Line[2].Type = "Func" And Line[2].Name = "AccessibilityOverlay" {
            This.StartingLine := LineNumber
            Break
        }
        If Not This.StartingLine {
            MsgBox "No importable overlays found.", "Error"
            Return False
        }
        For LineNumber, Line In This.Lines
        If LineNumber >= This.StartingLine
        If Not This.ProcessLine(LineNumber, Line) {
            Editor.DeleteItem(This.MasterOverlay, False)
            Editor.DeleteItem(This.TempItem, False)
            MsgBox "Import failed on line " . LineNumber . ".", "Error"
            Return False
        }
        Editor.DeleteItem(This.TempItem, False)
        MsgBox "Operation succeeded.", "import Overlay"
        Return True
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
    
    ProcessLine(LineNumber, Line) {
        If Line.Length > 1 And Line[1].Type = "Var" {
            If LineNumber = This.StartingLine
            This.TempItem := Editor.AddItem(Editor.MainWindow.MainTree.OverlayRoot, "CodeParserTemp", False)
            Var1 := Line[1].Name
            Var1ID := False
            Var1Type := False
            Var2 := False
            Var2ID := False
            Var2Type := False
            StartingIndex := 2
            If Line[2].Type = "Var" {
                Var2 := Line[2].Name
                If This.ItemMap.Has(Var2) {
                    Var2ID := This.ItemMap[Var2].ID
                    Var2Type := This.ItemMap[Var2].Type
                }
                StartingIndex := 3
            }
            If LineNumber = This.StartingLine {
                Var1ID := Editor.AddItem(Editor.MainWindow.MainTree.OverlayRoot, "AccessibilityOverlay")
                Var1Type := "AccessibilityOverlay"
                Editor.SetItemParam(Var1ID, "Editor", "VarName", Var1)
                SetConstructorParams(Line[2].Params, Var1ID)
                This.ItemMap[Var1].ID := Var1ID
                This.ItemMap[Var1].Type := "AccessibilityOverlay"
                This.MasterOverlay := Var1ID
            }
            Else {
                If This.ItemMap.Has(Var1) {
                    Var1ID := This.ItemMap[Var1].ID
                    Var1Type := This.ItemMap[Var1].Type
                    If Not Var1ID {
                        Var1ID := This.TempItem
                        Var1Type := "CodeParserTemp"
                        This.ItemMap[Var1].ID := Var1ID
                        This.ItemMap[Var1].Type := Var1Type
                    }
                }
            }
            If Var2 And Not Var2ID
            Return False
            If Line.Length = 2 And Line[2].Type = "Var" And This.ItemMap.Has(Line[2].Name) {
                ItemID := This.ItemMap[Line[2].Name].ID
                ItemType := This.ItemMap[Line[2].Name].Type
                This.ItemMap[Var1].ID := ItemID
                This.ItemMap[Var1].Type := ItemType
            }
            AddedItem := False
            For Index, Segment In Line
            If Index >= StartingIndex {
                If Index = 2 And LineNumber = This.StartingLine
                Continue
                If Segment.Type = "Func" {
                    ItemID := Var1ID
                    ItemType := Var1Type
                    If Var2 {
                        ItemID := Var2ID
                        ItemType := Var2Type
                    }
                    If Index = 2 And Editor.ItemDefinitions.Has(Segment.Name) And Editor.CanAdd(ItemType, Segment.Name) {
                        AddedItem := Editor.AddItem(ItemID, Segment.Name, False)
                        Editor.SetItemParam(AddedItem, "Editor", "VarName", Var1)
                        ItemID := AddedItem
                        ItemType := Segment.Name
                        SetConstructorParams(Segment.Params, ItemID)
                        This.ItemMap[Var1].ID := ItemID
                        This.ItemMap[Var1].Type := ItemType
                        Continue
                    }
                    If SubStr(Segment.Name, 1, 3) = "Add" And Editor.ItemDefinitions.Has(SubStr(Segment.Name, 4)) And Editor.CanAdd(ItemType, SubStr(Segment.Name, 4)) {
                        AddedItem := Editor.AddItem(ItemID, SubStr(Segment.Name, 4), False)
                        ItemID := AddedItem
                        ItemType := SubStr(Segment.Name, 4)
                        SetConstructorParams(Segment.Params, ItemID)
                        If Var2 {
                            Editor.SetItemParam(AddedItem, "Editor", "VarName", Var1)
                            This.ItemMap[Var1].ID := ItemID
                            This.ItemMap[Var1].Type := ItemType
                        }
                        Continue
                    }
                    If Segment.Name = "AddControl" And Segment.Params.Length = 1 {
                        IsValid := True
                        ItemCheck := False
                        ItemToAdd := Segment.Params[1]
                        SetConstructor := False
                        TypeToAdd := False
                        ValidTypes := ["AccessibilityOverlay", "CustomTab", "GraphicalTab", "HotspotTab", "OCRTab", "Tab"]
                        If Not This.Vars.Has(ItemToAdd) Or Not This.Vars[ItemToAdd].Type
                        IsValid := False
                        Else
                        TypeToAdd := This.Vars[ItemToAdd].Type
                        If Not IsValid {
                            ItemCheck := This.CheckSegment(ItemToAdd)
                            If ItemCheck.Type = "Func" {
                                IsValid := True
                                ItemCheck := This.ParseSegment(ItemToAdd)
                                SetConstructor := True
                                TypeToAdd := ItemCheck.Name
                            }
                        }
                        If IsValid
                        For ValidType In ValidTypes
                        If ItemType = ValidType {
                            IsValid := True
                            Break
                        }
                        If IsValid And Editor.ItemDefinitions.Has(TypeToAdd) And Editor.CanAdd(ItemType, TypeToAdd) {
                            AddedItem := Editor.AddItem(ItemID, TypeToAdd, False)
                            ItemID := AddedItem
                            ItemType := TypeToAdd
                            If SetConstructor
                            SetConstructorParams(ItemCheck.Params, ItemID)
                            If Var2 {
                                Editor.SetItemParam(AddedItem, "Editor", "VarName", Var1)
                                This.ItemMap[Var1].ID := ItemID
                                This.ItemMap[Var1].Type := ItemType
                            }
                        }
                        Continue
                    }
                    If ItemType = "TabControl" And Segment.Type = "Func" And Segment.Name = "AddTabs" {
                        For Param In Segment.Params {
                            ParamID := False
                            ParamType := False
                            If This.ItemMap.Has(Param) And This.ItemMap[Param].ID And This.ItemMap[Param].Type {
                                ParamID := This.ItemMap[Param].ID
                                ParamType := This.ItemMap[Param].Type
                            }
                            If Editor.CanAdd(ItemType, ParamType) {
                                ChildItems := Editor.GetChildItems(ItemID)
                                If ChildItems.Length > 0 {
                                    BufferBackup := Editor.EditorBuffer
                                    Editor.CutItem(ParamID)
                                    LastChild := ChildItems[ChildItems.Length]
                                    Editor.PasteItem(LastChild,,, False)
                                    Editor.EditorBuffer := BufferBackup
                                }
                            }
                        }
                        Break
                    }
                    If Segment.Name = "SetHotkey" {
                        If Index = 2
                        SetHotkeyParams(Segment.Params, This.ItemMap[Var1].ID)
                        Else If Var2 And Index = 3
                        SetHotkeyParams(Segment.Params, This.ItemMap[Var2].ID)
                        Else
                        If AddedItem
                        SetHotkeyParams(Segment.Params, AddedItem)
                        Break
                    }
                }
            }
        }
        Return True
        SetConstructorParams(Params, ItemID) {
            SetParams("Constructor", Params, ItemID)
        }
        SetHotkeyParams(Params, ItemID) {
            SetParams("Hotkey", Params, ItemID)
        }
        SetParams(ParamGroup, Params, ItemID) {
            For ParamNumber, Param In Params
            If Editor.Items[ItemID].%ParamGroup%Params.Length >= ParamNumber {
                Expression := Editor.Items[ItemID].%ParamGroup%Params[ParamNumber].Expression
                If Expression = 1 Or Expression = 3 {
                    StringTest := This.Join(This.Split(Param, "`""))
                    If SubStr(Param, 2, -1) = StringTest
                    Editor.Items[ItemID].%ParamGroup%Params[ParamNumber].Expression := 1
                    Else
                    Editor.Items[ItemID].%ParamGroup%Params[ParamNumber].Expression := 3
                }
                Editor.Items[ItemID].%ParamGroup%Params[ParamNumber].Value := Param
            }
            Editor.SetItemParam(ItemID)
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
