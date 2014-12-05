


SuperStrict

Framework brl.blitz
Import maxgui.drivers
?win32
Import brl.d3d9max2d
?Not win32
Import brl.glmax2d
?
Import pub.opengl
Import brl.keycodes
Import brl.eventqueue
Import brl.timer
Import brl.ramstream
Import brl.pngloader
Import brl.jpgloader
'Import bah.random
Import brl.random
'Import bah.fontconfig
Import brl.bankstream
Import brl.socket
Import brl.audio
Import brl.wavloader
Import brl.freeaudioaudio
Import brl.font
Import brl.freetypefont
Import pub.freetype
'import brl.directsoundaudio

?debug
Import brl.socketstream
?


Include "iniloader.bmx"
Include "settings.bmx"
Include "types/SImage.bmx"
Include "types/blocks.bmx"
Include "types/tab.bmx"
Include "net.bmx"
Include "netmgrs.bmx"
Include "colour.bmx"

'global 


'Include "highgraphics.bmx"
Include "lowgraphics.bmx"

If Not AudioDriverExists("FreeAudio Directsound") 
	SetAudioDriver(AudioDrivers()[0])
Else
	SetAudioDriver("FreeAudio Directsound")
EndIf

Global channel:TChannel = AllocChannel() 

Global color:Byte[3] 
color[0] = Rand(0, 255) 
color[1] = Rand(0, 255) 
color[2] = Rand(0, 255) 
Global winr:Float

Include "guiinit.bmx"

Global gtime:Int = 0
Global wtime:Int = 0

Global firstgame:Byte = 1
Global GameStatus:Byte = 0

Global BombLose:Byte = 0

Global DeltaTime:Float = 0.001
Global GameTime:Float = 0

Global DEFWIDTH:Float = 270, DEFHEIGHT:Float = 320

	Global SCALEX:Float = 1, SCALEY:Float = 1, OriginX:Float = 0, OriginY:Float = 0
	Global BACKSCALEX:Float = 1, BACKSCALEY:Float = 1
'	SetViewport 0, 0, GadgetWidth(gCan), GadgetHeight(gCan)
	SCALEX = gMainWindow.ClientWidth() / DEFWIDTH
	SCALEY = gMainWindow.ClientHeight() / DEFHEIGHT
	BACKSCALEX = SCALEX
	BACKSCALEY = SCALEY
Global gMouseX:Float = 0, gMouseY:Float = 0
SeedRnd(MilliSecs()) 
Global backalpha:Float[3] 
backalpha[0] = Rnd(0, 1) 
backalpha[1] = Rnd(0, 1) 
backalpha[2] = Rnd(0, 1) 
Global backalphainc:Int[] =[Rand(0, 1), Rand(0, 1), Rand(0, 1)] 
Global backcol:Int[] =[Rand(1, 3), Rand(1, 3), Rand(1, 3)] 
Global backimg:TSImage[] =[IBack1, IBack2, IBack3] 
Global backtype:Byte = 1
Global ChatOKTimer:Int = 0

CreateTimer(70) 
AddHook EmitEventHook, Hook

Global ending:Byte = 0
'UpdateWindowMenu gMainWindow
'SetGraphics(CanvasGraphics(gCan)) 
'SetViewport 0, 0, GadgetWidth(gCan), GadgetHeight(gCan)
'SetClsColor(255, 255, 255) 
'Cls
'Flip


StartGame(oWidth, oHeight, oMines) 
ShowGadget(gMainWindow) 
While Not ending
  WaitSystem
Wend

Function Hook:Object (id:Int, data:Object, context:Object)
	Local Event:TEvent = TEvent (data)
