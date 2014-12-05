
Global ScrollSize:Int = 16
Global TopbarSize:Int = 40
?linux
Global gMainWindow:TGadget = CreateWindow("Mines", 40, 40, 270, 320, Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_CLIENTCOORDS)
?Not linux
Global gMainWindow:TGadget = CreateWindow("Mines", 40, 40, 270, 320, Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_HIDDEN| WINDOW_CLIENTCOORDS)
?
SetMinWindowSize(gMainWindow, 250, 270)

If Not gMainWindow End

Global gOptionWindow:TGadget = CreateWindow("Options", 50, 50, 260, 320, gMainWindow, WINDOW_TITLEBAR | WINDOW_HIDDEN) 
Global gOptionWrap:TGadget = CreateButton("Wrap Minefield", 30, 140, 14, 14, gOptionWindow, BUTTON_CHECKBOX) 
Global gOptionWrapTag:TGadget = CreateLabel("Wrap Minefield", 44, 140, 100, 20, gOptionWindow) 
Global gOptionSound:TGadget = CreateButton("Sound", 30, 160, 14, 14, gOptionWindow, BUTTON_CHECKBOX)
Global gOptionSoundTag:TGadget = CreateLabel("Sound", 44, 160, 100, 20, gOptionWindow)
Global gOptionBombL:TGadget = CreateButton("LBombs", 30, 180, 14, 14, gOptionWindow, BUTTON_CHECKBOX) 
Global gOptionBombLTag:TGadget = CreateLabel("Lethal Bombs", 44, 180, 100, 20, gOptionWindow) 
Global gOptionPan:TGadget = CreateButton("Pan", 30, 200, 14, 14, gOptionWindow, BUTTON_CHECKBOX) 
Global gOptionPanTag:TGadget = CreateLabel("Allow Pan", 44, 200, 100, 20, gOptionWindow) 
Global gOptionInvert:TGadget = CreateButton("Invert Arrows", 30, 220, 14, 14, gOptionWindow, BUTTON_CHECKBOX) 
Global gOptionInvertTag:TGadget = CreateLabel("Invert Arrows", 44, 220, 100, 20, gOptionWindow) 

Global gOptionWidth:TGadget = CreateNumberField(100, 30, 120, 22, gOptionWindow) 
Global gOptionWidthTag:TGadget = CreateLabel("Width:", 30, 30, 70, 20, gOptionWindow) 
Global gOptionHeight:TGadget = CreateNumberField(100, 60, 120, 22, gOptionWindow) 
Global gOptionHeightTag:TGadget = CreateLabel("Height:", 30, 60, 70, 20, gOptionWindow) 
Global gOptionMines:TGadget = CreateNumberField(100, 90, 120, 22, gOptionWindow) 
Global gOptionMinesTag:TGadget = CreateLabel("Mines:", 30, 90, 70, 20, gOptionWindow) 
Global gOptionOK:TGadget = CreateButton("Ok", 60, 250, 80, 30, gOptionWindow, BUTTON_OK)
Global gOptionCancel:TGadget = CreateButton("Cancel", 155, 250, 80, 30, gOptionWindow, BUTTON_PUSH | BUTTON_CANCEL)

Global gMultiWindow:TGadget = CreateWindow("Mines Multiplayer", 400, 60, 350, 290, gMainWindow, WINDOW_TITLEBAR | WINDOW_HIDDEN | WINDOW_RESIZABLE | WINDOW_STATUS) 
SetStatusText(gMultiWindow, "Not connected") 
SetMinWindowSize(gMultiWindow, 350, 290) 

Global gMultiTabber:TGadget = CreateTabber(0, 0, gMultiWindow.ClientWidth(), gMultiWindow.ClientHeight(), gMultiWindow) 
gMultiTabber.SetLayout(1, 1, 1, 1) 
AddGadgetItem(gMultiTabber, "Settings") 
AddGadgetItem(gMultiTabber, "Direct Connect") 
AddGadgetItem(gMultiTabber, "Server list") 
AddGadgetItem(gMultiTabber, "Chat / Console") 
Global TabSettings:TTab = TTab.Create(gMultiTabber, 0) 
Global gSettingsColor:TGadget = CreateButton("Colour", 70, 40, 80, 30, gMultiTabber) 
Global gSettingsColbox:TGadget = CreatePanel(200, 40, 40, 40, gMultiTabber) 
Global gSettingsName:TGadget = CreateTextField(100, 15, 120, 22, gMultiTabber) 
Global gSettingsNameTag:TGadget = CreateLabel("Name:", 30, 15, 70, 20, gMultiTabber) 
SetPanelColor(gSettingsColbox, color[0] , color[1] , color[2] ) 

