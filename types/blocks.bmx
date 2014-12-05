Global Blocks:TList = New TList
Global BlockMDown:Byte = 0
Global MouseBlock:TBlock = Null
Global BlockA:TBlock[1, 1]
Global BlockAW:Int
Global BlockAH:Int
Global Wrapping:Int = 1
Global Mines:Int = 13
Global rseed:Int = MilliSecs() 

Type TBlock
	Field x:Int, y:Int, dx:Float, dy:Float, Value:Int = 0, Revealed:Byte = 0, AdjBlocks:TBlock[9], flag:Byte = 0, id:Int = 0

	Field FadeAlpha:Float = (effect >= 0)
	Field fadecol:Byte[] = ColCreate(255, 255, 255)
		
	Field pcol:Byte[], pid:Byte=-1, fcol:Byte[], fpid:Byte = -1

	Global flags:Int = 0
	Global effect:Int = 0
	Global Size:Int = 24
	Global recursekill:Int = 0
	
	Function NumRevealed:Int() 
		Local _r:Int = 0
		For Local b:TBlock = EachIn Blocks
			If b.Revealed = 1 _r:+1
		Next
		Return _R
	End Function
	

	
	Method New()

		Blocks.AddLast(Self)
	EndMethod
	
	Function Create:TBlock(x:Float, y:Float) 
		Local n:TBlock = New TBlock
		n.x = x
		n.y = y
		n.SetDrawPos()
		Return n
	EndFunction
	
	Method SetDrawPos() 
		dx = x * Size
		dy = y * Size
	End Method
	
	Function DrawBlocks()
		SetOrigin(OriginX, OriginY)
		For Local b:TBlock = EachIn Blocks
			b.Draw() 
		Next
		SetAlpha(1)
		SetDrawMode(DRAW_LINE)
		SetColor(0, 0, 0)
		DrawSRect(framex, framey, BlockAW * Size, BlockAH * size, 3)
		SetDrawMode(DRAW_FILL)
	End Function
	
	Function UpdateBlocks()
		Local xx:Int = Floor((gMouseX - (framex * SCALEX)) / (Size * SCALEX))
		Local yy:Int = Floor((gMouseY - (framey * SCALEY)) / (Size * SCALEY))
		If xx >= 0 And yy >= 0 And xx < BlockAW And yy < BlockAH
			MouseBlock = BlockA[xx, yy]
		End If
	End Function
	
	
	Method MouseIn:Byte()
	'	rem
		If gMouseX > (framex + dx) * SCALEX And gMouseX < (framex + dx + Size) * SCALEX
			If gMouseY > (framey + dy) * SCALEY And gMouseY < (framey + dy + Size) * SCALEY
				Return 1
			Else
				Return 0
			EndIf
		EndIf
	'	endrem
	End Method
	
	Method ToggleFlag:Int(p:TPlayer)
		flag = 1 - flag
		If flag = 1 And p <> Null
			fcol = p.col
		 	fpid = p.id
		Else
			fpid = -1
		EndIf
		CountFlags()
	End Method
	
	Method Reveal:Int(p:TPlayer, clearflag:Byte = 0, block:TBlock = Null, first:Int = 1)
		If first = 1 recursekill = 0 Else recursekill:+1
		If recursekill > 85000
			Return - 2
		EndIf
		
		If revealed = 0
			revealed = 1
			If p <> Null
				pcol = p.col
				pid = p.id
			EndIf
			If value = 0
				For Local b:TBlock = EachIn AdjBlocks
					If b.Revealed = 0
						If b.Reveal(p, clearflag, block, 0) = -2
					
						EndIf
					EndIf
					If clearflag = 1 b.flag = 0
					
				Next
			endif
			Return Value
		EndIf
		Return value
	End Method
	
	Method Draw()
	
		If FadeAlpha > 0
			Select (effect)
				Case 0
					FadeAlpha:-(1 / PointDistance(DEFWIDTH / 2 - framex, DEFHEIGHT / 2 - framey, dx, dy)) * 4
				Case 1
					FadeAlpha:-(1 / PointDistance(0, 0, dx, dy)) * 4
				Case 2
					FadeAlpha:-(1 + Sin(dx)) / 200
					FadeAlpha:-(1 + Cos(dy)) / 200
			'		FadeAlpha:-(1 + -Sin(dy)) / 200
					FadeAlpha:-(1 / PointDistance(DEFWIDTH / 2 - framex, DEFHEIGHT / 2 - framey, dx, dy))
				Case 3
					FadeAlpha:-Delta.Time * 4
				Case 4
					FadeAlpha:-(((PointDistance(DEFWIDTH / 2 - framex, DEFHEIGHT / 2 - framey, dx, dy)) / DEFWIDTH) / 10)
					FadeAlpha:-(1 / PointDistance(DEFWIDTH / 2 - framex, DEFHEIGHT / 2 - framey, dx, dy)) / 3
				Case 5
					FadeAlpha:-Delta.Time
				Case 6
					FadeAlpha:-Delta.Time
			End Select
		EndIf
			
		If (dx + framex) * SCALEX > gCan.width - OriginX Return
		If (dy + framey) * SCALEY > gCan.height - OriginY Return
		If (dx + framex + Size) * SCALEX < - OriginX Return
		If (dy + framey + Size) * SCALEY < - OriginY Return
			
		SetAlpha(1)
		SetBlend(ALPHABLEND) 
		SetRotation(0) 
		SetScale(1, 1)
		If revealed = 0
			If MouseBlock = Self
				If BlockMDown And flag = 0
					SetColor 200, 250, 255
				'	SetRotation(180) 
				Else
					SetColor 190, 210, 240
					'SetColor 100, 135, 255
				EndIf
				SetAlpha 1
			Else
				SetColor 255, 255, 255
				SetAlpha 0.9
			EndIf
			'DrawImage(IBlock.img, 20, 20) 
			If GetRotation() = 0 DrawSImage(IBlock, framex + dx, framey + dy) Else DrawSImage(IBlock, framex + dx + Size, framey + dy + Size)
			SetRotation(0) 

		End If
		If revealed = 1 Or(BlockMDown = 1 And MouseBlock = Self And flag = 0)
			SetAlpha(1)
			If pcol <> Null SetColor(pcol[0], pcol[1], pcol[2]) Else SetColor(255, 255, 255)
			
			Local gr:Int, gg:Int, gb:Int
			GetColor(gr, gg, gb)
			SetColor((gr + 300) / 2, (gg + 300) / 2, (gb + 300) / 2)

			SetAlpha(0.8)
			DrawSImage(IBlockRev, framex + dx, framey + dy)
			SetRotation(0)
			SetAlpha(1)
			'DrawSRect(framex + dx, framey + dy, mw, mh)
			SetBlend(LIGHTBLEND)
			Select value
				Case 1 SetColor(90, 90, 200)
				Case 2 SetColor(0, 100, 0)
				Case 3 SetColor(255, 0, 0)
				Case 4 SetColor(0, 0, 255) 
				Case 5 SetColor(180, 0, 0) 
				Case 6 SetColor(80, 110, 255) 
				Case 7 SetColor(200, 125, 0) 
				Case 8 SetColor(40, 0, 0) 
			End Select
			 
			If revealed = 1
				SetBlend(ALPHABLEND)
				
			'	If SCALEX + SCALEY = 1.2
			'		SetImageFont(FArialBold20)
			'		SetScale(1, 1)
			'	Else
					SetImageFont(FArialBold40)
					SetScale(0.5, 0.5)
			'	EndIf
				
				If value > 0 DrawSText(String(value), (DX + framex + 6), (dy + framey + 0))
				
				SetScale(1, 1)
				If pcol <> Null SetColor pcol[0] , pcol[1] , pcol[2] Else SetColor(255, 255, 255) 
				If value = -1
					DrawSImage(IMine, framex + DX, framey + dy)
				EndIf
				SetScale(1, 1)
			EndIf
		EndIf
		
		If flag = 1
			SetScale(1, 1) 
			If fcol <> Null SetColor fcol[0] , fcol[1] , fcol[2] Else SetColor(255, 0, 0) 
			SetAlpha(0.7) 
			DrawSImage(IFlag, framex + dx, framey + dy) 
		EndIf
		If Fadealpha > 0
			SetBlend(LIGHTBLEND)
			SetAlpha(FadeAlpha)
			SetColor(fadecol[0], fadecol[1], fadecol[2])
			DrawSRect(framex + dx, framey + dy, Size, Size)
			SetBlend(ALPHABLEND)
		End If
	End Method
	
	Function FromID:TBlock(id:Int) 
		For Local b:TBlock = EachIn Blocks
			If b.id = id Return b
		Next
		Return Null
	End Function
	
	Method BlockAt:TBlock(xx:Int, yy:Int) 
	 	If Wrapping = 1
			Return BlockA[WrapPos(x + xx, y + yy)[0] , WrapPos(x + xx, y + yy)[1] ] 
		Else
			If x + xx >= 0 And y + yy >= 0 And x + xx < BlockAW And y + yy < BlockAH
				Return BlockA[x + xx, y + yy] 
			Else
				Return Null
			EndIf
		End If
	End Method
	
	Method AdjacentToBlock:Byte(block:TBlock) 
		For Local xx:Int = -1 To 1
			For Local yy:Int = -1 To 1
				If BlockAt(xx, yy) = block Return 1
			Next
		Next
		Return 0
	End Method
	
	Method FindAdjacents:TBlock[] () 
		Local a:Byte = 0
		For Local xx:Int = -1 To 1
			For Local yy:Int = -1 To 1
				Local b:TBlock = Blockat(xx, yy) 
				If b <> Self
					AdjBlocks[a] = b
					a:+1
				EndIf
			Next
		Next
	End Method
	
	Function MoveBlocks(xx:Int, yy:Int) 
		For Local b:TBlock = EachIn Blocks
			b.x = WrapPos(b.x + xx, b.y + yy)[0] 
			b.y = WrapPos(b.x + xx, b.y + yy)[1]
			BlockA[b.x, b.y] = b
			b.SetDrawPos() 
		Next
	End Function
	
	Function CountFlags:Int()
		flags = 0
		For Local b:TBlock = EachIn BlockA
			If b.flag = 1 flags:+1
		Next
		Return flags
	EndFunction
	
	Method Kill()
		For Local i:Int = 0 To 8
			AdjBlocks[i] = Null
		Next
	End Method