'	If event.source <> gCan And event.id <> EVENT_TIMERTICK Print(event.id + "    " + (TGadget(event.source) = gChatInp))
	Select Event.id
		Case 8200
			Select event.source
				Case gChatInp
					If MilliSecs() - ChatOKTimer < 500 ActivateGadget(gChatInp)
			End Select
		Case EVENT_WINDOWCLOSE
			Select event.source
				Case gMainWindow End
				Case gOptionWindow
					HideGadget(gOptionWindow) 
					EnableGadget(gMainWindow) 
					EnableGadget(gCan) 
					ActivateGadget(gCan) 
				Case gAboutWindow
					HideGadget(gAboutWindow) 
					EnableGadget(gMainWindow) 
					EnableGadget(gCan) 
					ActivateGadget(gCan) 
				Case gWinWindow
					HideGadget(gWinWindow) 
					EnableGadget(gMainWindow) 
					EnableGadget(gCan) 
					ActivateGadget(gCan) 
				Case gMultiWindow
					HideGadget(gMultiWindow) 
					ActivateGadget(gCan) 
			End Select
		Case EVENT_APPTERMINATE End
		Case EVENT_MENUACTION
			Select event.source
				Case menu_player_kick
					If TNet.NetStatus = 2
						KickID(SelectedGadgetItem(gChatPList)) 
					End If
				Case menu_game_exit
					End
				Case menu_game_ratio
				'	Local r:Float = DEFWIDTH / DEFHEIGHT
					WindowSetToRatio() 
					ActivateGadget(gCan) 
				Case menu_game_theme
					backtype = backtype + 1
					If backtype > 2 backtype = 0
					ActivateGadget(gCan) 
				Case menu_game_new
					If TNet.NetStatus = 0 StartGame(oWidth, oHeight, oMines) 
					If TNet.NetStatus = 2 SendGame(oWidth, oHeight, oMines)
					firstgame = 0
					ActivateGadget(gCan) 
				Case menu_game_options
					ShowGadget(gOptionWindow) 
					DisableGadget(gMainWindow) 
					DisableGadget(gCan) 
					ActivateGadget(gOptionWindow) 
				Case menu_help_about
					ShowGadget(gAboutWindow) 
					DisableGadget(gMainWindow) 
					DisableGadget(gCan) 
					ActivateGadget(gAboutWindow) 
				Case menu_multiplayer
					If GadgetHidden(gMultiWindow) ShowGadget(gMultiWindow) Else HideGadget(gMultiWindow) 
			EndSelect
		Case EVENT_TIMERTICK
			RedrawGadget gCan
			RedrawGadget gCanScore
			
			If TNet.NetStatus = 2 NetServer() 
			If TNet.NetStatus > 0 NetClient()
			TServerList.NetRecv()
			
			Update() 
		Case EVENT_GADGETPAINT
			
			Select event.source
				Case gCan
					EnableGadget(gCan) 
					ActivateGadget(gCan) 

					SetGraphics(CanvasGraphics(gCan))
					SetViewport 0, 0, GadgetWidth(gCan), GadgetHeight(gCan)
					Draw()
				Case gCanScore
					SetGraphics(CanvasGraphics(gCanScore))
					SetViewport 0, 0, GadgetWidth(gCanScore), GadgetHeight(gCanScore)
					DrawScore()
			End Select

		Case EVENT_WINDOWSIZE
			SetViewport 0, 0, GadgetWidth(gCan), GadgetHeight(gCan)
			SCALEX = Max(GadgetWidth(gCan) / DEFWIDTH, 0.6)
			SCALEY = Max(GadgetHeight(gCan) / DEFHEIGHT, 0.6)
			BACKSCALEX = SCALEX
			BACKSCALEY = SCALEY
			SCALEX = Min(SCALEX, SCALEY)
			SCALEY = Min(SCALEY, SCALEX)
			SetSliderRange(gHScroll, GadgetWidth(gCan), DEFWIDTH * SCALEX)
			SetSliderRange(gVScroll, GadgetHeight(gCan), DEFHEIGHT * SCALEY)
			OriginX = -SliderValue(gHScroll)
			OriginY = -SliderValue(gVScroll)
		'	SetSliderValue(gHScroll, DEFWIDTH * SCALEX + GadgetWidth(gCan))
		'	SetSliderValue(gHScroll, GadgetWidth(gCan))
		'	SetSliderValue(
		'	WSX = GadgetWidth(gMainWindow) / WDX

		Case EVENT_GADGETMENU
			If event.source = gChatPList
				PopupWindowMenu(gMultiWindow, menu_player) 
				Select TNet.NetStatus
					Case 0
						DisableGadget(menu_player) 
						DisableGadget(menu_player_slap) 
						DisableGadget(menu_player_kick) 
					Case 1
						EnableGadget(menu_player) 
						EnableGadget(menu_player_slap) 
						DisableGadget(menu_player_kick) 
					Case 2
						EnableGadget(menu_player) 
						EnableGadget(menu_player_slap) 
						EnableGadget(menu_player_kick) 
				End Select
			End If
		Case EVENT_GADGETACTION
			Select event.source
				Case gHScroll
					OriginX = -event.data
				Case gVScroll
					OriginY = -event.data
				Case gServerRefresh
					TServerList.Refresh()
				Case gServerJoin
					If SelectedGadgetItem(gServerList) <> - 1
						Local ga:TGame = TGame(GadgetItemExtra(gServerList, SelectedGadgetItem(gServerList)))
						If ga <> Null Connect(HostIp(ga.ip), ga.PORT)
					End If
				Case gServerList
					Local ga:TGame = TGame(event.extra)
					If ga <> Null Connect(HostIp(ga.ip), ga.PORT)
				Case gChatSend
					If TextFieldText(gChatInp) <> ""
						TNet.MNew(MES_CHAT) 
						TNet.MLine(TextFieldText(gChatInp)) 
						TNet.MSend(TNet.Clientsock) 
						TNet.MClear()
						'DisableGadget(gChatSend)
						SetGadgetText(gChatInp, "")
						ActivateGadget(gChatInp)
						ChatOKTimer = MilliSecs()
					End If
				Case gSettingsColor
					RequestColor(color[0] , color[1] , color[2] ) 
					'If RequestedRed() + RequestedGreen() + RequestedBlue() > 50 And RequestedRed() + RequestedGreen() + RequestedBlue() < 665
						color[0] = RequestedRed() 
						color[1] = RequestedGreen() 
						color[2] = RequestedBlue() 
						SetPanelColor(gSettingsColbox, color[0] , color[1] , color[2] ) 
				'	EndIf
					If MPlayer <> Null
						TNet.MNew(MES_SETCOLOR)
						Sendcolor(color)
						TNet.MSend(TNet.Clientsock)
						TNet.MClear()
					End If

				Case gOptionOK
					Local w:Int = NumberFieldNumber(gOptionWidth)
					Local h:Int = NumberFieldNumber(gOptionHeight)
					Local m:Int = NumberFieldNumber(gOptionMines) 
					Local i:Byte = ButtonState(gOptionInvert) 
					Local b:Byte = ButtonState(gOptionBombL) 
					Local p:Byte = ButtonState(gOptionPan) 
					If m < (w * h) - 12
						oWidth = w
						oHeight = h
						oMines = m
						oInverted = i
						oBombLose = b
						oPan = p
						oWrap = ButtonState(gOptionWrap) 
						HideGadget(gOptionWindow) 
						EnableGadget(gMainWindow) 
						EnableGadget(gCan) 
						ActivateGadget(gCan) 
						
						ini.SetSectionValue("settings", "Bombkill", oBombLose) 
						ini.SetSectionValue("settings", "Sound", oSound)
						ini.SetSectionValue("minefield", "Height", oHeight)
						ini.SetSectionValue("settings", "InvertArrows", oInverted) 
						ini.SetSectionValue("minefield", "Mines", oMines)
						ini.SetSectionValue("settings", "Pan", oPan) 
						ini.SetSectionValue("minefield", "Width", oWidth)
						ini.SetSectionValue("minefield", "Wrap", oWrap)
						ini.Save(1) 
					Else

					EndIf
				Case gOptionSound
					oSound = ButtonState(gOptionSound)
				Case gOptionCancel
						HideGadget(gOptionWindow) 
						EnableGadget(gMainWindow) 
						EnableGadget(gCan) 
						ActivateGadget(gCan) 
				Case gSettingsName
					oName = TextFieldText(gSettingsName) 
					ini.SetSectionValue("network", "Name", oName) 
					ini.Save(1) 
				Case gMultiTabber
					TTab.DoTab(gMultiTabber, event.data) 
				Case gDirectConnect
					Connect(HostIp(TextFieldText(gDirectIP)), NumberFieldNumber(gDirectPort))
				Case gServerHost
					Host(1)
				Case gDirectHost
					Host(0)
				Case gDisconnect
					TNet.Disconnect()
					TServerList.ClearList()
					If TServerList.Sock <> Null TServerList.Sock.Close()
					SetStatusText(gMultiWindow, "Not connected")
			End Select
		Case EVENT_WINDOWACTIVATE
			If event.source = gMainWindow
				ActivateGadget(gCan) 
			End If
		Case EVENT_MOUSEMOVE
			If event.source = gCan
				gMouseX = event.x - OriginX
				gMouseY = event.y - OriginY
			EndIf
		Case EVENT_MOUSEUP
			If event.source = gCan
				If event.data = MOUSE_LEFT
					If BlockMDown = 1 And MouseBlock <> Null
						If TNet.NetStatus = 0 ClickBlock(MouseBlock, MOUSE_LEFT) Else SendClick(MouseBlock, MOUSE_LEFT) 
					End If
					BlockMDown = 0
				EndIf
				If event.data = MOUSE_RIGHT
					If MouseBlock <> Null If MouseBlock.Revealed = 0
						If TNet.NetStatus = 0 ClickBlock(MouseBlock, MOUSE_RIGHT) Else SendClick(MouseBlock, MOUSE_RIGHT) 
					EndIf
				End If
			End If
		Case EVENT_MOUSEDOWN
			If event.source = gCan
				If event.data = MOUSE_LEFT
					If MouseBlock <> Null BlockMDown = 1
				EndIf
			End If
		Case EVENT_KEYDOWN
		'	print event.ToString()
			If oPan = 1 And Wrapping = 1
				Select event.data
					Case KEY_LEFT
						If oInverted = 0 TBlock.MoveBlocks(- 1, 0) Else TBlock.MoveBlocks(1, 0) 
					Case KEY_RIGHT
						If oInverted = 0 TBlock.MoveBlocks(1, 0) Else TBlock.MoveBlocks(- 1, 0) 
					Case KEY_UP
						If oInverted = 0 TBlock.MoveBlocks(0, - 1) Else TBlock.MoveBlocks(0, 1) 
					Case KEY_DOWN
						If oInverted = 0 TBlock.MoveBlocks(0, 1) Else TBlock.MoveBlocks(0, - 1) 
				End Select
			EndIf
	End Select
	Return data
