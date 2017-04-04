#include include\logError.ahk
#include include\displayOut.ahk

SetBatchLines,-1

Msgbox A small Test Script to showcase the displayOut API`nControls:`nwasd: move Player`nqe:   change Players size`nf:    rotate Player`nEnter: suprise 

mapGrid 		:= []

GUI,Add,Picture,w300 h300
GUI +hwndhOut +Resize
GUI,Show
if !isObject( displayOutput := new display( hOut + 0, [ 20, 20 ] ) )
	logError( "failed to create display", "", 4 )
	;The first step of outputting pictures using the display API is by creating a new display Object
	;The first parameter is a HWND that is used to output the video info to
	;The second parameter is the size of the field of the display Object
fieldSize := displayOutput.getFieldSize()
mapPic    := displayOutput.addPicture( "resources\images\bg_0001.png", [ fieldSize.1/2 + 0.5 , fieldSize.2/2 + 0.5, 1 ], [ fieldSize.1, fieldSize.2 ] )
	;Then you can add pictures to the display using the addPicture function of the display
	;With the returned object you can modify how the picture should be displayed and where
	;This creates a picture from the file "resources\images\bg_title.png" at the position [ 3, 3, 1 ] and the size [ 5, 5 ]

playerPic := displayOutput.addPicture( "resources\images\player_up.png", [ 3, 3, 3 ], [ 0.9, 0.9 ] )
	;This creates a picture from the file "resources\images\player_up.png"
	;Also sets the position of the picture to [ 3, 3, 2 ]

mapPic.setVisible( 1 )
	;Makes the map visible

playerPic.setVisible( 1 )
	;Makes the player visible

playerDirection := 1
playerFiles     := [ "resources\images\player_up.png", "resources\images\player_left.png", "resources\images\player_down.png", "resources\images\player_right.png" ]
SetTimer,Redraw,16

#if WinActive( "ahk_id " . hOut )
	f::
playerPic.setFile( playerFiles[ playerDirection := mod( playerDirection, 4 ) + 1 ] )
;Changes the players Picture/Direction
return

e::
size      := playerPic.getSize()
fieldSize := displayOutput.getFieldSize()
newSize   := [ mod( size.1, fieldSize.1 ) + 1, mod( size.2, fieldSize.2 ) + 1 ]
playerPic.setSize( newSize )
return

q::
size      := playerPic.getSize()
fieldSize := displayOutput.getFieldSize()
newSize   := [ mod( size.1 - 1 - fieldSize.1 , fieldSize.1 ) + fieldSize.1, mod( size.2 - 1 - fieldSize.2 , fieldSize.2 ) + fieldSize.2 ]
playerPic.setSize( newSize )
return
;Changes the size of the player depending on old Size

w::
pos       := playerPic.getPosition(), 
fieldSize := displayOutput.getFieldSize()
newPos    := [ pos.1,  mod( pos.2 - 1 - fieldSize.2, fieldSize.2 ) + fieldSize.2 , pos.3 ]
playerPic.setPosition( newPos )
return

s::
pos 		:= playerPic.getPosition()
fieldSize := displayOutput.getFieldSize()
newPos	:= [ pos.1, mod( pos.2, fieldSize.2 ) + 1, pos.3 ]
playerPic.setPosition( newPos )
return

a::
pos 		:= playerPic.getPosition()
fieldSize := displayOutput.getFieldSize()
newPos	:= [ mod( pos.1 - 1 - fieldSize.1 , fieldSize.1 ) + fieldSize.1 , pos.2, pos.3 ]
playerPic.setPosition( newPos )
return

d::
pos := playerPic.getPosition(), playerPic.setPosition( [ mod( pos.1, 5 ) + 1, pos.2, pos.3 ] )
fieldSize := displayOutput.getFieldSize()
newPos	:= [ mod( pos.1, fieldSize.1 ) + 1, pos.2, pos.3 ]
playerPic.setPosition( newPos )
return
;Changes the position of the player depending on the old Position

Enter::
pos := playerPic.getPosition()
Particles.createExplosion( displayOutput, playerPic.getFile(), [ pos.1, pos.2, 2 ] )
return

GuiSize:
displayOutput.setTarget( hOut )
;notifies the display that something changed
return

Redraw:
Particles.update( displayOutput )
displayOutput.draw()
return

GuiClose:
ExitApp

class Particles
{
	static particles   := []
	
	createExplosion( display, pictureFile, spawnPosition, nr= "" )
	{
		if !nr
			Random, nr, 5, 10
		Loop % nr
		{
			Random, direction, 0, 360
			Random, velocity,  20,50
			velocity  := velocity/50
			direction := direction * aTan( 1 )/45
			particle  := { direction:[ sin( direction ), cos( direction ) ], velocity:velocity, pic:display.addPicture( pictureFile, spawnPosition ) }
			particle.pic.setVisible( 1 )
			This.particles.push( particle )
		}
	}

	update( display )
	{
		timeElapsed := ( A_TickCount - This.lastUpdated ) / 1000
		This.lastUpdated := A_TickCount
		decay := 0.5
		For each, particle in This.particles
		{
			if ( particle.velocity - decay * timeElapsed < 0 )
			{
				This.particles.Delete( each )
				continue
			}
			pos   := particle.pic.getPosition()
			pos.1 += ( particle.velocity - ( decay * timeElapsed / 2 ) ) * particle.direction.1 * timeElapsed
			pos.2 += ( particle.velocity - ( decay * timeElapsed / 2 ) ) * particle.direction.2 * timeElapsed
			particle.pic.setPosition( pos )
			particle.velocity -= decay * timeElapsed
		}
	}
}