EndType

Function WrapPos:Int[] (xx:Int, yy:Int) 
	If xx <= - 1 xx = BlockAW - (0 - xx) 
	If yy <= - 1 yy = BlockAH - (0 - yy) 
	If xx >= BlockAW xx = 0
	If yy >= BlockAH yy = 0
	Return[xx, yy] 
End Function

Function StartBlocks(w:Int, h:Int)
	IBlock.SetScalesRelative(TBlock.Size)
	IMine.SetScalesRelative(TBlock.Size)
	IBlockRev.SetScalesRelative(TBlock.Size)
	IFlag.SetScalesRelative(TBlock.Size)
	
	TBlock.effect = Rand(0, 6)
	Local num:Int = (w * h)
	If oEffects = 0 TBlock.effect = -1
	If num > 3000 TBlock.effect = -1
	'Clear old blocks
	For Local oldblock:TBlock = EachIn Blocks
		oldblock.Kill()
	Next
	Blocks.Clear()
	rem
	If BlockA.dimensions()[0] > 0 And BlockA.dimensions()[1] > 0
		For Local ix:Int = 0 To BlockA.dimensions()[0] - 1
			For Local iy:Int = 0 To BlockA.dimensions()[1] - 1
				BlockA[ix, iy] = Null
			Next
		Next
	EndIf
	endrem
	BlockA = New TBlock[w, h]
	'Create new blocks
	BlockAW = w
	BlockAH = h
	Local n:Int = 0
	For Local xx:Int = 0 To w - 1
		For Local yy:Int = 0 To h - 1
			BlockA[xx, yy] = TBlock.Create(xx, yy) 
			BlockA[xx, yy].id = n
			n:+1
			Local b:TBlock = BlockA[xx, yy]
			Select TBlock.effect
				Case 3
					b.FadeAlpha = Rnd(0.5, 5)
					b.fadecol = ColCreate(Rand(0, 255), Rand(0, 255), Rand(0, 255))
				Case 5
					b.FadeAlpha = 0.5
					If Ceil(Float(xx) / 2) = xx / 2 b.FadeAlpha:+0.3
					If Ceil(Float(yy) / 2) = yy / 2 b.FadeAlpha:+0.3
					If Ceil(Float(xx) / 3) = xx / 3 b.FadeAlpha:+0.3
					If Ceil(Float(yy) / 3) = yy / 3 b.FadeAlpha:+0.3
				Case 6
					
					If b.id < num / 2
						b.FadeAlpha = Float(b.id) / (num / 3)
					Else
						b.FadeAlpha = (num - Float(b.id)) / (num / 3)
					EndIf
			EndSelect
		Next
	Next
	For Local b:TBlock = EachIn Blocks
		b.FindAdjacents() 
	Next
End Function

Function MakeMines(x:Int, y:Int, num:Int, rseed:Int = -1)
	If rseed = -1 rseed = MilliSecs()
	seedrnd(rseed) 
	Local p:Int = num
	Local mblock:TBlock = BlockA[x, y] 
	If num > BlockAW * BlockAH - 10 Return
	
	While p > 0
		Local xx:Int = Rand(0, BlockAW - 1) 
		Local yy:Int = Rand(0, BlockAH - 1) 
		If Not BlockA[xx, yy].AdjacentToBlock(mblock) And BlockA[xx, yy].Value = 0
			BlockA[xx, yy].Value = -1
			p:-1
		EndIf
	Wend
	
	For Local b:TBlock = EachIn Blocks
		If b.Value > - 1
			Local ms:Byte = 0
			For Local a:TBlock = EachIn b.AdjBlocks
				If a.Value = -1 ms:+1
			Next
			b.Value = ms
		End If
	Next
End Function