EndFunction

Function Host:Int(br:Int = 0)
	TNet.disconnect()
	If br = 0
		TServerList.ClearList()
		If TServerList.Sock <> Null TServerList.Sock.Close()
	EndIf
	SetStatusText(gMultiWindow, "Attempting to host...") 
	Select TNet.Host(NumberFieldNumber(gDirectPort)) 
		Case 0
			SetStatusText(gMultiWindow, "Failed to host") 
		Case 1
			SetStatusText(gMultiWindow, "Hosting") 
			SendGame(oWidth, oHeight, oMines) 
			SendConnect()
			If br
				TServerList.Refresh()
				TServerList.Host(oName, NumberFieldNumber(gDirectPort))
			End If
			SelectGadgetItem(gMultiTabber, 3)
			TTab.DoTab(gMultiTabber, 3) 
			TNet.NetStatus = 2
	EndSelect
End Function
Function Connect:Int(ip:Int, port:Int)
	TNet.Disconnect()
	SetStatusText(gMultiWindow, "Connecting...")
	Local c:Byte = TNet.Connect(ip, PORT)
	If c = Null
		SetStatusText(gMultiWindow, "Failed to connect")
		Return 0
	Else
		SetStatusText(gMultiWindow, "Connected to game") 
		TNet.NetStatus = 1
		SendConnect() 
		SelectGadgetItem(gMultiTabber, 3) 
		TTab.DoTab(gMultiTabber, 3) 
		Return 1
	EndIf
