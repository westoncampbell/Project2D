#include include\logError.ahk
#include include\displayOut.ahk

SetBatchLines,-1

Msgbox A small Test Script to showcase the displayOut API`nControls:`nwasd: move Player`nqe:   change Players size`nf:    rotate Player

mapGrid 		:= []

GUI,Add,Picture,w300 h300
GUI +hwndhOut +Resize
Gui,Show

if !isObject( displayOutput := new display( hOut + 0, [ 5, 5 ] ) )
	logError( "failed to create display", "", 4 )
;The first step of outputting pictures using the display API is by creating a new display Object
;The first parameter is a HWND that is used to output the video info to
;The second parameter is the size of the field of the display Object

mapPic    := displayOutput.addPicture( "resources\images\bg_title.png", [ 3, 3, 1 ], [ 5, 5 ] )
;Then you can add pictures to the display using the addPicture function of the display
;With the returned object you can modify how the picture should be displayed and where
;This creates a picture from the file "resources\images\bg_title.png" at the position [ 3, 3, 1 ] and the size [ 5, 5 ]

playerPic := displayOutput.addPicture( "resources\images\player_up.png", [ 3, 3, 3 ] )
;This creates a picture from the file "resources\images\player_up.png"
;Also sets the position of the picture to [ 3, 3, 2 ]

mapPic.setVisible( 1 )
;Makes the map visible

playerPic.setVisible( 1 )
;Makes the player visible

displayOutput.setAutoRedraw( 1 )
;By enabling auto redraw the display get's updated automatically every time the picture changes

playerDirection := 1
playerFiles     := [ "resources\images\player_up.png", "resources\images\player_left.png", "resources\images\player_down.png", "resources\images\player_right.png" ]

#if WinActive( "ahk_id " . hOut )
f::playerPic.setFile( playerFiles[ playerDirection := mod( playerDirection, 4 ) + 1 ] )
;Changes the players Picture/Direction

e::size := playerPic.getSize(), playerPic.setSize( [ mod( size.1, 5 ) + 1, mod( size.2, 5 ) + 1 ] )
q::size := playerPic.getSize(), playerPic.setSize( [ mod( size.1 - 6, 5 ) + 5, mod( size.2 - 6, 5 ) + 5 ] )
;Changes the size of the player depending on 

w::pos := playerPic.getPosition(), playerPic.setPosition( [ pos.1, mod( pos.2 - 6 , 5 ) + 5 ] )
s::pos := playerPic.getPosition(), playerPic.setPosition( [ pos.1, mod( pos.2, 5 ) + 1 ] )
a::pos := playerPic.getPosition(), playerPic.setPosition( [ mod( pos.1 - 6 , 5 ) + 5 , pos.2 ] )
d::pos := playerPic.getPosition(), playerPic.setPosition( [ mod( pos.1, 5 ) + 1, pos.2 ] )
;Changes the position of the player depending on the old Position

Enter::
pos := playerPic.getPosition()
pArray := createExplosion( displayOutput, playerPic.getFile(), [ pos.1, pos.2, 2 ] )
return

updateParticle:
updateParticles( pArray )
return

GuiSize:
displayOutput.notifyChange()
;notifies the display that something changed
return

GuiClose:
ExitApp

createExplosion( display, pictureFile, spawnPosition, nr= "" )
{
	if !nr
		Random, nr, 5, 10
	autoRedraw := display.getAutoRedraw()
	display.setAutoRedraw( 0 )
	pArray := { lastUpdated:A_TickCount, particles:[] }
	Loop % nr
	{
		Random, direction, 0, 360
		Random, velocity,  30,100
		velocity  := velocity/75
		direction := direction * aTan( 1 )/45
		particle  := { direction:[ sin( direction ), cos( direction ) ], velocity:velocity, pic:display.addPicture( pictureFile, spawnPosition ) }
		particle.pic.setVisible( 1 )
		pArray.particles.push( particle )
	}
	SetTimer,updateParticle, -1
	display.setAutoRedraw( autoRedraw )
	return pArray
}

updateParticles( pArray )
{
	timeElapsed := ( A_TickCount - pArray.lastUpdated ) / 1000
	toDelete := []
	decay := 0.3
	autoRedraw := display.getAutoRedraw()
	display.setAutoRedraw( 0 )
	For each, particle in pArray.particles
	{
		if ( particle.velocity - decay * timeElapsed < 0 )
		{
			pArray.particles.Delete( each )
			continue
		}
		pos   := particle.pic.getPosition()
		pos.1 += ( particle.velocity - ( decay * timeElapsed / 2 ) ) * particle.direction.1 * timeElapsed
		pos.2 += ( particle.velocity - ( decay * timeElapsed / 2 ) ) * particle.direction.2 * timeElapsed
		particle.pic.setPosition( pos )
		particle.velocity -= decay * timeElapsed
	}
	if ( pArray.particles._NewEnum().Next( k, v ) )
		SetTimer,updateParticle, -1
	display.setAutoRedraw( autoRedraw )
}