TabSettings.AddGadget(gSettingsColor) 
TabSettings.AddGadget(gSettingsColbox) 
TabSettings.AddGadget(gSettingsName) 
TabSettings.AddGadget(gSettingsNameTag) 
Global TabDirect:TTab = TTab.Create(gMultiTabber, 1) 
Global gDirectIP:TGadget = CreateTextField(70, 30, 200, 22, gMultiTabber) 
Global gDirectIPTag:TGadget = CreateLabel("Server IP", 8, 30, 60, 30, gMultiTabber) 
Global gDirectPort:TGadget = CreateNumberField(70, 60, 200, 22, gMultiTabber, 1) 
Global gDirectPortTag:TGadget = CreateLabel("Server Port", 8, 60, 60, 40, gMultiTabber) 

Global gDirectConnect:TGadget = CreateButton("Connect", 10, 100, 80, 30, gMultiTabber)
Global gDirectHost:TGadget = CreateButton("Host", 100, 100, 80, 30, gMultiTabber)
Global gDisconnect:TGadget = CreateButton("Disconnect", 190, 100, 80, 30, gMultiTabber)
TabDirect.AddGadget(gDirectIP) 
TabDirect.AddGadget(gDirectPort) 
TabDirect.AddGadget(gDirectConnect)
TabDirect.AddGadget(gDisconnect) 
TabDirect.AddGadget(gDirectHost) 
TabDirect.AddGadget(gDirectIPTag) 
TabDirect.AddGadget(gDirectPortTag) 

Global TabServers:TTab = TTab.Create(gMultiTabber, 2)
Global gServerList:TGadget = CreateListBox(0, 0, gMultiTabber.ClientWidth(), gMultiTabber.ClientHeight() - 60, gMultiTabber)
gServerList.SetLayout(1, 1, 1, 1)
Global gServerRefresh:TGadget = CreateButton("Refresh", 10, gMultiTabber.ClientHeight() - 40, 80, 30, gMultiTabber)
gServerRefresh.SetLayout(1, 0, 0, 1)
Global gServerJoin:TGadget = CreateButton("Join", 100, gMultiTabber.ClientHeight() - 40, 80, 30, gMultiTabber)
gServerJoin.SetLayout(1, 0, 0, 1)
Global gServerHost:TGadget = CreateButton("Host + broadcast", 190, gMultiTabber.ClientHeight() - 40, 120, 30, gMultiTabber)
gServerJoin.SetLayout(1, 0, 0, 1)
TabServers.AddGadget(gServerList)
TabServers.AddGadget(gServerRefresh)
TabServers.AddGadget(gServerJoin)
TabServers.AddGadget(gServerHost)

Global TabChat:TTab = TTab.Create(gMultiTabber, 3) 
Global gChatConsole:TGadget = CreateTextArea(0, 0, gMultiTabber.ClientWidth() - 100, gMultiTabber.ClientHeight() - 25, gMultiTabber, TEXTAREA_READONLY) 
gChatConsole.SetLayout(1, 1, 1, 1) 
Global gChatInp:TGadget = CreateTextField(0, gMultiTabber.ClientHeight() - 24, gMultiTabber.ClientWidth() - 60, 24, gMultiTabber)
gChatInp.SetLayout(1, 1, 0, 1)
Global gChatSend:TGadget = CreateButton("Send", gMultiTabber.ClientWidth() - 60, gMultiTabber.ClientHeight() - 24, 60, 24, gMultiTabber, BUTTON_OK)
gChatSend.SetLayout(0, 1, 0, 1) 
Global gChatPList:TGadget = CreateListBox(gMultiTabber.ClientWidth() - 100, 0, 100, gMultiTabber.ClientHeight() - 25, gMultiTabber) 
gChatPList.SetLayout(0, 1, 1, 1) 

Global menu_player:TGadget = CreateMenu("Player", 0, Null) 
Global menu_player_slap:TGadget = CreateMenu("Slap!", 1, menu_player)
Global menu_player_kick:TGadget = CreateMenu("Kick", 2, menu_player)


TabChat.AddGadget(gChatConsole) 
TabChat.AddGadget(gChatInp) 
TabChat.AddGadget(gChatSend) 
TabChat.AddGadget(gChatPList) 
DisableGadget(gChatConsole) 
TTab.DoTab(gMultiTabber, 0) 

Global gAboutWindow:TGadget = CreateWindow("About", 100, 100, 200, 100, gMainWindow, WINDOW_HIDDEN | WINDOW_TITLEBAR | WINDOW_TOOL) 
Global gAboutText:TGadget = CreateLabel("Made by Spacerat :D", 10, 10, 90, 30, gAboutWindow) 

SetButtonState(gOptionInvert, oInverted) 
SetButtonState(gOptionBombL, oBombLose) 
SetButtonState(gOptionPan, oPan) 
SetButtonState(gOptionSound, oSound) 
SetButtonState(gOptionWrap, oWrap) 
SetGadgetText(gOptionWidth, oWidth) 
SetGadgetText(gOptionHeight, oHeight) 
SetGadgetText(gOptionMines, oMines) 
SetGadgetText(gSettingsName, oName) 
SetGadgetText(gDirectIP, oIP) 
SetGadgetText(gDirectPort, String(oPort)) 