End Function

Function Update()
	MouseBlock = Null
	Delta.Update()
	If GameStatus < 2 GameTime:+Delta.time
	TBlock.UpdateBlocks() 
End Function

Function SendConnect()
	TNet.MNew(MES_CONNECT) 
	TNet.MLine(oName) 
	Sendcolor(color) 
	TNet.MSend(TNet.Clientsock) 
	TNet.MClear() 
'	CPrint TNet.Clientsock.RemoteIp() 
End Function



Function ClickBlock(bl:TBlock, mb:Byte, p:TPlayer = Null)
	If p <> Null
		If p.out = 1 Return
	End If
	Select mb
		Case MOUSE_LEFT
			Local enemyflag:Int = 0
			If p <> Null enemyflag = (bl.fpid <> p.id)
			
			If TBlock.NumRevealed() = 0 And (bl.flag = 0 Or enemyflag = 1)
				If TNet.NetStatus > 0 MakeMines(bl.x, bl.y, Mines, rseed) Else MakeMines(bl.x, bl.y, Mines) 
			EndIf
			
			If ((bl.flag = 0) Or (bl.flag = 1 And enemyflag))' And GameStatus = 0
	
				If bl.Revealed = 0 And bl.Value = -1 And BombLose = 1
					bl.Reveal(p, (p = Null))
					If p <> Null p.out = 1
					Local fail:Int = 1
					For Local pl:TPlayer = EachIn Players
						If pl.out = 0 fail = 0
					Next
					If fail
						For Local b:TBlock = EachIn Blocks
							b.Reveal(Null) 
						Next
						If oSound = 1 PlaySound(SExplosion)
						GameStatus = 2
						If p <> Null MPWin()
					EndIf
				ElseIf bl.revealed = 0
					bl.Reveal(p, (p = Null))
					Local won:Byte = 1
					For Local b:TBlock = EachIn Blocks
						If b.Revealed = 0 And b.Value > - 1
							won = 0
							Exit
						EndIf
					Next
					If won = 1' And bl.Revealed = 0
						GameStatus = 2
						For Local b:TBlock = EachIn Blocks
							b.Reveal(Null, 0, bl)
						Next
						If wtime = 0 wtime = Int(Floor(MilliSecs() / 1000 - gtime / 1000))
						If p = Null SPWin() Else MPWin()
					End If
				EndIf
			EndIf
		
		Case MOUSE_RIGHT
			If p = Null bl.ToggleFlag(p)
			If p <> Null
				If bl.flag = 0 Or bl.fpid = p.id bl.ToggleFlag(p)
			End If
	End Select

