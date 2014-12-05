Type TServerList
	Global Sock:TSocket
	Global IPs:String[2] 
	Global Ports:Int[2] 
	Global lists:Int = 2
	Global Gamelist:TList = New TList
	
	Function ClearList()
		Gamelist.Clear()
		ClearGadgetItems(gServerList)
	End Function
	
	Function NetRecv()
		If Connected()
			If sock.ReadAvail()
				Local mes:TBankStream = TNet.Recieve(sock, sock.ReadAvail())
				If mes.ReadDouble() = MESNEWMESSAGE
					Local mesid:Short = mes.ReadShort() 
					Select mesid
						Case MES_SENDGAMES
							Local c:Int = mes.ReadShort() 
							ClearList()
							If c > 0
								For Local i:Int = 1 To c
									Local ip:String = mes.ReadLine()
									Local PORT:Int = mes.ReadInt() 
									Local num:Short = mes.ReadShort() 
									Local name:String = mes.ReadLine()
									
									Local g:TGame = TGame.AddGame(GameList, name, ip, PORT)
									AddGadgetItem(gServerList, name, 0, - 1, ip + ":" + String(PORT), g)
									'CPrint name + "   " + ip + "   " + PORT
								Next
							Else
								AddGadgetItem(gServerList, "No games available")
							EndIf
						Case MES_CHAT
							Local ln:String = mes.ReadLine() 
							CPrint ln
					End Select
				EndIf
			End If
		EndIf
	EndFunction
	Function Connected:Byte() 
		If Sock <> Null
			If Sock.RemoteIp() = 0 Or Sock.Connected() = 0
				Return 0
			Else
				Return 1
			EndIf
		Else
			Return 0
		EndIf
	End Function
	
	Function Host:Byte(Name:String, port:Int) 
		If Connected() = 1
			TNet.MNew(MES_SETTYPE) 
			TNet.MByte(1) 
			TNet.MLine(Name) 
			TNet.MInt(PORT) 
			TNet.MSend(Sock) 
			TNet.MClear() 
			Return 1
		Else
			Return 0
		EndIf
	EndFunction
	Function Refresh:Byte() 
		If Connected() = 0 If Connect() = 0
			ClearList()
			AddGadgetItem(gServerList, "Failed to connect to server list")
			Return 0
		EndIf
		TNet.MNew(MES_REFRESH) 
		TNet.MSend(sock) 
		TNet.MClear() 
	End Function
	
	Function Connect:Byte() 
		For Local n:Int = 0 To lists - 1
			Local s:TSocket = TSocket.CreateTCP()
			Print IPs[0]
			Print Ports[0]
			If s.Connect(HostIp(IPs[n]) , Ports[n]) = 1
				sock = s
				sock.SetTCPNoDelay(0) 
				TNet.MNew(MES_SETTYPE) 
				TNet.MByte(2)
				Return 1
			EndIf
		Next
		Return 0
	EndFunction
EndType

Type TGame
	Field name:String, ip:String, PORT:Int
	Function AddGame:TGame(list:TList, name:String, ip:String, port:Int)
		Local n:TGame = New TGame
		n.name = name
		n.ip = ip
		n.PORT = PORT
		list.AddLast(n)
		Return n
	End Function
EndType




TServerList.IPs[0] = oListIP
TServerList.IPs[1] = "localhost"
TServerList.Ports[0] = Int(oListPort)
TServerList.Ports[1] = 8201