Global gWinWindow:TGadget = CreateWindow("Congratulations", 100, 100, 200, 100, gMainWindow, WINDOW_HIDDEN | WINDOW_TITLEBAR) 
Global gWinText:TGadget = CreateLabel("You have won!", 40, 10, 90, 15, gWinWindow) 
Global gWinTextTime:TGadget = CreateLabel("Time Taken: ", 40, 30, 150, 15, gWinWindow) 
'SetGadgetShape(gMainWindow, gMainWindow.xpos, gMainWindow.ypos, GAMESIZEW + (gMainWindow.width - gMainWindow.ClientWidth()), GAMESIZEH + (gMainWindow.height - gMainWindow.ClientHeight())) 
'Global WindowDefWidth:Int = gMainWindow.width, WindowDefHeight:Int = gMainWindow.height

'Global gMainPanel:TGadget = CreatePanel(0, 0, gMainWindow.ClientWidth(), TopbarSize, gMainWindow, PANEL_BORDER | PANEL_GROUP)
'gMainPanel.SetLayout(1, 1, 1, 0)
Global gCan:TGadget = CreateCanvas(0, TopbarSize, gMainWindow.ClientWidth() - ScrollSize, gMainWindow.ClientHeight() - TopbarSize - ScrollSize, gMainWindow, 0)
'Global gCan:TGadget = CreateCanvas(0, 0, gMainWindow.ClientWidth(), TopbarSize, gMainWindow)
gCan.SetLayout(1, 1, 1, 1)
'gCan.SetLayout(1, 1, 1, 0)
Global gCanScore:TGadget = CreateCanvas(0, 0, gMainWindow.ClientWidth(), TopbarSize, gMainWindow)
'Global gCanScore:TGadget = gCan
gCanScore.SetLayout(1, 1, 1, 0)
Global gHScroll:TGadget = CreateSlider(0, gMainWindow.ClientHeight() - ScrollSize, gMainWindow.ClientWidth() - ScrollSize, ScrollSize, gMainWindow, SLIDER_HORIZONTAL | SLIDER_SCROLLBAR)
gHScroll.SetLayout(1, 1, 0, 1)
Global gVScroll:TGadget = CreateSlider(gMainWindow.ClientWidth() - ScrollSize, TopbarSize, ScrollSize, gMainWindow.ClientHeight() - ScrollSize - TopbarSize, gMainWindow, SLIDER_VERTICAL | SLIDER_SCROLLBAR)
gVScroll.SetLayout(0, 1, 1, 1)

Global menu_game:TGadget = CreateMenu("Game", 0, WindowMenu(gMainWindow))
	Global menu_game_new:TGadget = CreateMenu("New Game", 0, menu_game, KEY_F2) 
	Global menu_game_ratio:TGadget = CreateMenu("Reset Window Ratio", 1, menu_game, KEY_F5) 
	Global menu_game_options:TGadget = CreateMenu("Options", 2, menu_game, KEY_F6) 
	Global menu_game_theme:TGadget = CreateMenu("Change Background", 2, menu_game, KEY_F7)
	Global menu_game_exit:TGadget = CreateMenu("Exit", 3, menu_game) 
Global menu_help:TGadget = CreateMenu("Help", 1, WindowMenu(gMainWindow))
	Global menu_help_about:TGadget = CreateMenu("About", 0, menu_help, KEY_F1) 
Global menu_multiplayer_parent:TGadget = CreateMenu("Multiplayer", 2, WindowMenu(gMainWindow))
	Global menu_multiplayer:TGadget = CreateMenu("Open Multiplayer Window", 2, menu_multiplayer_parent)


Function CreateNumberField:TGadget(x:Int, y:Int, w:Int, h:Int, group:TGadget, IntOnly:Byte = 1)
	Local g:TGadget=CreateTextField(x,y,w,h,group)
	If IntOnly = 1 SetGadgetFilter g, IntFilter
	If IntOnly = 0 SetGadgetFilter g, FloatFilter
	Return g
End Function

Function NumberFieldNumber:Float(numberfield:TGadget) 
	Return Float(TextFieldText(numberfield)) 
End Function

Function IntFilter:Int(event:TEvent, context:Object) 
	If Event.ID=EVENT_KEYCHAR
		If (event.data > 47 And event.data < 58) Or event.data = KEY_BACKSPACE Then Return True Else Return False
	EndIf
	Return True
End Function
Function FloatFilter:Int(event:TEvent, context:Object) 
	If Event.ID=EVENT_KEYCHAR
		If (event.data > 47 And event.data < 58) Or event.data = KEY_BACKSPACE Or event.data = KEY_PERIOD Then Return True Else Return False
	EndIf
	Return True
End Function