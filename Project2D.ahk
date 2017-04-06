; Script Information ===========================================================
; Name:        Project 2D
; Description: Example of a tile-based game engine using AutoHotkey
; AHK Version: AHK_L 1.1.25.01 (Unicode 32-bit) - March 5, 2017
; OS Version:  Windows 2000+
; Language:    English - United States (en-US)
; Author:      Weston Campbell <westoncampbell@gmail.com>
; Website:     https://autohotkey.com/boards/viewtopic.php?f=6&t=7348
; ==============================================================================

; Revision History =============================================================
; Revision 2 (March 13, 2017)
; * Complete rewrite
; ------------------------------------------------------------------------------
; Revision 1 (June 08, 2016)
; * Initial Release
; ==============================================================================

; Auto-Execute =================================================================
#SingleInstance, Force ; Allow only one running instance of script
#Persistent ; Keep the script permanently running until terminated
#NoEnv ; Avoid checking empty variables for environment variables
#NoTrayIcon ; Disable the tray icon of the script
#Include include\displayOut.ahk
SendMode, Input ; The method for sending keystrokes and mouse clicks
SetWorkingDir, %A_ScriptDir% ; Set the working directory of the script
SetBatchLines, -1 ; The speed at which the lines of the script are executed
SetWinDelay, -1 ; The delay to occur after modifying a window
SetControlDelay, -1 ; The delay to occur after modifying a control
OnExit("OnUnload") ; Run a subroutine or function when exiting the script
SetTimer,Redraw,16
return ; End automatic execution
; ==============================================================================

; Labels =======================================================================
;GuiEscape:
GuiClose:
ExitSub:
    ExitApp ; Terminate the script unconditionally
return
; ==============================================================================

; Functions ====================================================================
OnLoad() {
    Global ; Assume-global mode
    Static Init := OnLoad() ; Call function

    OnMessage(0x0100, "WM_KEYDOWN")
}

OnUnload(ExitReason, ExitCode) {
    Global ; Assume-global mode
}

WM_KEYDOWN(wParam, lParam, Msg, Hwnd) {
    Global ; Assume-global mode
    Static VK_UP := 26, VK_LEFT := 25, VK_DOWN := 28, VK_RIGHT := 27,
    VK_KEY_W := 57, VK_KEY_A := 41, VK_KEY_S := 53, VK_KEY_D := 44,
    VK_F1 := 70, VK_RETURN := "D",  VK_ESCAPE := "1B"

    If (lParam & 0x40000000) {
        return ; Disable auto-repeat
    }

    VK := Format("{:x}", wParam)

    If (VK = VK_UP) || (VK = VK_KEY_W) {
        Hero.Move(0, -1, true)
    }

    If (VK = VK_LEFT) || (VK = VK_KEY_A) {
        Hero.Move(-1, 0, true)
    }

    If (VK = VK_DOWN) || (VK = VK_KEY_S) {
        Hero.Move(0, 1, true)
    }

    If (VK = VK_RIGHT) || (VK = VK_KEY_D) {
        Hero.Move(1, 0, true)
    }

    If (VK = VK_RETURN) {
        GridAction("VK_RETURN")
    }

    If (VK = VK_F1) {
        GuiControlGet, DebugVisible, Visible, Debug
        GuiControl, % (!DebugVisible ? "Show" : "Hide"), Debug
    }

    If (VK = VK_ESCAPE) {
        GoSub, ExitSub
    }
}

GuiCreate() {
	Global ; Assume-global mode
	Static Init := GuiCreate() ; Call function
	
	Menu, Tray, Icon, resources\images\icon.ico
	Gui, +LastFound -Resize +HWNDhProject2D
	Gui, Margin, 10, 10
	Gui, Add, Edit, x0 y0 w0 h0 0x800 ; Focus
	;Gui, Add, Text, x10 y10 w620 r3 cFFFFFF vDebug BackgroundTrans
	;GuiControl, Hide, Debug
	Gui, Show, w640 h640, Project 2D
	
	displayOut := new display( hProject2D, [ 20, 20 ] )
	
	Stage := new Stage( displayOut )
	Stage.Color("000000")
	Stage.Background("bg_title.png")
     Stage.Map("map_0000.map")
	
	Hero := new Player( displayOut )
	Hero.Move(-1, -1, false)
}

