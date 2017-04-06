#include %A_LineFile%\..\logError.ahk
#include %A_LineFile%\..\classGDIp.ahk
#include %A_LineFile%\..\indirectReference.ahk

/*
	API display OutPut
	author:      nnnik
	
	description: The display Output API is used to output images on a GUI while having certain control over them.
	
	general:     First you create an instance of the display class.
	Then you use it's methods to create picture objects.
	With these picture objects you can then control what exactly is displayed how.
*/

class display
{
	
	/*
		class display 
		syntax:  newDisplay := new display( hWND [, size, usedAPI ] )
		
		displayOutput:	The new instance of a display class
		
		hWND:			The handle of the Window or control you want to output data to
		
		size:			The size of the field of the display
		Has to be in the form [ sizeX, sizeY ]
		( optional defaults to [ 1, 1 ] )
		
		usedAPI: 		The backend API used to output to the Window
		So far it can only be "gdipAPI" or gdipAPI which will use gdip to display the output
		
	*/
	
	__New( hWND , size = "", usedAPI := "gdipAPI" )
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
	}
	
	/*
		method addPicture
		description: 	Creates a new Picture to display
		
		syntax: 		newPicture := newDisplay.addPicture( file, [ pos, size, rotation ] )
		
		newPicture:		A new instance of the display.Picture class
		
		file:			The path to the picture file you want displayed
		e.g. "test.png"
		
		pos:			The position of the picture on the field
		Has to be in the form [ posX, posY ] e.g. [ 1, 1 ] or in the form of [ posX, posY, posZ ]
		Defaults to [ 1, 1 ]
		It is important to know how sizing and positioning works in the display API
		The position is relative to the size of the parent displays field, meaning that if the fields size is [ 1, 1 ] and the Pictures pos is [ 1, 1 ] the picture is centered
		If the fields size is [ 2, 2 ] and the Pictures pos is [ 1, 1 ] it takes up the upper left quarter of the field
			The Z position defines which picture is drawn on top and which on bottom
		Pictures with a higher Z coordinate are drawn on top of others
		
		size:			The size of the picture on the field
		Has to be in the form [ sizeX, sizeY ] e.g. [ 1, 1 ]
		Defaults to [ 1, 1 ]
		It is important to know how sizing and positioning works in the display API
		The size is relative to the size of the parent displays field, meaning that if the fields size is [ 1, 1 ] and the Pictures size is [ 1, 1 ] it takes up the entire field
		
		rotation:		The rotation of the picture on the field
		Currently not implemented
		
	*/
	
	addPicture( file, pos = "", size = "" , rotation := 0 )
	{
		pic := new This.Picture()
		pic.setDisplay( This )
		pic.setPosition( isObject( pos ) ? pos : [ 1, 1, 1 ]  )
		pic.setSize( isObject( size ) ? size : [ 1, 1 ]  )
		pic.setRotation( 0 )
		pic.setFile( file )
		return pic
	}
	
	/*
		method draw
		description:	Draws everything on the field and outputs it to the GUI/Control
		
		syntax			newDisplay.draw()
	*/
	
	draw()
	{
		API := This.getAPI()
		API.prepareFrame()
		For zLayerID, zLayer in This.zLayers
			API.drawZLayer( zLayer )
		API.flushFrame()
	}
	
	/*
		method setDisplayStyle
		description:	Defines the looks of the pictures that are drawn onto the GUI
		Can make pictures look very smooth or pixelated
		
		syntax:			newDisplay.setDisplayStyle( drawStyle )
		
		drawStyle:		Can be either "pixelated" or "smooth"
		
	*/
	
	setDrawStyle( drawStyle )
	{
		This.drawStyle := drawStyle,This.getAPI().notifyDrawStyle()
	}
	
	setPixelPerField( pix )
	{
		This.minPix := pix
	}
	
	setTarget( hWND )
	{
		This.targetHWND := hWND
		This.getAPI().notifyTarget()
	}
	
	setFieldSize( size )
	{
		if  ( !( size.1 > 0 && size.2 > 0 ) )
			return 1
		else if !( This.size.1 = size.1 && This.size.2 = This.size.2 )
			This.size := size
		This.getAPI().notifyField()
	}
	
	setAPI( usedAPI )
	{
		global
		if ( isObject( usedAPI ) || isObject( usedAPI := %usedAPI% ) )
		{
			This.API := new usedAPI( This )
			This.API.notifyTarget()
			This.API.notifyField()
			This.API.notifyDrawStyle()
			return !isObject( This.API )
		}
		return 1
	}
	
	getFieldSize()
	{
		return This.size
	}
	
	getAPI()
	{
		return This.API
	}
	
	getTargetHWND()
	{
		return This.targetHWND
	}
	
	getTargetSize()
	{
		VarSetCapacity( rc, 16 )
		DllCall("GetClientRect", "Ptr", This.targetHWND, "Ptr", &rc )
		return [ NumGet( rc, 8, "UInt"), NumGet( rc, 12, "UInt") ]
	}
	
	getDrawStyle()
	{
		return This.drawStyle
	}
	
	getPixelPerField()
	{
		return This.minPix
	}
	
	registerFile( fileName )
	{
		if !( ( API := This.getAPI() ).isLoaded( fileName ) )
			API.loadPicture( fileName )
	}
	
	/*
		class display.Picture
		description: 	The Picture class returned by the addPicture method.
		Shouldn't be instanced directly
		A new picture is always invisible
	*/
	
	class Picture
	{
		
		/*
			method setFile
			description:	Sets the picture on the field
			
			syntax:			newPicture.setFile( fileName )
			
			fileName:		The path of the file you want to display
			e.g. "test.png"
		*/
		
		setFile( fileName )
		{
			This.fileName := fileName
			This.getDisplay().registerFile( fileName )
		}
		
		/*
			method setPosition
			description:	Sets the position of the picture on the field
			
			syntax:			newPicture.setPosition( pos )
			
			pos:			The position of the picture on the field
			Has to be in the form [ posX, posY, posZ ] e.g. [ 1, 1, 1 ]
			The Z position defines which picture is drawn on top and which on bottom
			Pictures with a higher Z coordinate are drawn on top of others
		*/
		
		setPosition( pos )
		{
			if ( This.pos.3 != pos.3 )
				This.joinZLayer()
			This.pos := pos
		}
		
		/*
			method setRotation
			description:	Sets the rotation of the picture on the field
			Currently not implemented
			
			syntax:			newPicture.setRotation( rot )
		*/
		
		setRotation( rot )
		{
			This.rot := rot
		}
		
		/*
			method setSize
			description:	Sets the size of the picture on the field
			
			syntax:			newPicture.setSize( size )
			
			pos:			The size of the picture on the field
			Has to be in the form [ sizeX, sizeY ] e.g. [ 1, 1 ]
		*/
		
		setSize( size )
		{
			This.size := size
		}
		
		/*
			method setVisible
			description:	Defines wether a Picture is visible on the field or not
			Since they start invisible making them visible is neccessary to display the on the GUI
			
			syntax:			newPicture.setVisible( bVisible )
			
			bVisible:		Defines visibility
			Boolean value (0 = invisible | 1 = visible )
		*/
		
		setVisible( bVisible )
		{
			bVisible := !!bVisible
			if ( bVisible ^ This.getVisible() )
				if ( bVisible )
					This.joinZLayer()
			else
				This.leaveZLayer()
		}
		
		/*
			method getters
			description:	Returns the value of the attributes set above. 
			Just replace set with get and you will get the value of the Attribute
		*/
		
		getFile()
		{
			return This.fileName
		}
		
		getPosition()
		{
			return This.pos.clone()
		}
		
		getRotation()
		{
			return this.rot
		}
		
		getSize()
		{
			return This.size.clone()
		}
		
		getVisible()
		{
			return !!This.visible
		}
		
		/*
			method internals
			description:	Methods used to make the pictures work internally
			Proceed with caution
		*/
		
		joinZLayer()
		{
			This.leaveZLayer()
			This.zLayer := This.getDisplay().getZLayer( This.getPosition().3 )
			This.zLayer.addPicture( This )
		}
		
		leaveZLayer()
		{
			This.zLayer.removePicture( This )
			This.delete( "zLayer" )
		}
		
		getZLayer()
		{
			return This.zLayer
		}
		
		setDisplay( parentDisplay )
		{
			This.parentDisplay := new indirectReference( parentDisplay )
		}
		
		getDisplay()
		{
			return This.parentDisplay
		}
		
		__Delete()
		{
			This.leaveZLayer()
		}
		
	}
	
	getZLayer( zLayerID )
	{
		if !( This.zLayers.hasKey( zLayerID ) )
			This.zLayers[ zLayerID ] := new This.ZLayer( This, zLayerID )
		return This.zLayers[ zLayerID ]
	}
	
	freeZLayer( zLayerID )
	{
		This.zLayers.Delete( zLayerID )
	}
	
	class ZLayer
	{
		
		__New( parentDisplay, layerID )
		{
			This.visiblePictures := {}
			This.parentDisplay   := new indirectReference( parentDisplay )
			This.layerID         := layerID
		}
		
		__Delete()
		{
			This.parentDisplay.freeZLayer( This.layerID )
		}
		
		addPicture( pic )
		{
			This.visiblePictures[ &pic ] := new indirectReference( pic )
		}
		
		removePicture( pic )
		{
			This.visiblePictures.Delete( &pic )
		}
		
		getVisiblePictures()
		{
			return This.visiblePictures
		}
		
		touch()
		{
			This.hChanged := 1
		}
		
		resetHasChanged()
		{
			This.hChanged := 0
		}
		
		hasChanged()
		{
			return This.hChanged
		}
		
		getID()
		{
			return This.layerID
		}
		
	}
	
}



