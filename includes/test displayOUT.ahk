#include logError.ahk
#include displayOut.ahk

SetBatchLines,-1

GUI,Add,Picture,w300 h300
GUI +hwndhOut +Resize
Gui,Show
if !isObject( testDisplay := new display( hOut + 0, [ 5, 5 ] ) )
	logError( "failed to create Test display", "", 4 )
testPic := testDisplay.addPicture( "test.png" )
testPic.setPosition( [ 3, 3 ] )
testDisplay.setAutoRedraw( 1 )
testPic.setVisible( 1 )

Loop, 5
{
	testPic.setSize( [ A_Index, A_Index ] )
	
	sleep 1000
}
GuiSize:
testDisplay.notifyChange()
return