#Requires AutoHotkey v2.0

Class CodeGenerator {
    
    Static Items := Map()
    Static ParentClass := ""
    Static Tree := ""
    
    Static __New() {
        This.ParentClass := SubStr(This.Prototype.__Class, 1, InStr(This.Prototype.__Class, ".") - 1)
    }
    
    Static GenerateOverlay(Overlay, ParentVarName := False) {
        OverlayVarName := %This.ParentClass%.GetItemParam(Overlay, "Editor", "VarName")
        If ParentVarName
        OverlayCode := OverlayVarName . " := " . ParentVarName . ".Add" . This.Items[Overlay].Code . "`n"
        Else
                OverlayCode := OverlayVarName . " := " . This.Items[Overlay].Code . "`n"
        ChildItems := %This.ParentClass%.GetChildItems(Overlay, True)
        For ChildItem In ChildItems {
            ItemType := This.Items[ChildItem].Type
            ItemVarName := %This.ParentClass%.GetItemParam(ChildItem, "Editor", "VarName")
            If ItemType = "AccessibilityOverlay" {
                OverlayCode .= This.GenerateOverlay(ChildItem, OverlayVarName)
            }
            Else If ItemType = "TabControl" {
                OverlayCode .= ItemVarName . " := " . OverlayVarName . ".Add" . This.Items[ChildItem].Code . "`n"
                        TabItems := %This.ParentClass%.GetChildItems(ChildItem, True)
                        For TabItem In TabItems {
                                            OverlayCode .= This.GenerateOverlay(TabItem)
                                            OverlayCode .= ItemVarName . ".AddTabs(" .  %This.ParentClass%.GetItemParam(TabItem, "Editor", "VarName") . ")`n"
                        }
            }
            Else {
                OverlayCode .= OverlayVarName . ".Add" . This.Items[ChildItem].Code . "`n"
            }
        }
        Return OverlayCode
    }
    
    Static GenerateOverlays() {
        OverlayCode := ""
        Overlays := %This.ParentClass%.GetChildItems(This.Tree.OverlayRoot, True)
        For Index, Overlay In Overlays {
                    If Index > 1
        OverlayCode .= "`n"
        OverlayCode .= This.GenerateOverlay(Overlay)
        }
        Return OverlayCode
    }
    
}