class displayBackendAPI
{
	
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
		This.createPictureStorage()
		This.createBuffers()
		This.createNotificationQueue()
	}
	
	__Delete()
	{
		This.freeBuffers()
		This.freePictureStorage()
		This.freeAPI()
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
		This.display := new indirectReference( connectedDisplay )
	}
	
	getDisplay()
	{
		return This.display
	}
	
	getTargetSize()
	{
		return This.getDisplay().getTargetSize()
	}
	
	getTargetHWND()
	{
		return This.getDisplay().getTargetHWND()
	}
	
	getFieldSize()
	{
		return This.getDisplay().getFieldSize()
	}
	
	getDrawStyle()
	{
		return This.getDisplay().getDrawStyle()
	}
	
	createPictureStorage()
	{
		This.loadedPics := []
	}
	
	isLoaded( pictureFile )
	{
		return This.loadedPics.hasKey( pictureFile )
	}
	
	loadPicture( pictureFile )
	{
		if !This.isLoaded( pictureFile )
			if isObject( pic := This.APIloadPicture( pictureFile ) )
				This.loadedPics[ pictureFile ] := pic
	}
	
	freePicture( pictureFile )
	{
		This.loadedPics.Delete( pictureFile )
	}
	
	createNotificationQueue()
	{
		This.notificationQueue := []
	}
	
	notifyDrawStyle()
	{
		This.notify( "updateDrawStyle" )
	}
	
	notifyTarget()
	{
		This.notify( "updateTarget" )
	}
	
	notifyField()
	{
		This.notify( "updateField" )
	}
	
	notify( option )
	{
		if ( !This.notificationQueue.hasKey( option ) && isFunc( This[ option ] ) )
			This.notificationQueue[ option ] := This[ option ]
	}
	
	handleNotifications()
	{
		For each, function in This.notificationQueue
			function.Call( This )
	}
	
}

