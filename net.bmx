Const MESNEWMESSAGE:Double = 68740

'DO NOT USE 0 HERE
Const MES_CLICK:Short = 50
Const MES_SYNCBLOCKS:Short = 84
Const MES_RSEED:Short = 45
Const MES_NEWGAME:Short = 41

Const MES_CONNECT:Short = 1
Const MES_JOIN:Short = 2
Const MES_LEAVE:Short = 3
Const MES_JOINCONFIRM:Short = 4
Const MES_CHAT:Short = 5
Const MES_CURPLAYERS:Short = 6
Const MES_KICK:Short = 7
Const MES_PING:Short = 8
Const MES_SETCOLOR:Short = 9

Const MES_SETTYPE:Short = 100
Const MES_REFRESH:Short = 101
Const MES_SENDGAMES:Short = 102

'GLOBAL Net type. there only needs to be one
Type TNet
	Global Bank:TBank = New TBank
	Global Message:TBankStream = CreateBankStream(Bank)
	Global Clients:TList = New TList
	Global Clientsock:TSocket = TSocket.CreateTCP() 
	Global Serversock:TSocket = TSocket.CreateTCP() 
	Global NetStatus:Byte = 0 '0=singleplayer,1=hosting,2=joining
	Global MaxPlayers:Byte = 8
	Function Reset() 
		MClear()
		DisconnecT()
	End Function
	Function MClear() 
	'	If NetStatus = 0 Return
		Message.Close()
		Bank = New TBank
		Message = CreateBankStream(bank) 
	End Function
	Function MClientSendTCP(exclude:TNetClient = Null) 
		If netstatus = 0 Return
		For Local i:TNetClient = EachIn clients	
			If Not (i = exclude) 
				MSend(i.tcpsock) 
			EndIf
		Next
	End Function
	Function MNew(MessageType:Short) 
		'If NetStatus = 0 Return
		Message.WriteDouble(MESNEWMESSAGE) 
		Message.WriteShort(MessageType) 
	End Function
	Function MSend(sock:TSocket)
		If NetStatus > 0 Or sock = TServerList.sock sock.Send(Message._bank._buf, Message._bank._size) Else Return
	End Function
	Function BSend(sock:TSocket, Buf:Byte Ptr, Count:Int) 
		'If NetStatus = 0 Return
		sock.Send(Buf, Count) 
	End Function
	Function MKickID(id:Byte) 
		MNew(MES_KICK) 
		MByte(id) 
	End Function
	Function MByte(n:Byte) 
		'If NetStatus = 0 Return
		Message.WriteByte(n) 
	End Function
	Function MDouble(n:Double) 
		'If NetStatus = 0 Return
		Message.WriteDouble(n) 
	End Function
	Function MFloat(n:Float) 
		'If NetStatus = 0 Return
		Message.WriteFloat(n:Float) 
	End Function
	Function MInt(n:Int) 
		'If NetStatus = 0 Return
		Message.WriteInt(n) 
	End Function
	Function MLong(n:Long) 
		'If NetStatus = 0 Return
		Message.WriteLong(n) 
	End Function
	Function MShort(n:Short) 
		'If NetStatus = 0 Return
		Message.WriteShort(n) 
	End Function
	Function MLine(str:String) 
		'If NetStatus = 0 Return
		Message.WriteLine(str) 
	End Function
	Function MObject(obj:Object) 
		'If NetStatus = 0 Return
		Message.WriteObject(obj) 
	End Function
	Function MString(str:String) 
		'If NetStatus = 0 Return
		Message.WriteString(str) 
	End Function
	Function Recieve:TBankStream(sock:TSocket, length:Int)   'Reads length bytes from sock into a new bank and returns a bankstream
		'If netstatus = 0 Return Null
		Local bank:TBankStream = CreateBankStream(Null) 
		Local Buf:Byte[length] 
		sock.Recv(Buf, length) 
		bank.Write(Buf, length) 
		bank.Seek(0) 
		Return bank
	End Function
	Function Connect:Byte(cIP:Int = -1, cPort:Int = -1) 
		Clientsock.SetTCPNoDelay(1) 
		If Clientsock.Connect(cIP, cPORT)
			Return 1
		Else
			Return Null
		EndIf
	End Function
	Function Disconnect() 
		For Local c:TNetClient = EachIn clients
			c.tcpsock.Close()
		Next
		Players.Clear() 
		SPlayers.Clear() 
		Clients = New TList
		Clientsock.Close() 
		Clientsock = TSocket.CreateTCP() 
		Serversock.Close() 
		Serversock = TSocket.CreateTCP() 
		NetStatus = 0
		ClearGadgetItems(gChatPList) 
	End Function
	Function Host:Byte(cPort:Int = -1) 
		ServerSock.SetTCPNoDelay(1) 
		If Not Serversock.Bind(cPort)
			Return 0
		Else
			serversock.Listen(0) 
			Connect(HostIp("localhost"), cPort) 
			TNet.NetStatus = 2

			Return 1
		EndIf
	End Function
End Type

Type TNetClient
	Field IP:Int, PORT:Int, tcpsock:TSocket
	Function CreateClient:TNetClient(sock:TSocket) 
	'	If TNet.NetStatus = 0 Return Null
		Local n:TNetClient = New TNetClient
		n.tcpsock = sock
		n.IP = sock.RemoteIp() 
		n.PORT = sock.RemotePort() 
		Return n
	EndFunction
	Method New() 

		TNet.clients.AddLast(Self) 
	EndMethod
	Method remove() 
		tcpsock.Close() 
		TNet.Clients.Remove(Self) 
	End Method
End Type