End Function

Function MPWin()
	If GameStatus = 0 Return
	For Local pl:TPlayer = EachIn Players
		pl.FindScore()
	Next
	wtime = Int(Floor(GameTime))
	SetGadgetText(gWinTextTime, "Time Taken: " + wtime + " secs.")
	Local t:String = ""
	Local sorted:TList = Players.Copy()
	sorted.Sort(False, compareScore)
	CPrint("----------")
	CPrint("  Scores  ")
	For Local pl:TPlayer = EachIn sorted
		CPrint(pl.name + " scored: " + pl.score)
	Next
	SetGadgetText(gWinText, TPlayer(sorted.First()).name + " has won!")
	SetGadgetShape(gWinWindow, gMainWindow.xpos + 30, gMainWindow.ypos + 30, gWinWindow.width, gWinWindow.Height)
	ShowGadget(gWinWindow)
	DisableGadget(gMainWindow) 
	DisableGadget(gCan) 
	ActivateGadget(gWinWindow)
End Function

Function SPWin()
	If GameStatus = 0 Return
	wtime = Int(Floor(GameTime))
	SetGadgetShape(gWinWindow, gMainWindow.xpos + 30, gMainWindow.ypos + 30, gWinWindow.width, gWinWindow.Height)
	SetGadgetText(gWinText, "You have won!")
	SetGadgetText(gWinTextTime, "Time Taken: " + wtime + " secs.")
	ShowGadget(gWinWindow)
	DisableGadget(gMainWindow) 
	DisableGadget(gCan) 
	ActivateGadget(gWinWindow)