/*
	class gdipAPI
	description:	This is a class used by the displayClass as Backend to display the pictures
	No need to understand it
*/

class gdipAPI extends displayBackendAPI
{
	
	loadAPI()
	{
		This.api := new GDIp()
	}
	
	freeAPI()
	{
		This.Delete( "api" )
	}
	
	createBuffers()
	{
		This.zBuffers    := {}
		This.frameBuffer := new This.ZBuffer()
		This.frameBuffer.setDrawStyle( "Pixel" )
	}
	
	getBuffer( zLayerID )
	{
		if !This.zBuffers.HasKey( zLayerID )
		{
			zBuffer := new This.ZBuffer()
			zBuffer.setSize( This.getBufferSize() )
			zBuffer.setDrawStyle( This.getBufferDrawStyle() )
			This.zBuffers[ zLayerID ] := zBuffer
		}
		return This.zBuffers[ zLayerID ]
	}
	
	updateTarget()
	{
		This.setBufferSize( This.getTargetSize() )
	}
	
	setBufferSize( size )
	{
		This.bufferSize := size
		For each, zBuffer in This.zBuffers
			zBuffer.setSize( size )
		This.frameBuffer.setSize( size )
		This.updateField()
	}
	
	getBufferSize()
	{
		return This.bufferSize
	}
	