GridAction(Action := "") {
    Global ; Assume-global mode

    If (GridType = 1) {
        Hero.Move(PX, PY, false)
        return
    }

    If (Map = "map_0000.map") {
        If (Action = "VK_RETURN") {
            Stage.Background("bg_0001.png")
            Stage.Map("map_0001.map")
            Hero.Move(9, 11, false)
            return
        }
    }

    If (Map = "map_0001.map") {
        If (GridType = 2) { ; Go to next map
            Stage.Background("bg_0002.png")
            Stage.Map("map_0002.map")
            Hero.Move(PX, 19, false)
            return
        }
    }

    If (Map = "map_0002.map") {
        If (GridType = 2) { ; Go to previous map
            Stage.Background("bg_0001.png")
            Stage.Map("map_0001.map")
            Hero.Move(PX, 0, false)
            return
        }

        If (GridType = 3) { ; Go to next map
            Stage.Background("bg_0003.png")
            Stage.Map("map_0003.map")
            Hero.Move(PX, 19, false)
            return
        }
    }

    If (Map = "map_0003.map") {
        If (GridType = 2) { ; Go to previous map
            Stage.Background("bg_0002.png")
            Stage.Map("map_0002.map")
            Hero.Move(PX, 0, false)
            return
        }

        If (GridType = 3) { ; Fell in hole
            Hero.Move(10, 19, false)
            return
        }

        If (GridType = 4) { ; Go to next map
            Stage.Background("bg_0004.png")
            Stage.Map("map_0004.map")
            Hero.Move(16, 15, false)
            return
        }
    }

    If (Map = "map_0004.map") {
        If (GridType = 2) { ; Go to previous map
            Stage.Background("bg_0003.png")
            Stage.Map("map_0003.map")
            Hero.Move(8, 10, false)
            return
        }

        If (GridType = 3) { ; AutoHotkey "A" icon
            Stage.Background("bg_0004_2.png")
            Stage.Map("map_0004_2.map")
            return
        }
    }

    If (Map = "map_0004_2.map") {
        If (GridType = 2) { ; Go to next map
            Stage.Background("bg_0005.png")
            Stage.Map("map_0005.map")
            Hero.Move(19, PY, false)
            return
        }
    }

    If (Map = "map_0005.map") {
        If (GridType = 2) { ; Go to previous map
            Stage.Background("bg_0004_2.png")
            Stage.Map("map_0004_2.map")
            Hero.Move(0, PY, false)
            return
        }

        If (GridType = 3) { ; Key item
            Stage.Background("bg_0005_2.png")
            Stage.Map("map_0005_2.map")
            return
        }
    }

    If (Map = "map_0005_2.map") {
        If (GridType = 2) { ; AutoHotkey "H" icon
            Stage.Background("bg_0005_3.png")
            Stage.Map("map_0005_3.map")
            return
        }
    }

    If (Map = "map_0005_3.map") {
        If (GridType = 2) { ; Go to next map
            Stage.Background("bg_0006.png")
            Stage.Map("map_0006.map")
            Hero.Move(PX, 0, false)
            return
        }
    }

    If (Map = "map_0006.map") {
        If (GridType = 2) { ; Go to previous map
            Stage.Background("bg_0005_3.png")
            Stage.Map("map_0005_3.map")
            Hero.Move(PX, 19, false)
            return
        }

        If (GridType = 3) { ; Key item
            Stage.Background("bg_0006_2.png")
            Stage.Map("map_0006_2.map")
            return
        }
    }

    If (Map = "map_0006_2.map") {
        If (GridType = 2) { ; AutoHotkey "K" icon
            Stage.Background("bg_0006_3.png")
            Stage.Map("map_0006_3.map")
            return
        }
    }

    If (Map = "map_0006_3.map") {
        If (GridType = 2) { ; Go to next map
            Stage.Background("bg_0007.png")
            Stage.Map("map_0007.map")
            Hero.Move(9, 13, false)
            return
        }
    }

    If (Map = "map_0007.map") {
        If (GridType = 2) { ; AutoHotkey icon
            Stage.Background("bg_0008.png")
            Stage.Map("map_0008.map")
            Hero.Move(-1, -1, false)
            return
        }
    }
}

Class Stage {
	__New( displayOut ) {
		size       := displayOut.getFieldSize()
		this.Stage := displayOut.addPicture( "resources\images\bg_title.png", [ size.1/2 + 0.5, size.2/2 + 0.5 ,1 ], [ size.1, size.2 ] )
		Msgbox % disp( This.stage )
		this.Stage.setVisible( 1 )
	}
	
	Background(File) {
		this.Stage.setFile( "resources\images\" . File )
	}
	
	Map(File) {
		Global ; Assume-global mode
		
		GridMap := []
		
		FileRead, MapData, % "resources\maps\" (Map := File)
		
		For Each, Line In StrSplit(MapData, "`n", "`r") {
			GridMap.Push(StrSplit(Line))
		}
	}
}

Class Player {
	__New( displayOut ) {
		this.Player := displayOut.addPicture( "resources\images\player_up.png", [ 1, 1, 2 ], [ 0.9, 0.9 ] )
		this.Visible()
	}
	
	Visible(Show := true) {
		this.Player.setVisible( Show )
	}
	
	Image(File) {
		this.Player.setFile( "resources\images\" . File )
	}
	
	Move(X, Y, Relative := 0) {
		Global ; Assume-global mode
		
		pos := this.Player.getPosition()
		PX := pos.1 - 1
		PY := pos.2 - 1
		X := (Relative ? PX + X : X), Y := (Relative ? PY + Y : Y)
		GridType := GridMap[Y + 2, X + 2]
		GuiControl,, Debug, %X%, %Y%`n%Background%`n%Map% ; Debug info
		if Relative
		{
			If (Y < PY) {
				this.Image("player_up.png")
			}
			If (X < PX) {
				this.Image("player_left.png")
			}
			If (Y > PY) {
				this.Image("player_down.png")
			}
			If (X > PX) {
				this.Image("player_right.png")
			}
		}
		this.Player.setPosition( [ X + 1, Y + 1, 2 ] )
		GridAction("Move")
	}
}
; ==============================================================================

Redraw:
displayOut.draw()
return