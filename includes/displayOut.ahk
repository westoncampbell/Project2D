#include logError.ahk

class display
{
	
	__New( hWND := 0, size = "", usedAPI := "gdipAPI" )
	{
		if ( This.setFieldSize( isObject( size ) ? size : [ 1, 1 ] ) )
		{
			logError( "Can't create display:Wrong size", A_ThisFunc, 3 )
			return
		}
		if ( This.setTarget( hWND ) )
		{
			logError( "Can't create display:Can't connect to Window", A_ThisFunc, 3 )
			return
		}
		if ( This.setAPI( usedAPI ) )
		{
			logError( "Can't create display:Can't connect to API", A_ThisFunc, 3 )
			return
		}
		This.visiblePics   := {}
		This.visibleWorld  := []
	}
	
	addPicture( file, pos = "", size = "" , rotation := 0 )
	{
		This.loadFile( file )
		pic := new This.Picture( This )
		pic.setPosition( isObject( pos ) ? pos : [ 1, 1 ]  )
		pic.setSize( isObject( size ) ? size : [ 1, 1 ]  )
		pic.setRotation( 0 )
		pic.setFile( file )
		This.notifyChange( pic )
		return pic
	}
	
	removePicture( pic )
	{
		This.removeFromVisibleWorld( pic )
	}
	
	setAutoRedraw( bAutoRedraw )
	{
		This.autoRedraw := bAutoRedraw
	}
	
	class Picture
	{
		visible := 0
		
		__New( display )
		{
			This.setPosition( [ 0, 0 ] )
			This.setZLayer( 1 )
			This.setParent( display )
		}
		
		__Delete()
		{
			This.setVisible( false )
			This.getParent().notifyChange( This )
		}
		
		setPosition( pos )
		{
			This.pos := pos
			if ( This.getVisible() )
				This.getParent().notifyChange( This )
		}
		
		getPosition()
		{
			return This.pos
		}
		
		setRotation( rot )
		{
			This.rot := rot
			if ( This.getVisible() )
				This.getParent().notifyChange( This )
		}
		
		getRotation()
		{
			return this.rot
		}
		