Function NetClient() 
	If TNet.Clientsock = Null Or TNet.Clientsock.Connected() = 0
		TNet.Disconnect() 
		TNet.Reset() 
		CPrint "Disconnected"
		SetStatusText(gMultiWindow, "Disconnected") 
	ElseIf TNet.Clientsock.ReadAvail() > 0
		Local ra:Int = TNet.Clientsock.ReadAvail() 
		Local so:TSocket = TNet.Clientsock
		Local mes:TBankStream = TNet.Recieve(so, ra) 
		While Not mes.Eof() 
			Local mnid:Double = mes.ReadDouble() 
			If mnid = MESNEWMESSAGE
				Local mesid:Short = mes.ReadShort() 
				Select mesid
					Case MES_JOIN
						Local name:String = mes.ReadLine() 
						Local r:Byte = mes.ReadByte() 
						Local g:Byte = mes.ReadByte() 
						Local b:Byte = mes.ReadByte() 
						Local col:Byte[] = ColCreate(r, g, b) 
						Local id:Byte = mes.ReadByte() 
						TPlayer.Create(name, col, id)
						CPrint name + " has joined the game."
						PlayerlistRefresh()
					Case MES_JOINCONFIRM
						Local name:String = mes.ReadLine() 
						Local r:Byte = mes.ReadByte() 
						Local g:Byte = mes.ReadByte() 
						Local b:Byte = mes.ReadByte() 
						Local col:Byte[] = ColCreate(r, g, b) 
						Local id:Byte = mes.ReadByte()
						Local p:TPlayer = TPlayer.Create(name, col, id)
						MPlayer = p
						PlayerlistRefresh() 
						DCPrint "I am " + name
					Case MES_CLICK
						Local bid:Int = mes.ReadInt() 
						Local mb:Byte = mes.ReadByte() 
						Local id:Byte = mes.ReadByte() 
						Local p:TPlayer = TPlayer.FindByID(id) 
						Local bl:TBlock = TBlock.FromID(bid) 
						If bl <> Null And p <> Null ClickBlock(bl, mb, p) 
						If bl <> Null And id = 255 ClickBlock(bl, mb) 
					Case MES_RSEED
						Local r:Int = mes.ReadInt() 
						SeedRnd(r) 
						rseed = r
					Case MES_CHAT
						Local l:String = mes.ReadLine() 
						CPrint l
					Case MES_NEWGAME
						Local w:Int = mes.ReadInt() 
						Local h:Int = mes.ReadInt() 
						Local m:Int = mes.ReadInt() 
						Local wr:Byte = mes.ReadByte()
						Local bl:Byte = mes.ReadByte()
						Local r:Int = mes.ReadInt()
						Local gt:Float = mes.ReadFloat()
						StartGame(w, h, m, wr, gt, bl)
						rseed = r
					Case MES_LEAVE
						Local id:Byte = mes.ReadByte() 
						Local p:TPlayer = TPlayer.FindByID(id) 
						CPrint p.name + " has left the game."
						p.name:+" [left]"
						p.Left = 1
						PlayerlistRefresh() 
						LeavingPlayers.AddLast(p) 
					Case MES_KICK
						TNet.Disconnect() 
						CPrint "You have been kicked from the game!"
					Case MES_SETCOLOR
						Local p:TPlayer = TPlayer.FindByID(mes.ReadByte())
						p.col[0] = mes.ReadByte()
						p.col[1] = mes.ReadByte()
						p.col[2] = mes.ReadByte()
				End Select
			End If
		WEnd
	EndIf
End Function

Function NetServer() 
	Local ac:TSocket = SocketAccept(TNet.Serversock) 
