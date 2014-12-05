Type TSImage
	Field img:TImage, scX:Float, scY:Float
	Function Create:TSImage(img:TImage, scX:Float = 1, scY:Float = 1) 
		Local n:TSImage = New TSImage
		n.img = img
		n.scX = scX
		n.scY = scy
		Return n
	EndFunction
	Method SetScales(sx#,sy#) 
		scX = sx
		scY = sy
	End Method
	Method SetScalesRelative(sdiv:Float)
		scX = sdiv / img.width
		scY = sdiv / img.height
	End Method
	Method Image:TImage()
		Return img
	End Method
	
	Method Width:Int()
		Return img.Width
	End Method
	
	Method Height:Int()
		Return img.Height
	End Method
EndType


Function LoadSImage:TSImage(url:Object, scX:Float = 1, scY:Float = 1, flags:Int = -1) 
	Local i:TImage = LoadImage(url, flags)
	If i <> Null
		Return TSImage.Create(i, scX, scY) 
	Else
		Return Null
	EndIf
EndFunction

Function DrawSImage(sImage:TSImage, x:Float, y:Float, frame:Int = 0) 
	Local sx:Float, sy:Float
	GetScale(sx, sy) 
	SetScale(SCALEX * sImage.scX * sx, SCALEY * sImage.scY * sy)
	
	DrawImage(simage.img, X * SCALEX, Y * SCALEY, Frame)
	SetScale(sx, sy)
	

EndFunction

Function DrawSText(text:String, x:Float, y:Float)
	Local sx:Float, sy:Float
	GetScale(sx, sy)
	SetScale(SCALEX * sx, SCALEY * sy)
	DrawText(text, SCALEX * x, SCALEY * y)
	SetScale(sx, sy)
End Function

Function DrawSRect(x:Float, y:Float, width:Float, height:Float, size:Int = 1)
	If width = 1
		DrawRect(x * SCALEX, y * SCALEY, width * SCALEX, height * SCALEY)
	Else
		For Local i:Int = 0 To size - 1
			DrawRect(x * SCALEX - i, y * SCALEY - i, width * SCALEX + (i * 2), height * SCALEY + (i * 2))
		Next
	EndIf
End Function

Const DRAW_POINT:Int = GL_POINT
Const DRAW_LINE:Int = GL_LINE
Const DRAW_FILL:Int = GL_FILL

Function SetDrawMode(mode:Int)
    glPolygonMode(GL_FRONT_AND_BACK, mode)
EndFunction