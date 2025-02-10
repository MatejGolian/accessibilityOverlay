#Requires AutoHotkey v2.0

Class Editor {
    
    Static AppName := "Overlay Editor"
    Static EditorBuffer := ""
    Static Items := Map()
    Static ItemDefinitions := Map()
    Static MainWindow := Object()
    
    Static __New() {
        #Include ../Includes/ItemDefinitions.ahk
        This.MainWindow := Gui("+OwnDialogs", This.AppName)
        This.MainWindow.AddButton("vImportButton", "Import").OnEvent("Click", ObjBindMethod(This, "Import"))
        This.MainWindow.AddText("Section XS", "Items")
        This.MainWindow.AddTreeView("XS vMainTree").OnEvent("ContextMenu", ObjBindMethod(This, "ShowEditMenu"))
        This.MainWindow.AddText("YS", "Code")
        This.MainWindow.AddEdit("W1000 R3000 XM vCodeField +Multi +ReadOnly")
        This.MainWindow.ImportButton := This.MainWindow["ImportButton"]
        This.MainWindow.MainTree := This.MainWindow["MainTree"]
        This.MainWindow.MainTree.OverlayRoot := This.MainWindow.MainTree.Add("Overlays",, "Expand")
        This.MainWindow.CodeField := This.MainWindow["CodeField"]
        This.AddItem(This.MainWindow.MainTree.OverlayRoot, "DummyItem", False)
        This.MainWindow.OnEvent("Close", ObjBindMethod(This, "Close"))
    }
    
    Static AddItem(Parent, Type, Select := True) {
        ItemDefinition := This.ItemDefinitions[Type]
        Selection := This.MainWindow.MainTree.GetSelection()
        Item := This.MainWindow.MainTree.Add(Type, Parent, "Expand" . ItemDefinition.Expand . " " . Selection)
        For ChildItem In This.GetChildItems(Parent)
        If This.Items.Has(ChildItem) And This.Items[ChildItem].Type = "DummyItem"
        This.DeleteItem(ChildItem, False)
        This.Items.Set(Item, This.CloneObj(ItemDefinition))
        This.SetItemParam(Item, "Editor", "VarName", Type . Item)
        If ItemDefinition.Expand
        This.AddItem(Item, "DummyItem", False)
        If Select
        This.MainWindow.MainTree.Modify(Item)
        This.UpdateCodeField()
        Return Item
    }
    
    Static CanAdd(Type, Value) {
        If This.ItemDefinitions.Has(Type)
        If This.ItemDefinitions[Type].CanAdd And This.ItemDefinitions[Type].CanAdd Is Array
        For Item In This.ItemDefinitions[Type].CanAdd
        If Item = Value
        Return True
        Return False
    }
    
    Static CloneObj(Obj) {
        NewObj := Obj.Clone()
        If NewObj Is Array {
            For Key, Value In NewObj
            If Value Is Object
            NewObj[Key] := This.CloneObj(Value)
            Else
            NewObj[Key] := Value
        }
        Else
        If NewObj Is Object {
            For Key, Value In NewObj.OwnProps()
            If Value Is Object
            NewObj.%Key% := This.CloneObj(Value)
            Else
            NewObj.%Key% := Value
        }
        Return NewObj
    }
    
    Static Close(*) {
        FocusedControl := This.MainWindow.FocusedCtrl
        This.MainWindow.Opt("+OwnDialogs")
        This.MainWindow.Opt("+Disabled")
        ConfirmationDialog := MsgBox("Are you sure you want to quit?", This.AppName, 4)
        If ConfirmationDialog == "Yes"
        ExitApp
        This.MainWindow.Show()
        This.MainWindow.Opt("-Disabled")
        If FocusedControl
        FocusedControl.Focus()
        Return True
    }
    
    Static CopyItem(Item) {
        If This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem"
        If This.CopyToBuffer(Item) {
            This.EditorBuffer := This.CopyToBuffer(Item)
            Return This.EditorBuffer
        }
        Return False
    }
    
    Static CopyToBuffer(Item) {
        If This.Items.Has(Item) {
            EditorBuffer := Map("RootItem", This.CloneObj(This.Items[Item]), "ChildItems", [])
            For ChildItem In This.GetChildItems(Item, True)
            EditorBuffer["ChildItems"].Push(This.CopyToBuffer(ChildItem))
            Return EditorBuffer
        }
        Return False
    }
    
    Static CreateMenu(Name) {
        Switch Name {
            Case "Add":
            Selection := This.MainWindow.MainTree.GetSelection()
            Parent := This.MainWindow.MainTree.GetParent(Selection)
            If Not Parent And                        Not This.MainWindow.MainTree.Get(Selection, "Expanded") {
                Return False
            }
            Else If Not Parent And                        This.MainWindow.MainTree.Get(Selection, "Expanded") {
                Return False
            }
            Else If Not This.Items.Has(Parent) {
                AddMenu := Menu()
                AddMenu.Add("AccessibilityOverlay", AddMenuHandler)
                Return AddMenu
            }
            Else {
                AddMenu := False
                MenuSource := This.Items[Parent]
                If MenuSource.CanAdd {
                    AddMenu := Menu()
                    For ItemType In MenuSource.CanAdd
                    AddMenu.Add(ItemType, AddMenuHandler)
                }
                Return AddMenu
            }
            Case "Edit":
            Selection := This.MainWindow.MainTree.GetSelection()
            Parent := This.MainWindow.MainTree.GetParent(Selection)
            If Not Parent And                        Not This.MainWindow.MainTree.Get(Selection, "Expanded") {
                Return False
            }
            Else If Not Parent And                        This.MainWindow.MainTree.Get(Selection, "Expanded") {
                Return False
            }
            Else If Not This.Items.Has(Parent) {
                EditMenu := Menu()
                Item := This.Items[Selection]
                AddMenu := This.CreateMenu("Add")
                If AddMenu Is Menu
                EditMenu.Add("Add", AddMenu)
                EditMenu.Add("Cut", EditMenuHandler)
                EditMenu.Add("Copy", EditMenuHandler)
                EditMenu.Add("Paste", EditMenuHandler)
                EditMenu.Add("Delete...", EditMenuHandler)
                EditMenu.Add("Properties...", EditMenuHandler)
                If Item.Type = "DummyItem" {
                    EditMenu.Disable("Cut")
                    EditMenu.Disable("Copy")
                    EditMenu.Disable("Delete...")
                    EditMenu.Disable("Properties...")
                }
                Return EditMenu
            }
            Else {
                EditMenu := Menu()
                Item := This.Items[Selection]
                AddMenu := This.CreateMenu("Add")
                If AddMenu Is Menu
                EditMenu.Add("Add", AddMenu)
                EditMenu.Add("Cut", EditMenuHandler)
                EditMenu.Add("Copy", EditMenuHandler)
                EditMenu.Add("Paste", EditMenuHandler)
                EditMenu.Add("Delete...", EditMenuHandler)
                EditMenu.Add("Properties...", EditMenuHandler)
                If Item.Type = "DummyItem" {
                    EditMenu.Disable("Cut")
                    EditMenu.Disable("Copy")
                    EditMenu.Disable("Delete...")
                    EditMenu.Disable("Properties...")
                }
                Return EditMenu
            }
        }
        Return False
        AddMenuHandler(ItemName, ItemNumber, AddMenu) {
            Selection := This.MainWindow.MainTree.GetSelection()
            Parent := This.MainWindow.MainTree.GetParent(Selection)
            This.AddItem(Parent, ItemName)
        }
        EditMenuHandler(ItemName, ItemNumber, EditMenu) {
            Selection := This.MainWindow.MainTree.GetSelection()
            If ItemName = "Cut" And Selection
            This.CutItem(Selection)
            If ItemName = "Copy" And Selection
            This.CopyItem(Selection)
            If ItemName = "Paste" And Selection
            This.PasteItem(Selection)
            If ItemName = "Delete..." And Selection
            This.DeleteItem(Selection)
            If ItemName = "Properties..." And Selection
            This.EditItem(Selection)
        }
    }
    
    Static CutItem(Item) {
        If This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem"
        If This.CopyToBuffer(Item) {
            This.EditorBuffer := This.CopyToBuffer(Item)
            This.DeleteItem(Item, False)
            Return This.EditorBuffer
        }
        Return False
    }
    
    Static DeleteItem(Item, Confirmation := True) {
        This.MainWindow.Opt("+OwnDialogs")
        If Confirmation = True {
            This.MainWindow.Opt("+Disabled")
            ConfirmationDialog := MsgBox("Delete item?", This.AppName, 4)
            If ConfirmationDialog == "Yes"
            Proceed()
            This.MainWindow.Opt("-Disabled")
            This.MainWindow.MainTree.Focus()
            Return
        }
        Proceed()
        Proceed() {
            Parent := This.MainWindow.MainTree.GetParent(Item)
            ChildItems := This.GetChildItems(Parent)
            If ChildItems.Length = 1
            This.AddItem(Parent, "DummyItem")
            This.MainWindow.MainTree.Delete(Item)
            This.Items.Delete(Item)
            This.UpdateCodeField()
        }
    }
    
    Static EditItem(Item) {
        ItemType := This.Items[Item].Type
        ParamBox := GUI("+OwnDialogs +owner" . This.MainWindow.Hwnd, ItemType . " Properties")
        EditorBoxes := Map()
        EditorExpressionBoxes := Map()
        ControlIndex := 0
        For Param In This.Items[Item].EditorParams {
            ControlIndex++
            Label := Param.Name
            If Param.Optional
            Label .= " (optional)"
            Label .= ":"
            If ControlIndex = 1
            ParamBox.AddText(, Label)
            Else
            ParamBox.AddText("Section XS", Label)
            Value := Param.Value
            If Param.Expression < 2
            Value := SubStr(Value, 2, StrLen(Value) -2)
            EditorBoxes[Param.Name] := ParamBox.AddEdit("YS", Value)
            Checked := ""
            If Param.Expression > 2
            Checked := "Checked"
            EditorExpressionBoxes[Param.Name] := ParamBox.AddCheckBox("YS " . Checked, "Treat as expression")
            If Param.Expression = 2 Or Param.Expression = 4
            EditorExpressionBoxes[Param.Name].Opt("+Disabled")
        }
        ConstructorBoxes := Map()
        ConstructorExpressionBoxes := Map()
        For Param In This.Items[Item].ConstructorParams {
            ControlIndex++
            Label := Param.Name
            If Param.Optional
            Label .= " (optional)"
            Label .= ":"
            If ControlIndex = 1
            ParamBox.AddText(, Label)
            Else
            ParamBox.AddText("Section XS", Label)
            Value := Param.Value
            If Param.Expression < 2
            Value := SubStr(Value, 2, StrLen(Value) -2)
            ConstructorBoxes[Param.Name] := ParamBox.AddEdit("YS", Value)
            Checked := ""
            If Param.Expression > 2
            Checked := "Checked"
            ConstructorExpressionBoxes[Param.Name] := ParamBox.AddCheckBox("YS " . Checked, "Treat as expression")
            If Param.Expression = 2 Or Param.Expression = 4
            ConstructorExpressionBoxes[Param.Name].Opt("+Disabled")
        }
        HotkeyBoxes := Map()
        HotkeyExpressionBoxes := Map()
        For Param In This.Items[Item].HotkeyParams {
            ControlIndex++
            Label := Param.Name
            If Param.Optional
            Label .= " (optional)"
            Label .= ":"
            If ControlIndex = 1
            ParamBox.AddText(, Label)
            Else
            ParamBox.AddText("Section XS", Label)
            Value := Param.Value
            If Param.Expression < 2
            Value := SubStr(Value, 2, StrLen(Value) -2)
            HotkeyBoxes[Param.Name] := ParamBox.AddEdit("YS", Value)
            Checked := ""
            If Param.Expression > 2
            Checked := "Checked"
            HotkeyExpressionBoxes[Param.Name] := ParamBox.AddCheckBox("YS " . Checked, "Treat as expression")
            If Param.Expression = 2 Or Param.Expression = 4
            HotkeyExpressionBoxes[Param.Name].Opt("+Disabled")
        }
        ParamBox.AddButton("Section XS Default", "OK").OnEvent("Click", Save)
        ParamBox.AddButton("YS", "Cancel").OnEvent("Click", Close)
        ParamBox.OnEvent("Close", Close)
        ParamBox.OnEvent("Escape", Close)
        This.MainWindow.Opt("+Disabled")
        ParamBox.Show()
        Close(*) {
            This.MainWindow.Opt("-Disabled")
            ParamBox.Destroy()
        }
        Save(*) {
            ParamBox.Opt("+OwnDialogs")
            For Param In This.Items[Item].EditorParams {
                Result := This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, EditorBoxes[Param.Name].Value, EditorExpressionBoxes[Param.Name].Value, Param.Optional)
                If Result Is This.ParamHandler.Error {
                    ParamBox.Opt("+Disabled")
                    MsgBox Result.Message, This.AppName
                    ParamBox.Opt("-Disabled")
                    EditorBoxes[Param.Name].Focus()
                    Return
                }
            }
            For Param In This.Items[Item].ConstructorParams {
                Result := This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, ConstructorBoxes[Param.Name].Value, ConstructorExpressionBoxes[Param.Name].Value, Param.Optional)
                If Result Is This.ParamHandler.Error {
                    ParamBox.Opt("+Disabled")
                    MsgBox Result.Message, This.AppName
                    ParamBox.Opt("-Disabled")
                    ConstructorBoxes[Param.Name].Focus()
                    Return
                }
            }
            For Param In This.Items[Item].HotkeyParams {
                Result := This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, HotkeyBoxes[Param.Name].Value, HotkeyExpressionBoxes[Param.Name].Value, Param.Optional)
                If Result Is This.ParamHandler.Error {
                    ParamBox.Opt("+Disabled")
                    MsgBox Result.Message, This.AppName
                    ParamBox.Opt("-Disabled")
                    HotkeyBoxes[Param.Name].Focus()
                    Return
                }
            }
            For Index, Param In This.Items[Item].EditorParams {
                This.SetItemParam(Item, "Editor", Param.Name, This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, EditorBoxes[Param.Name].Value, EditorExpressionBoxes[Param.Name].Value, Param.Optional))
                If Param.Expression = 1 Or Param.Expression = 3 {
                    Value := 1
                    If EditorExpressionBoxes[Param.Name].Value
                    Value := 3
                    This.Items[Item].EditorParams[Index].Expression := Value
                }
            }
            For Index, Param In This.Items[Item].ConstructorParams {
                This.SetItemParam(Item, "Constructor", Param.Name, This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, ConstructorBoxes[Param.Name].Value, ConstructorExpressionBoxes[Param.Name].Value, Param.Optional))
                If Param.Expression = 1 Or Param.Expression = 3 {
                    Value := 1
                    If ConstructorExpressionBoxes[Param.Name].Value
                    Value := 3
                    This.Items[Item].ConstructorParams[Index].Expression := Value
                }
            }
            For Index, Param In This.Items[Item].HotkeyParams {
                This.SetItemParam(Item, "Hotkey", Param.Name, This.ParamHandler.Handle%ItemType%%Param.Name%(Param.Name, HotkeyBoxes[Param.Name].Value, HotkeyExpressionBoxes[Param.Name].Value, Param.Optional))
                If Param.Expression = 1 Or Param.Expression = 3 {
                    Value := 1
                    If HotkeyExpressionBoxes[Param.Name].Value
                    Value := 3
                    This.Items[Item].HotkeyParams[Index].Expression := Value
                }
            }
            This.UpdateCodeField()
            Close()
        }
    }
    
    Static GetChildItems(Item, IgnoreDummies := False) {
        ChildItems := Array()
        ChildItem := This.MainWindow.MainTree.GetChild(Item)
        While ChildItem {
            If Not IgnoreDummies
            ChildItems.Push(ChildItem)
            Else
            If This.Items.Has(ChildItem) And Not This.Items[ChildItem].Type = "DummyItem"
            ChildItems.Push(ChildItem)
            ChildItem := This.MainWindow.MainTree.GetNext(ChildItem)
        }
        Return ChildItems
    }
    
    Static GetItemParam(Item, ParamGroup, ParamName) {
        If This.Items.Has(Item) And ParamGroup And This.Items[Item].HasOwnProp(ParamGroup . "Params")
        For Index, Param In This.Items[Item].%ParamGroup%Params
        If Param.Name = ParamName
        Return Param.Value
        Return False
    }
    
    Static ItemAddHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) {
            This.ShowAddMenu()
            Return
        }
        This.TreeHKsOff()
        Send "{Enter}"
        This.TreeHKsOn()
    }
    
    Static ItemCopyHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem" {
            This.CopyItem(Item)
            Return
        }
        This.TreeHKsOff()
        Send "^C"
        This.TreeHKsOn()
    }
    
    Static ItemCutHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem" {
            This.CutItem(Item)
            Return
        }
        This.TreeHKsOff()
        Send "^X"
        This.TreeHKsOn()
    }
    
    Static ItemPasteHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) {
            This.PasteItem(Item)
            Return
        }
        This.TreeHKsOff()
        Send "^V"
        This.TreeHKsOn()
    }
    
    Static Import(*) {
        ImportBox := GUI("+OwnDialogs +owner" . This.MainWindow.Hwnd, "Import Overlay")
        ImportBox.AddText(" W396 X2 Y2", "Paste your code into the field below and press OK.")
        ImportBox.AddEdit("R4  W396 X2 Y63 vImportField")
        ImportBox.AddButton("H30 W199 X1 Y124", "OK").OnEvent("Click", Proceed)
        ImportBox.AddButton("H30 W199 X200 Y124", "Cancel").OnEvent("Click", Close)
        ImportBox.OnEvent("Close", Close)
        ImportBox.OnEvent("Escape", Close)
        This.MainWindow.Opt("+Disabled")
        ImportBox.Show()
        Close(*) {
            This.MainWindow.Opt("-Disabled")
            ImportBox.Destroy()
            This.MainWindow.MainTree.Focus()
        }
        Proceed(*) {
            ImportBox.Opt("+OwnDialogs")
            OverlayParser := This.CodeParser()
            If OverlayParser.ImportOverlay(ImportBox["ImportField"].Value)
            Close()
        }
    }
    
    Static ItemDeleteHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem" {
            This.DeleteItem(Item)
            Return
        }
        This.TreeHKsOff()
        Send "{Delete}"
        This.TreeHKsOn()
    }
    
    Static ItemEditHK() {
        Item := This.MainWindow.MainTree.GetSelection()
        If This.MainWindow.MainTree.Focused And This.Items.Has(Item) And Not This.Items[Item].Type = "DummyItem" {
            This.EditItem(Item)
            Return
        }
        This.TreeHKsOff()
        Send "{F2}"
        This.TreeHKsOn()
    }
    
    Static PasteItem(Item, Parent := False, EditorBuffer := False, Select := True) {
        If Not EditorBuffer
        EditorBuffer := This.EditorBuffer
        If Not EditorBuffer Is Map Or Not EditorBuffer.Has("RootItem")
        Return False
        If Not EditorBuffer["RootItem"].HasOwnProp("Type")
        Return False
        If Not Parent
        Parent := This.MainWindow.MainTree.GetParent(Item)
        If Parent = This.MainWindow.MainTree.OverlayRoot And Not EditorBuffer["RootItem"].Type = "AccessibilityOverlay"
        Parent := This.AddItem(Parent, "AccessibilityOverlay", False)
        If Not Parent = This.MainWindow.MainTree.OverlayRoot And This.Items[Parent].Type = "TabControl" And Not SubStr(EditorBuffer["RootItem"].Type, -3) = "Tab" And EditorBuffer["ChildItems"].Length > 0
        Parent := This.AddItem(Parent, "Tab", False)
        If Not Parent = This.MainWindow.MainTree.OverlayRoot And Not This.Items[Parent].Type = "TabControl" And Not This.Items[Parent].Type = "CodeParserTemp" And SubStr(EditorBuffer["RootItem"].Type, -3) = "Tab"
        Parent := This.AddItem(Parent, "TabControl", False)
        Proceed()
        Return True
        Proceed() {
            Item := This.AddItem(Parent, EditorBuffer["RootItem"].Type, False)
            This.Items[Item] := This.CloneObj(EditorBuffer["RootItem"])
            This.SetItemParam(Item)
            If EditorBuffer.Has("ChildItems") And EditorBuffer["ChildItems"] Is Array
            For ChildItem In EditorBuffer["ChildItems"]
            This.PasteItem(Item, Item, ChildItem, False)
            If Select
            This.MainWindow.MainTree.Modify(Item)
            This.UpdateCodeField()
            Return Item
        }
    }
    
    Static SetItemParam(Item, ParamGroup := False, ParamName := False, ParamValue := False) {
        If This.Items.Has(Item) And ParamGroup  And This.Items[Item].HasOwnProp(ParamGroup . "Params")  And ParamName
        For Index, Param In This.Items[Item].%ParamGroup%Params
        If Param.Name = ParamName {
            This.Items[Item].%ParamGroup%Params[Index].Value := ParamValue
            Break
        }
        If This.Items.Has(Item) {
            Code := This.Items[Item].Type . "("
            If This.Items[Item].HasOwnProp("ConstructorParams") {
                Added := 0
                Optional := 0
                For Param In This.Items[Item].ConstructorParams {
                    Added++
                    Code .= Param.Value . ", "
                    If Param.Optional
                    Optional++
                }
                If Added
                Code := SubStr(Code, 1, StrLen(Code) - 2)
                If Optional
                While Substr(Code, -2) = ", "
                Code := SubStr(Code, 1, StrLen(Code) -2)
            }
            Code .= ")"
            HotkeyCommand := This.GetItemParam(Item, "Hotkey", "HotkeyCommand")
            If HotkeyCommand {
                Optional := 0
                Code .= ".SetHotkey("
                For Param In This.Items[Item].HotkeyParams {
                    Code .= Param.Value . ", "
                    If Param.Optional
                    Optional++
                }
                Code := SubStr(Code, 1, StrLen(Code) - 2)
                If Optional
                While Substr(Code, -2) = ", "
                Code := SubStr(Code, 1, StrLen(Code) -2)
                Code .= ")"
            }
            This.Items[Item].Code := Code
            CustomLabel := This.GetItemParam(Item, "Editor", "CustomLabel")
            If CustomLabel
            This.MainWindow.MainTree.Modify(Item,, CustomLabel)
            Else
            This.MainWindow.MainTree.Modify(Item,, Code)
        }
    }
    
    Static Show() {
        This.MainWindow.Show()
        This.MainWindow.MainTree.Focus()
    }
    
    Static ShowAddMenu(*) {
        CreatedMenu := This.CreateMenu("Add")
        If CreatedMenu {
            This.TreeHKsOff()
            CreatedMenu.Show()
            This.TreeHKsOn()
        }
    }
    
    Static ShowEditMenu(*) {
        CreatedMenu := This.CreateMenu("Edit")
        If CreatedMenu {
            This.TreeHKsOff()
            CreatedMenu.Show()
            This.TreeHKsOn()
        }
    }
    
    Static ToggleTreeHKs(Value) {
        HotIfWinActive("Overlay Editor ahk_class AutoHotkeyGUI")
        Hotkey "^C", Value
        Hotkey "^V", Value
        Hotkey "^X", Value
        Hotkey "Delete", Value
        Hotkey "Enter", Value
        Hotkey "F2", Value
    }
    
    Static TreeHKsOff() {
        This.ToggleTreeHKs("Off")
    }
    
    Static TreeHKsOn() {
        This.ToggleTreeHKs("On")
    }
    
    Static UpdateCodeField() {
        This.CodeGenerator.Items := This.Items
        This.CodeGenerator.Tree := This.MainWindow.MainTree
        This.MainWindow.CodeField.Value := This.CodeGenerator.GenerateOverlays()
    }
    
    #Include <CodeGenerator>
    #Include <CodeParser>
    #Include <ParamHandler>
    
}