'	Print "lol"
	If ac <> Null
		TNetClient.CreateClient(ac) 
		DPrint "New Client"
	EndIf
	For Local cl:TNetClient = EachIn TNet.Clients
		If cl.tcpsock = Null Or cl.tcpsock.Connected() = 0
			TNet.Clients.Remove(cl) 
			DPrint "Lost connection to client"
			Local p:TPlayer = TPlayer.SFindByClient(cl) 
			If p <> Null
				p.client.remove() 
				p.Left = 1
				SLeavingPlayers.AddLast(p) 
				TNet.MNew(MES_LEAVE) 
				TNet.MByte(p.id) 
				TNet.MClientSendTCP() 
				TNet.MClear() 
			EndIf
		Else
			Local ra:Int = cl.tcpsock.ReadAvail() 
			If ra > 0
				Local mes:TBankStream = TNet.Recieve(cl.tcpsock, ra) 
				While Not mes.Eof() 
					Local mnid:Double = mes.ReadDouble() 
					If mnid = MESNEWMESSAGE
						Local mesid:Short = mes.ReadShort() 
						Select mesid 'INTERPRET MESSAGES	
							Case MES_CONNECT
								Local name:String = Mes.ReadLine() 
								Local col:Byte[3] 
								col[0] = Mes.ReadByte() 
								col[1] = Mes.ReadByte() 
								col[2] = Mes.ReadByte() 
								If Not TPlayer.SFindByClient(cl) 
									SPlayers.Sort(1, PlayersSortId)
									Local nincr:Int = 0
									Local doublename:String = name
									While TPlayer.SFindByName(doublename)
										nincr:+1
										doublename = name + String(nincr)
									Wend
									name = doublename
									
									Local p:TPlayer = TPlayer.Create(name, col, TPlayer.NID(), cl, 1)
									TNet.MNew(MES_JOIN) 
									TNet.MLine(name) 
									SendColor(col) 
									TNet.MByte(p.id) 
									TNet.MClientSendTCP(cl)
									TNet.MClear()
									
									TNet.MNew(MES_JOINCONFIRM)
									TNet.MLine(name) 
									SendColor(col) 
									TNet.MByte(p.id)	
									TNet.MSend(cl.tcpsock)
									TNet.MClear()
									
									TNet.MNew(MES_NEWGAME)
									TNet.MInt(BlockAW) 
									TNet.MInt(BlockAH) 
									TNet.MInt(Mines)
									TNet.MByte(Wrapping)
									TNet.MByte(BombLose)
									TNet.MInt(rseed) 
									TNet.MFloat(GameTime)
									
									For Local cpl:TPlayer = EachIn SPlayers
										If cpl <> p
											TNet.MNew(MES_JOIN) 
											TNet.MLine(cpl.name) 
											Sendcolor(cpl.col) 
											TNet.MByte(cpl.id) 
											If cpl.Left = 1
												TNet.MNew(MES_LEAVE) 
												TNet.MByte(cpl.id) 
											End If
										EndIf
									Next
									For Local a:TAction = EachIn Actions
										TNet.MNew(a.atype) 
										TNet.MInt(a.adata) 
										TNet.MByte(a.amod) 
										TNet.MByte(a.aplayer) 
									Next
																	
									TNet.MSend(cl.tcpsock)
									TNet.MClear()
								EndIf
							Case MES_CHAT
								Local l:String = TPlayer.SFindByClient(cl).name + ": " + mes.ReadLine()
								TNet.MNew(MES_CHAT) 
								TNet.MLine(l) 
								TNet.MClientSendTCP() 
								TNet.MClear() 
							Case MES_CLICK
								Local bid:Int = mes.ReadInt() 
								Local mb:Byte = mes.ReadByte() 
								If TPlayer.SFindByClient(cl) <> Null
									Local id:Byte = TPlayer.SFindByClient(cl).id
									TNet.MNew(MES_CLICK) 
									TNet.MInt(bid) 
									TNet.MByte(mb) 
									TNet.MByte(id) 
									TNet.MClientSendTCP() 
									TNet.MClear() 
									TAction.Add(MES_CLICK, mb, bid, id) 
								End If
							Case MES_SETCOLOR
								Local p:TPlayer = TPlayer.SFindByClient(cl)
								p.col[0] = mes.ReadByte()
								p.col[1] = mes.ReadByte()
								p.col[2] = mes.ReadByte()
								TNet.MNew(MES_SETCOLOR)
								TNet.MByte(p.id)
								Sendcolor(p.col)
								TNet.MClientSendTCP()
								TNet.MClear()
						EndSelect
					EndIf
				Wend
			End If
		EndIf
	Next
End Function


Global Actions:TList = New TList
Type TAction
	Const ACT_CLICK:Byte = 50
	Field atype:Byte, amod:Byte, adata:Float, aplayer:Byte
	Method New() 
		Actions.AddLast(Self) 
	End Method
	Function Add:TAction(atype:Byte, amod:Byte, adata:Float, aplayer:Byte) 
		Local n:TAction = New TAction
		n.atype = atype
		n.amod = amod
		n.adata = adata
		n.aplayer = aplayer
		Return n
	End Function
End Type