		setFile( fileName )
		{
			if ( This.fileName = fileName )
				return
			if !fileExist( fileName )
			{
				logError( "Couldn't find file:""" . fileName . """.", A_ThisFunc, 3 )
				return
			}
			This.fileName := fileName
			if ( This.getVisible() )
				This.getParent().notifyChange( This )
		}
		
		getFile()
		{
			return This.fileName
		}
		
		setVisible( bVisible )
		{
			if ( !!bVisible ^ This.getVisible() )
			{
				This.visible := !!bVisible, This.getParent().notifyChange( This )
			}
		}
		
		getVisible()
		{
			return This.visible
		}
		
		setZLayer( zLayer )
		{
			This.zLayer := zLayer
			if This.getVisible()
				This.getParent().notifyChange( This )
		}
		
		getZLayer()
		{
			return This.zLayer
		}
		
		setSize( size )
		{
			This.size := size
			if This.getVisible()
				This.getParent().notifyChange( This )
		}
		
		getSize()
		{
			return This.size
		}
		
		setParent( parent )
		{
			This.parent := Object( parent )
		}
		
		getParent()
		{
			return Object( This.parent )
		}
	}
	
	setFieldSize( size )
	{
		if !( size.1 > 0 && size.2 > 0 )
			return 1
		This.size := size
	}
	
	getFieldSize()
	{
		return This.size
	}
	
	setAPI( usedAPI )
	{
		global
		if ( isObject( usedAPI ) || isObject( usedAPI := %usedAPI% ) )
			return !isObject( This.API := new usedAPI( This ) )
		return 1
	}
	
	getAPI()
	{
		return This.API
	}
	
	setTarget( hWND )
	{
		This.targetHWND := hWND
	}
	
	getTargetHWND()
	{
		return This.targetHWND
	}
	
	getTargetRect()
	{
		VarSetCapacity( rc, 16 )
		DllCall("GetClientRect", "Ptr", This.targetHWND, "Ptr", &rc )
		rect := []
		Loop 4
			rect.Push( NumGet( rc, A_Index * 4 - 4, "UInt") )
		return rect
	}
	
	loadFile( fileName )
	{
		if !This.getAPI().isLoaded( fileName )
			This.getAPI().loadPicture( fileName )
	}
	
	notifyChange( pic = "" )
	{
		if ( pic.getVisible() )
		{
			This.foadFile( pid.getFile() )
			This.addToVisibleWorld( pic )
		}
		else
			This.removeFromVisibleWorld( pic )
		if ( This.autoRedraw )
			This.draw()
	}
	
	removeFromVisibleWorld( pic )
	{
		if ( This.visiblePics.hasKey( idPic := Object( pic ) ) )
		{
			zLayerID := This.visiblePics[ idPic ]
			This.visibleWorld[ zLayerId ].Delete( idPic ) 
			This.visiblePics.Delete( idPic )
			This.hasChanged[ zLayerId ] := 1
		}
	}
	
	addToVisibleWorld( pic )
	{
		This.removeFromVisibleWorld( pic )
		This.visiblePics[ idPic := Object( pic ) ] := zLayerId := pic.getZLayer()
		This.visibleWorld[ zLayerId, idPic ] := idPic
		This.hasChanged[ zLayerId ] := 1
	}
	
	draw()
	{
		API := This.getAPI()
		if ( API.prepareBuffer() )
		{
			For zLayerID, picList in This.visibleWorld
			{
				if ( API.prepareZLayer( zLayerID ) )
					For idPic in picList
						API.drawPic( Object( idPic ) )
				API.flushZLayer()
			}
		}
		API.flushBufferToGUI()
	}
	
}

class gdipAPI 
{
	
	static loaded := 0
	
	__New( connectedDisplay )
	{
		if ( This.setDisplay( connectedDisplay ) )
		{
			logError( "Can't create API instance:display incompatible", A_ThisFunc, 3 )
			return
		}
		if ( This.loadAPI() )
		{
			logError( "Can't create API instance:loadAPI failed", A_ThisFunc, 3 )
			return
		}
		This.loadedPics := {}
		This.zLayers    := {}
	}
	
	__Delete()
	{
		For each, pBitmap in This.loadedPics
			This.deletepBitmap( pBitmap )
		For each, pBitmap in This.zLayers
			This.deletepBitmap( pBitmap )
		This.deletepBitmap( This.drawBuffer )
	}
	
	loadAPI()
	{
		if !( gdipAPI.loaded++ )
		{
			if !DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" )
				if !DllCall( "LoadLibrary", "Str", "gdiplus" )
				{
					logError( "Can't load gdiplus.dll LastError:" . A_LastError, A_ThisFunc, 3 )
					return 1
				}
			VarSetCapacity( si, A_PtrSize = 8 ? 24 : 16, 0)
			si := Chr(1)
			DllCall( "gdiplus\GdiplusStartup","Ptr*", pToken, "Ptr", &si, "Ptr", 0 )
			gdipAPI.pToken := pToken
		}
	}
	
	freeAPI()
	{
		if ( !(--gdipAPI.loaded) )
		{
			DllCall( "gdiplus\GdiplusShutdown", "Ptr", gdipAPI.pToken )
			if ( hModule := DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" ) )
				DllCall( "FreeLibrary", "Ptr", hModule )
		}
	}
	
	
	prepareBuffer()
	{
		This.updateSize()
		size := This.getSize()
		if ( This.drawBuffer.w != size.1 || This.drawBuffer.h != size.2 )
		{
			This.deletepBitmap( This.drawBuffer )
			This.drawBuffer := This.createpBitmap( size.1, size.2 )
			This.openGraphics( This.drawBuffer )
		}
		This.clearpBitmap( This.drawBuffer, 0xFF000000 )
		return 1
	}
	
	prepareZLayer( id, hasChanged = 1 )
	{
		if ( ( zLayer := This.zLayers[ id ] ).w != This.getSize().1 || zLayer.h != This.getSize().2 )
		{
			This.deletepBitmap( zLayer )
			zLayer := This.zLayers[ id ] := This.createpBitmap( This.getSize().1, This.getSize().2 )
			This.openGraphics( This.zLayers[ id ] )
			hasChanged := 1
		}
		if ( hasChanged )
			This.clearpBitmap( zLayer )
		This.activeZLayer := zLayer
		return hasChanged
	}
	
	drawPic( pic )
	{
		sourcepBitmap := This.loadedPics[ pic.getFile() ]
		targetpBitmap := This.activeZLayer
		rect    := This.translateCoordsToPixelRect( pic.getPosition(), pic.getSize() )
		if ( This.drawImage( targetpBitmap.pGraphics, sourcepBitmap.pBitmap, rect.1, rect.2, rect.3, rect.4, 0, 0, sourcepBitmap.w, sourcepBitmap.h ) )
			logError( "Can't draw pic", A_ThisFunc, 3 )
	}
	
	flushZLayer()
	{
		This.delete( "activeZLayer" )
	}
	
	flushBufferToGUI()
	{
		For each, zLayer in This.zLayers
			This.pushpBitmap( This.drawBuffer, zLayer )
		targetpBitmap := This.openTarget()
		This.pushpBitmap( targetpBitmap, This.drawBuffer )
		This.freeTarget( targetpBitmap )
	}
	
	
	setDisplay( connectedDisplay )
	{
		if ( !connectedDisplay.getTargetHWND() )
		{
			logError( "Can't connect to display:display needs to be connected to window or control", A_ThisFunc, 3 )
			return 1
		}
		if !( connectedDisplay.getFieldSize().1 && connectedDisplay.getFieldSize().2 )
		{
			logError( "Can't connect to display:display needs to have a field size", A_ThisFunc, 3 )
			return 1
		}
		This.display := Object( connectedDisplay )
	}
	
	getDisplay()
	{
		return Object( This.display )
	}
	
	updateSize()
	{
		This.size := This.getTargetSize()
		fieldSize := This.getDisplay().getFieldSize()
		This.mul  := [ This.size.1 / fieldSize.1, This.size.2 / fieldSize.2 ]
		This.add  := [ -This.mul.1 / 2, -This.mul.2 / 2 ]
	}
	
	getSize()
	{
		return This.size
	}
	
	translateCoordsToPixelRect( pos, size )
	{
		return [ Round( ( pos.1 - ( size.1/2 ) ) * This.mul.1 + This.add.1 ), Round( ( pos.2 - ( size.2/2 ) ) * This.mul.2 + This.add.2 ), Round( size.1 * This.mul.1 ), Round( size.2 * This.mul.2 ) ]
	}
	
	getTargetSize()
	{
		rect := This.getDisplay().getTargetRect()
		rect.removeAt( 1, 2 )
		return rect
	}
	
	createpBitmap( w, h )
	{
		DllCall( "gdiplus\GdipCreateBitmapFromScan0", "UInt", w, "UInt", h, "UInt", 0, "UInt", 0x26200A, "Ptr", 0, "Ptr*", pBitmap )
		Return { pBitmap : pBitmap, h: h, w: w }
	}
	
	deletepBitmap( pBitmap )
	{
		This.closeGraphics( pBitmap )
		if ( !isObject( pBitmap ) || ( pBitmap := pBitmap.pBitmap ) )
			DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap )
	}
	
	clearpBitmap( pBitmap, color = 0 )
	{
		if !pBitmap.hasKey( "pGraphics" )
			This.openGraphics( pBitmap )
		DllCall( "gdiplus\GdipGraphicsClear", "Ptr", pBitmap.pGraphics, "UInt", color )
	}
		
	pushpBitmap( targetpBitmap, sourcepBitmap )
	{
		if !( targetpBitmap.haskey( "pGraphics" ) )
			This.openGraphics( targetpBitmap )
		if ( This.drawImage( targetpBitmap.pGraphics, sourcepBitmap.pBitmap, 0, 0, targetpBitmap.w, targetpBitmap.h, 0, 0, sourcepBitmap.w, sourcepBitmap.h ) )
			logError( "Can't push picture", A_ThisFunc, 3 )
	}
	
	drawImage( tpGraphics, spBitmap, tx, ty, tw, th, sx, sy, sw, sh )
	{
		if ( ret := DllCall( "gdiplus\GdipDrawImageRectRect", "Ptr", tpGraphics, "Ptr", spBitmap, "float", tx, "float", ty, "float", tw, "float", th, "float", sx, "float", sy, "float", sw, "float", sh, "UInt", 2, "Ptr", 0, "Ptr", 0, "Ptr", 1 ) )
			logError( "Can't draw picture", A_ThisFunc, 3 )
		return ret
	}
	
	openGraphics( pBitmap )
	{	
		if !pBitmap.hasKey( "pGraphics" )
		{
			DllCall( "gdiplus\GdipGetImageGraphicsContext", "Ptr", pBitmap.pBitmap, "Ptr*", pGraphics )
			pBitmap.pGraphics := pGraphics
		}
	}
	
	closeGraphics( pBitmap )
	{
		if pBitmap.hasKey( "pGraphics" )
		{
			DllCall( "gdiplus\GdipDeleteGraphics", "Ptr", pBitmap.pGraphics )
			pBitmap.Delete( "pGraphics" )
		}
	}
	
	openTarget()
	{
		size := This.getTargetSize()
		hDC := DllCall( "GetDC", "Ptr", hWND := This.getDisplay().getTargetHWND() )
		DllCall( "gdiplus\GdipCreateFromHDC", "Ptr", hDC, "Ptr*", pGraphics )
		return { w: size.1, h: size.2, pGraphics: pGraphics, hDC: hDC, hWND: hWND }
	}
	
	freeTarget( targetpBitmap )
	{
		DllCall( "gdiplus\GdipReleaseDC", "Ptr", targetpBitmap.pGraphics, "Ptr", targetpBitmap.hDC )
		DllCall( "ReleaseDC", "Ptr", targetpBitmap.hWND, "Ptr", targetpBitmap.hDC )
	}
		
	loadPicture( pictureFile )
	{
		DllCall( "gdiplus\GdipCreateBitmapFromFile", "WStr", pictureFile, "Ptr*", pBitmap )
		DllCall( "gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "UInt*", w )
		DllCall( "gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", h )
		This.loadedPics[ pictureFile ] := { pBitmap: pBitmap, w: w, h: h }
	}
	
	isLoaded( pictureFile )
	{
		return This.loadedPictures.hasKey( pictureFile )
	}
	
	unloadPicture( pictureFile )
	{
		This.deletepBitmap( This.loadedPictures[ pictureFile ] )
		This.loadedPictures.Delete( pictureFile )
	}

}