End Function

Function SendClick(bl:TBlock, mb:Byte) 
	If bl <> Null' And MPlayer <> Null
		If mb = MOUSE_LEFT 'And bl.flag = 0
			TNet.MNew(MES_CLICK) 
			TNet.MInt(bl.id) 
			TNet.MByte(mb) 
			TNet.MSend(TNet.Clientsock) 
			TNet.MClear() 
		EndIf
		If mb = MOUSE_RIGHT And bl.Revealed = 0
			TNet.MNew(MES_CLICK) 
			TNet.MInt(bl.id) 
			TNet.MByte(mb) 
			TNet.MSend(TNet.clientsock) 
			TNet.MClear() 
		End If
	'	CPrint TNet.Clientsock.RemoteIp() 
	EndIf
End Function
Function WindowSetToRatio(width:Float = -1)
	
	Local maxwidth:Int = Desktop().width - (gMainWindow.width - gCan.width)
	width = Min(width, maxwidth)
	Local maxheight:Int = Desktop().height - Desktop().height / 16 - (gMainWindow.height - gCan.height) + TopbarSize
	
	Local w:Int = width + (gMainWindow.width - gCan.width)
	
	If width > - 1
		SetGadgetShape(gMainWindow, gMainWindow.xpos, gMainWindow.ypos, Min(w, maxwidth), Min((w / winr) + TopbarSize, maxheight))
	Else
		SetGadgetShape(gMainWindow, gMainWindow.xpos, gMainWindow.ypos, Min(gMainWindow.width, maxwidth), Min((gMainWindow.width / winr) + TopbarSize, maxheight))
	EndIf
	
	SCALEX = Max(GadgetWidth(gCan) / DEFWIDTH, 0.6)
	SCALEY = Max(GadgetHeight(gCan) / DEFHEIGHT, 0.6)
	BACKSCALEX = SCALEX
	BACKSCALEY = SCALEY
	SCALEX = Min(SCALEX, SCALEY)
	SCALEY = Min(SCALEY, SCALEX)
	SetSliderRange(gHScroll, GadgetWidth(gCan), DEFWIDTH * SCALEX)
	SetSliderRange(gVScroll, GadgetHeight(gCan), DEFHEIGHT * SCALEY)
	OriginX = -SliderValue(gHScroll)
	OriginY = -SliderValue(gVScroll)	
	
End Function
Function Draw()
	SetScale(1, 1)

	If GameTime < 1.5 And firstgame = 1
		Cls
		DrawBackground(backtype, GameTime)
		SetColor 255,255,255
		TBlock.DrawBlocks() 
		SetBlend(LIGHTBLEND) 
		SetAlpha(1 - GameTime / 1.5) 
		SetColor(255, 255, 255) 
		DrawRect(0, 0, GadgetWidth(gCan), GadgetHeight(gCan)) 
		
	Else
		Cls
		DrawBackground(backtype, 1) 
		SetColor(255, 255, 255) 
		TBlock.DrawBlocks() 
		SetScale(1, 1) 
		SetColor 0, 255, 0
		SetBlend(ALPHABLEND) 
		SetAlpha(1) 		
	EndIf
	
	Flip
End Function