	updateDrawStyle()
	{
		This.setBufferDrawStyle( This.getDrawStyle() )
	}
	
	setBufferDrawStyle( drawStyle )
	{
		This.drawStyle := drawStyle
		For each, zBuffer in This.zBuffers
			zBuffer.setDrawStyle( size )
	}
	
	getBufferDrawStyle( drawStyle )
	{
		return This.drawStyle
	}
	
	updateField()
	{
		This.setBufferFieldSize( This.getFieldSize() )
	}
	
	setBufferFieldSize( fieldSize )
	{
		This.fieldSize := fieldSize
		pixelSize :=  This.getBufferSize()
		This.mul := [ pixelSize.1 / fieldSize.1, pixelSize.2 / fieldSize.2 ]
		This.add := [ -This.mul.1 / 2, -This.mul.2 / 2 ]
	}
	
	getBufferFieldSize()
	{
		return This.fieldSize
	}
	
	APIloadPicture( pictureFile )
	{
		return new GDIp.Bitmap( pictureFile )
	}
	
	fieldToPixel( pic )
	{
		pos     := pic.getPosition()
		size    := pic.getSize()
		return [ Round( ( pos.1 - size.1 / 2  ) * This.mul.1 + This.add.1 ), Round( ( pos.2 - size.2 / 2  ) * This.mul.2 + This.add.2 ), Round( size.1 * This.mul.1 ), Round( size.2 * This.mul.2 ) ]
	}
	
	prepareFrame()
	{
		This.handleNotifications()
	}
	
	drawZLayer( zLayer )
	{
		zBuffer := This.getBuffer( zLayer.getID() )
		if ( zBuffer.hasChanged() || zLayer.hasChanged() )
		{
			This.redraw := 1
			Graphics    := zBuffer.getGraphics()
			Graphics.clear()
			pics        := zLayer.getVisiblePictures()
			For each, pic in pics
			{
				Bitmap := This.loadedPics[ pic.getFile() ]
				size := Bitmap.getSize()
				rect := [ 0, 0, size.1, size.2 ]
				Graphics.drawBitmap( Bitmap, This.fieldToPixel( pic ), rect )
			}
		}
	}
	
	flushFrame()
	{
		frameBuffer := This.frameBuffer
		Graphics := frameBuffer.getGraphics()
		size := This.getBufferSize()
		rect := [ 0, 0, size.1, size.2 ]
		if ( This.redraw )
		{
			Graphics.clear( 0xFF000000 )
			for each, zBuffer in This.zBuffers
				Graphics.drawBitmap( zBuffer.getBitmap(), rect, rect  )
			This.redraw := 0
		}
		targetSize := This.getTargetSize()
		targetRect := [ 0, 0, targetSize.1, targetSize.2 ]
		DC := new GDI.DC( This.getTargetHWND() )
		Graphics := DC.getGrapics()
		Graphics.drawBitmap( frameBuffer.getBitmap(), targetRect, rect )
	}
	
	class ZBuffer
	{
		
		setSize( size )
		{
			This.size := size
			This.bitmap := new GDIp.Bitmap( size* )
			This.setDrawStyle()
			This.touch()
		}
		
		setDrawStyle( drawStyle = "" )
		{
			If ( !drawStyle || ( ( drawStyle != This.drawStyle  ) && This.drawStyle := drawStyle ) )
			{
				This.getGraphics().setSmoothingMode( { Pixel:3, Smooth:1 }[ This.drawStyle ] )
				This.getGraphics().setInterpolationMode( { Pixel:5, Smooth:3 }[ This.drawStyle ] )
				This.touch()
			}
		}
		
		getGraphics()
		{
			return This.bitmap.getGraphics()
		}
		
		getBitmap()
		{
			return This.bitmap
		}
		
		touch()
		{
			This.hChanged := 1
		}
		
		hasChanged()
		{
			return This.hChanged
		}
		
		resetHasChanged()
		{
			This.hChanged := 0
		}
		
	}
	
}