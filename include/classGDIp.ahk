/*
	API GDIp
	author:			nnnik
	
	description:	A class based wrapper around the GDI+ API based on gdip.ahk made by tick
	
	general:		I don't feel like creating a documentation for this right now
*/
#include %A_LineFile%\..\indirectReference.ahk

class GDIp
{
	
	static openObjects := []
	static references  := 0
	
	__New()
	{
		if !( GDIp.hasKey( "refObj" ) )
		{
			refObj := { base:{ __Delete: GDIp.DeleterefObj } }
			if !( GDIp.Startup() )
				return
			GDIp.refObj := &refObj
			return refObj
		}
		return Object( GDIp.refObj )
	}
	
	DeleterefObj()
	{
		GDIp.Delete( "refObj" )
		GDIp.Shutdown()
	}
	
	Startup()
	{
		if !( GDIp.references++ )
		{
			if !( DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" ) )
				if !( DllCall( "LoadLibrary", "Str", "gdiplus" ) )
					return 0
			VarSetCapacity( si, A_PtrSize = 8 ? 24 : 16, 0 )
			si := Chr(1)
			DllCall( "gdiplus\GdiplusStartup","Ptr*", pToken, "Ptr", &si, "Ptr", 0 )
			if ( pToken )
				GDIp.Token := pToken
			return pToken
		}
	}
	
	Shutdown()
	{
		if ( !( --GDIp.references ) )
		{
			For each, GDIpObject in GDIp.openObjects
				GDIpObject.__Delete()
			DllCall( "gdiplus\GdiplusShutdown", "Ptr", GDIp.Token )
			if ( hModule := DllCall( "GetModuleHandle", "Str", "gdiplus", "Ptr" ) )
				DllCall( "FreeLibrary", "Ptr", hModule )
		}
	}
	
	class Bitmap
	{
		
		__New( filePathOrW, h = "" )
		{
			if fileExist( filePathOrW )
			{
				ret := DllCall( "gdiplus\GdipCreateBitmapFromFile", "WStr", filePathOrW, "Ptr*", pBitmap )
				DllCall( "gdiplus\GdipGetImageWidth",  "Ptr", pBitmap, "UInt*", w )
				DllCall( "gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", h )
			}
			else if ( ( w := filePathOrW ) > 0 && h > 0 )
				ret := DllCall( "gdiplus\GdipCreateBitmapFromScan0", "UInt", w, "UInt", h, "UInt", 0, "UInt", 0x26200A, "Ptr", 0, "Ptr*", pBitmap )
			if !( ret = 0 )
				return ret
			This.ptr := pBitmap
			This.w   := w
			This.h   := h
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			if ( This.hasKey( "pGraphics" ) )
				This.pGraphics.__Delete()
			DllCall("gdiplus\GdipDisposeImage", "Ptr", This.ptr )
			GDIp.unregisterObject( This )
			This.base := "" ;prevent all bad calls to gdiplus.dll by disconnecting the base and freeing all references towards such functions from the object
		}
		
		getGraphics()
		{
			if !( This.hasKey( "pGraphics" ) )
			{
				This.pGraphics := new GDIp.Graphics( This )
			}
			return This.pGraphics
		}
		
		getpBitmap()
		{
			return This.ptr
		}
		
		getSize()
		{
			return [ This.w, This.h ]
		}
		
		saveToFile( fileName )
		{
			RegExMatch( fileName, "\.\w$", Extension )
			DllCall( "gdiplus\GdipGetImageEncodersSize", "UInt*", nCount, "UInt*", nSize )
			VarSetCapacity( ci, nSize )
			DllCall( "gdiplus\GdipGetImageEncoders", "UInt", nCount, "UInt", nSize, "Ptr", &ci )
			Loop, %nCount%
			{
				sString := StrGet( NumGet( ci, ( idx := ( 48 + 7 * A_PtrSize ) * ( A_Index - 1 ) ) + 32 + 3 * A_PtrSize ), "UTF-16" )
				if InStr( sString, "*" . Extension )
				{
					pCodec := &ci+idx
					break
				}
			}
			DllCall("gdiplus\GdipSaveImageToFile", "Ptr", This.ptr, "WStr", fileName, "Ptr", pCodec, "UInt", 0)
		}
	}
	
	class Graphics
	{
		
		__New( bitmapOrDC )
		{
			if ( pBitmap := bitmapOrDC.getpBitmap() )
				ret := DllCall( "gdiplus\GdipGetImageGraphicsContext", "Ptr", pBitmap, "Ptr*", pGraphics )
			else if ( hDC := bitmapOrDC.gethDC() )
				ret := DllCall( "gdiplus\GdipCreateFromHDC", "Ptr", hDC, "Ptr*", pGraphics )
			if !( ret = 0 )
				return ret
			This.ptr := pGraphics
			GDIp.registerObject( This )
		}
		
		__Delete()
		{
			GDIp.unregisterObject( This )
			DllCall( "gdiplus\GdipDeleteGraphics", "Ptr", This.ptr )
			This.base := ""
		}
		
		drawBitmap( Bitmap, tRect , sRect )
		{
			return DllCall( "gdiplus\GdipDrawImageRectRect", "Ptr", This.ptr, "Ptr", Bitmap.getpBitmap(), "float", tRect.1, "float", tRect.2, "float", tRect.3, "float", tRect.4, "float", sRect.1, "float", sRect.2, "float", sRect.3, "float", sRect.4, "UInt", 2, "Ptr", 0, "Ptr", 0, "Ptr", 1 )
		}
		
		; Default = 0
		; HighSpeed = 1
		; HighQuality = 2
		; None = 3
		; AntiAlias = 4
		
		setSmoothingMode( smoothingMode )
		{
			return DllCall( "gdiplus\GdipSetSmoothingMode", "Ptr", This.ptr, "Int", smoothingMode )
		}
		
		; Default = 0
		; LowQuality = 1
		; HighQuality = 2
		; Bilinear = 3
		; Bicubic = 4
		; NearestNeighbor = 5
		; HighQualityBilinear = 6
		; HighQualityBicubic = 7
		
		setInterpolationMode( interpolationMode )
		{
			return DllCall( "gdiplus\GdipSetInterpolationMode", "Ptr", This.ptr, "Int", interpolationMode )
		}
		
		clear( color = 0 )
		{
			return DllCall("gdiplus\GdipGraphicsClear", "Ptr", This.ptr, "UInt", color )
		}
		
		getpGraphics()
		{
			return This.ptr
		}
		
	}
	
	registerObject( Object )
	{
		This.openObjects[ &Object ] := new indirectReference( Object , { __Delete: 1 } )
	}
	
	unregisterObject( Object )
	{
		This.openObjects.Delete( &Object )
	}
	
}

class GDI
{
	class DC
	{
		
		__New( hWND )
		{
			if !hDC  := DllCall( "GetDC", "Ptr", hWND, "Ptr" )
				return
			This.hWND := hWND
			This.hDC  := hDC
		}
		
		__Delete()
		{
			This.Graphics.__Delete()
			DllCall( "ReleaseDC", "Ptr", This.hWND, "Ptr", This.hDC )
			This.base := ""
		}
		
		gethDC()
		{
			return This.hDC
		}
		
		getGrapics()
		{
			if !( This.hasKey( "pGraphics" ) )
				This.pGraphics := new GDIp.Graphics( This )
			return This.pGraphics
		}
		
	}
}