Function DrawBackground(t:Byte = 0, a:Float = 1) 
	SetScale(1, 1) 
	If t = 0
		For Local n:Int = 0 To 2
			If n = 0 SetBlend(SOLIDBLEND) Else SetBlend(LIGHTBLEND) 
		'	SetBlend(LIGHTBLEND) 
			If backalpha[n] > 1
				If n = 0
					Select Rand(1, 3) 
						Case 1 SetClsColor(255, 255, 0) 
						Case 2 SetClsColor(0, 255, 255) 
						Case 3 SetClsColor(255, 0, 255) 
					End Select
				EndIf
				backalphainc[n] = 1 - backalphainc[n] 
			EndIf
			If backalpha[n] < 0
				backcol[n] = Rand(1, 3) 
				backalphainc[n] = 1 - backalphainc[n] 
			End If
			backalpha[n] :+(DeltaTime / 10) * (backalphainc[n] * 2 - 1) 
			Select backcol[n] 
				Case 1 SetColor 255, 0, 0
				Case 2 SetColor 0, 255, 0
				Case 3 SetColor 0, 0, 255
			End Select
			
			SetAlpha(backalpha[n] * a) 
			DrawSImage(backimg[n] , 0, 0) 
		Next
		SetBlend(ALPHABLEND) 
		SetAlpha(0.5 * a) 
		SetColor(255, 255, 255) 
		SetScale(1, 1)
		SetOrigin(0, 0)
		DrawRect(0, 0, GadgetWidth(gCan), GadgetHeight(gCan))
		SetOrigin(OriginX, OriginY)
	EndIf
	If t = 1
		SetBlend(ALPHABLEND)
		SetAlpha(1) 
		SetColor(255, 255, 255)
		
		SetScale(BACKSCALEX * IBackImg.scX, BACKSCALEY * IBackImg.scY)
		DrawImage(IBackImg.Image(), 0, 0)
		
		SetScale(1, 1)
	End If
	If t = 2
		SetClsColor(255, 255, 255) 
	End If
End Function

Function DrawScore()
'	SetClsColor(255, 255, 255)
	Cls
	SetBlend(ALPHABLEND)
	SetOrigin(0, 0)
	SetImageFont(FArialBold20)
	SetColor(240, 240, 240)
	DrawRect(0, 0, gCanScore.width, gCanScore.height)
	SetColor(0, 0, 0) 
	SetAlpha(1) 
	SetScale(0.4, 0.4)
	Local yoff:Int = 0
	SetColor(255, 255, 255)
	DrawImage(ITextBox.img, 10, yoff)
	DrawImage(ITextBox.img, gCanScore.width - 120, yoff)
	
	SetScale(24 / Float(IMine.Width()), 24 / Float(IMine.Height()))
	
	DrawImage(IMineImg, gCanScore.Width - 117, yoff + 5)
	
	SetScale(24 / Float(IClock.Width()), 24 / Float(IClock.Height()))
	
	DrawImage(IClock.Image(), 13, yoff + 5)
	
	SetColor(0, 0, 0)
	SetScale(1, 1)
	DrawText(Int(Floor(GameTime)), 50, yoff + 5)
	If Mines - TBlock.flags < 0 SetColor(255, 0, 0)
	DrawText(Mines - TBlock.flags, gCanScore.width - 80, yoff + 5)
	DrawLine(0, gCanScore.height - 2, gCanScore.width, gCanScore.height - 2)
	DrawLine(0, gCanScore.height - 1, gCanScore.width, gCanScore.height - 1)
	'DrawLine(0, gCanScore.height - 3, gCanScore.width, gCanScore.height - 3)
	Flip
End Function

Function DPrint(t:String) 
	?debug
	Print(t) 
	?
End Function

Function CPrint(t:String) 
	Local e:Byte = GadgetHidden(gChatConsole) 
	gChatConsole.AddText("~n " + t) 
	If e = 1 HideGadget(gChatConsole) 
End Function

Function DCPrint(t:String)
	?debug
	Local e:Byte = GadgetHidden(gChatConsole)
	gChatConsole.AddText("~n " + t) 
	If e = 1 HideGadget(gChatConsole) 	
	?
End Function

