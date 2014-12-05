Type TTab
	Global Tabs:TList = New TList
	Field gadgets:TList = New TList, parent:TGadget, num:Int
	Method AddGadget(gadget:TGadget) 
		gadgets.AddLast(gadget) 
	EndMethod
	Method Show() 
		For Local g:TGadget = EachIn gadgets
			ShowGadget(g) 
			EnableGadget(g) 
		Next
	End Method
	Method Hide() 
		For Local g:TGadget = EachIn gadgets
			HideGadget(g) 
			DisableGadget(g) 
		Next
	End Method
	Method New() 
		Tabs.addlast(Self) 
	End Method
	Function DoTab(par:TGadget, num:Int) 
		For Local t:TTab = EachIn Tabs
			t.Hide() 
			If t.parent = par And t.num = num
				t.Show() 
			EndIf
		Next
	End Function
	Function Create:TTab(parent:TGadget, num:Int) 
		Local n:TTab = New TTab
		n.parent = parent
		n.num = num
		return n
	End Function
EndType