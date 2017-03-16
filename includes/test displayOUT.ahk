#include logError.ahk
#include displayOut.ahk

SetBatchLines,-1

GUI,Add,Picture,w300 h300
GUI +hwndhOut +Resize
Gui,Show

if !isObject( testDisplay := new display( hOut + 0, [ 5, 5 ] ) )
	logError( "failed to create Test display", "", 4 )
;The first step of outputting pictures using the display API is by creating a new display Object
;The first parameter is a HWND that is used to output the video info to
;The second parameter is the size of the field of the display Object

testPic := testDisplay.addPicture( "test.png" )
;Then you can add pictures to the display using the addPicture function of the display
;With the returned object you can modify how the picture should be displayed and where

testPic.setPosition( [ 3, 3 ] )
;This sets the position of the picture

testDisplay.setAutoRedraw( 1 )
;By enabling auto redraw the display get's updated automatically every time the picture changes

testPic.setVisible( 1 )
;Makes the picture visible

Loop, 5
{
	testPic.setSize( [ A_Index, A_Index ] )
	;Changes the picture size
	sleep 1000
}
GuiSize:
testDisplay.notifyChange()
;notifies the display that something changed
return