Global SPlayers:TList = New TList
Global Players:TList = New TList
Global MPlayer:TPlayer
Global LeavingPlayers:TList = New TList
Global SLeavingPlayers:TList = New TList


Type TPlayer
	Field name:String, col:Byte[3], id:Byte, client:TNetClient, Left:Byte = 0
	Field score:Int, out:Int
	Method New() 

	End Method
	
	Method remove() 
		Players.Remove(Self) 
		SPlayers.Remove(Self) 
	End Method
	
	Method FindScore:Int()
		score = 0
		For Local b:TBlock = EachIn BlockA
			If b.flag = 1 And b.value >= 0 And b.fpid = id score:-1
			If b.flag = 1 And b.value = -1 And b.fpid = id score:+1
			If b.pid = id And b.Value = -1 score:-5
		Next
	End Method
	
	Function NID:Byte() 
		For Local n:Byte = 0 To 254
			Local h:Byte = 0
			For Local p:TPlayer = EachIn Players
				If p.id = n h = 1
			Next
			If h = 0
				Return n
				Exit
			End If
		Next
		Return 0
	End Function
	Function SFindByClient:TPlayer(client:TNetClient) 
		For Local p:TPlayer = EachIn SPlayers
			If p.client = client
				Return p
				Exit
			EndIf
		Next
		Return Null
	End Function
	Function SFindByID:TPlayer(id:Byte) 
		For Local p:TPlayer = EachIn SPlayers
			If p.id = id
				Return p
				Exit
			EndIf
		Next
		Return Null
	End Function
	Function SFindByName:TPlayer(name:String)
		For Local p:TPlayer = EachIn SPlayers
			If p.name = name
				Return p
				Exit
			EndIf
		Next
		Return Null		
	End Function
	
	
	
	Function FindByClient:TPlayer(client:TNetClient) 
		For Local p:TPlayer = EachIn Players
			If p.client = client
				Return p
				Exit
			EndIf
		Next
		Return Null
	End Function
	
	Function FindByID:TPlayer(id:Byte) 
		For Local p:TPlayer = EachIn Players
			If p.id = id
				Return p
				Exit
			EndIf
		Next
		Return Null
	End Function
	
	Function FindByName:TPlayer(name:String)
		For Local p:TPlayer = EachIn Players
			If p.name = name
				Return p
				Exit
			EndIf
		Next
		Return Null		
	End Function
	
			
	Function Create:TPlayer(name:String, col:Byte[] , id:Byte, cl:TNetClient = Null, slist:Byte = 0) 
		Local n:TPlayer = New TPlayer
		n.name = name
		n.col[0] = col[0] 
		n.col[1] = col[1] 
		n.col[2] = col[2] 
		n.id = id
		n.client = cl
		If slist = 0 Players.AddLast(n) 
		If slist = 1 SPlayers.AddLast(n) 
		'CPrint "ADDING PLAYER " + name + " TO LIST"
		Return n
	EndFunction
EndType

Function PlayerlistRefresh() 
	Players.sort(1, PlayersSortId) 
	ClearGadgetItems(gChatPList) 
	For Local n:TPlayer = EachIn Players
		AddGadgetItem(gChatPList, n.name)
		
	Next
End Function

Function PlayersSortId:Int(o1:Object, o2:Object) 
	Local p1:TPlayer = TPlayer(o1) 
	Local p2:TPlayer = TPlayer(o2) 
	If p1.id > p2.id Return 1
	If p1.id = p2.id Return 0
	If p1.id < p2.id Return - 1
End Function

Function compareScore:Int(o1:Object, o2:Object)
	Local p1:TPlayer = TPlayer(o1)
	Local p2:TPlayer = TPlayer(o2)
	If p1.score > p2.score Return 1
	If p1.score = p2.score Return 0
	If p1.score < p2.score Return - 1
End Function

Function KickID(id:Byte)
	Local p:TPlayer = TPlayer.SFindByID(id) 
	If p <> Null
		TNet.MNew(MES_KICK) 
		TNet.MSend(p.client.tcpsock) 
	EndIf
	TNet.MClear() 
End Function