Type Delta
	Global Time:Float
	Global TimeDelay:Int = MilliSecs() 
	Global FPS:Int = 0
	Global mFPS:Int = 0
	Global __d:Short = 0 ''IGNORE THIS
	Function Start() 
		TimeDelay = MilliSecs() 
	End Function
	Function Update() 
		Time = (MilliSecs() - TimeDelay) * 0.001
		If (MilliSecs() - TimeDelay) > 0
			FPS = (1000 / (MilliSecs() - TimeDelay)) 
		EndIf
		TimeDelay = MilliSecs() 
		DeltaTime = Time
		__d:+Time * 1000
		If __d >= 1000
			mFPS = FPS
			__d = 0
		EndIf
	EndFunction
	Function Delta:Float() 
		Return Time
	End Function
	Function GetFPS:Int(Every_Second:Byte = 0) 
		If Every_Second = 1 Return mFPS
		If Every_Second = 0 Return FPS
	End Function
End Type

Function StartGame:Byte(w:Int, h:Int, m:Int, wr:Int = -1, gt:Float = 0, bLose:Int = -1)
	If m < (w * h) - 12
		If w <> BlockAW Or h <> BlockAH
			DEFWIDTH = Float((TBlock.Size * (w) + 52))
			DEFHEIGHT = Float((TBlock.Size * (h) + 52))
			'SetGadgetShape(gMainWindow, gMainWindow.xpos, gMainWindow.ypos, DEFWIDTH * 1.2, DEFHEIGHT * 1.2) 
			IBack1.SetScales(DEFWIDTH / IBack1.img.width, DEFHEIGHT / IBack1.img.height)
			IBack2.SetScales(DEFWIDTH / IBack2.img.width, DEFHEIGHT / IBack2.img.height)
			IBack3.SetScales(DEFWIDTH / IBack3.img.width, DEFHEIGHT / IBack3.img.height)
			backimg = [IBack1, IBack2, IBack3]
			IBackImg.SetScales(DEFWIDTH / 700, DEFHEIGHT / 900) 
			winr = Float(DEFWIDTH / DEFHEIGHT) 
			WindowSetToRatio(DEFWIDTH)
			'Print winr
		EndIf
		If wr = -1 Wrapping = oWrap Else Wrapping = wr
		StartBlocks(w, h)
		Mines = m
		gtime = MilliSecs()
		If bLose = -1 BombLose = oBombLose Else BombLose = bLose
		wtime = 0
		GameStatus = 0
		GameTime = gt
		TBlock.flags = 0
		For Local p:TPlayer = EachIn Players
			p.score = 0
			p.FindScore()
			p.out = 0
		Next
		For Local p:TPlayer = EachIn LeavingPlayers
			Players.Remove(p) 
		Next
		PlayerlistRefresh() 
		For Local p:TPlayer = EachIn SLeavingPlayers
			SPlayers.remove(p)
		Next
		Return 1
	EndIf

	Return 0
End Function
Function SendGame:Byte(w:Int, h:Int, m:Int) 
	If TNet.NetStatus = 2 And m < (w * h) - 12 
		rseed = MilliSecs() 
		TNet.MNew(MES_NEWGAME) 
		TNet.MInt(w) 
		TNet.MInt(h) 
		TNet.MInt(m) 
		TNet.MByte(oWrap)
		TNet.MByte(oBombLose)
		TNet.MInt(rseed)
		TNet.MFloat(0) 'Game time
		
		TNet.MNew(MES_CLICK) 
		Local bl:Int = Rand(0, w * h - 1) 
		TNet.MInt(bl) 
		TNet.MByte(MOUSE_LEFT) 
		TNet.MByte(255) 
		TNet.MClientSendTCP() 
		TNet.MClear() 
		Actions.clear() 
		TAction.Add(MES_CLICK, MOUSE_LEFT, bl, 255) 

	EndIf
EndFunction


 Function PointDistance:Double(x1:Double, y1:Double, x2:Double, y2:Double)
	Return Sqr((Abs(x1 - x2) ^ 2) + (Abs(y1 - y2) ^ 2)) ;
End Function
