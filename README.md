# Project 2D
Tile-based 2D game engine created using AutoHotkey.

## Introduction
Project 2D is a tile-based 2D game engine created using AutoHotkey. Its purpose is to allow users to create games using only a text editor and basic image editing.

According to Wikipedia:

> "A tile-based video game is a type of video or video game where the playing area consists of small rectangular, square, or hexagonal graphic images, referred to as tiles. The complete set of tiles available for use in a playing area is called a tileset. Tiles are laid out adjacent to one another in a grid; usually, some tiles are allowed to overlap, for example, when a tile representing a unit is overlaid onto a tile representing terrain. Tile-based games usually simulate a top-down or "2.5D" view of the playing area, and are almost always two-dimensional."

[https://en.wikipedia.org/wiki/Tile-based_video_game](https://en.wikipedia.org/wiki/Tile-based_video_game)

## Getting Started
Before you can begin creating your first game, you'll need to download the current release of the Project 2D engine. The download links are available at the end of this post.

After you've downloaded the compressed zip archive, you'll need to extract the files to a directory on your computer. The Windows operating system should be capable of handling files with the zip extension, however you may download a third-party software such as 7-Zip to open the archive.

Project 2D is configured with an initial demonstration game as an example of how to use image and text files to create a multi-room level, and interact with the game environment.

## Creating Backgrounds
The background is the image file that will be display behind the player. It's used to create the environment of the level, to create the appearance of a room or objects... The display area of the game is 640x640 pixels, using a 20x20 grid of 32x32 pixel tiles. The background image must match these dimensions to fit accurately in the game window.

A background can be created in any image editor, but I recommend using a tiled map editor when possible. A tiled map editor is like a stamping tool, allowing background images to be created and edited with ease. Visit one of the following links for more information:

- [Tiled](http://www.mapeditor.org)
- [tIDE](https://tide.codeplex.com)
- [Mappy](http://tilemap.co.uk/mappy.php)
- [DAME](http://dambots.com/dame-editor/)
- [Tile Studio](http://tilestudio.sourceforge.net)
- [TuDee](http://www.diorgo.com/v1/?p=366)
- [Ogmo](http://www.ogmoeditor.com)
- [SGDK2](http://sgdk2.sourceforge.net)
- [Tat](https://web.archive.org/web/20130207022709/http://kotisivu.dnainternet.net/ttilli/tilemapeditor/main.htm)
- [TileMapper](https://web.archive.org/web/20101115043454/http://www.tilemapper.com/)
- [TileME](https://sourceforge.net/projects/tilemapeditor2d/)

Source: [http://www.tilemapeditor.com/](http://www.tilemapeditor.com/)

To use a tiled map editor, you must have a tile map image (or collection of images). The tile map used in the demonstration is provided at the end of this post.

## ASCII Maps
Project 2D uses text files to store information used for interacting with the current background image. This is where you define the boundaries of the room and location of objects, etc... Each 32x32 pixel tile of your background image can be assigned a numerical value of 0-9 which can be used to trigger an action when the player is occupying the space at that tile's coordinates.

You can create and edit the ASCII map files using a text editor, or you may use the ASCII Map Editor script that is attached at the end of this post.

Note that while the main window uses a 20x20 grid, the ASCII maps use a 22x22 grid to allow the player object to trigger an action while outside of window's viewable area.

## Additional Resources
Many websites are devoted to sharing resources to assist you with building assets for your games, or just to provide inspiration. A few examples are listed below:

- OpenGameArt - [http://opengameart.org/](http://opengameart.org/)
- Bfxr - [http://www.bfxr.net/](http://www.bfxr.net/)
- Kenney - [http://kenney.nl/assets](http://kenney.nl/assets)
- Title Scream - [http://www.titlescream.com/](http://www.titlescream.com/)
- NES Title Screens - [http://nestitlescreens.tumblr.com/](http://nestitlescreens.tumblr.com/)
- NFG's Arcade Font Tool - [http://nfggames.com/games/fontmaker/](http://nfggames.com/games/fontmaker/)
- Arcade Font Writer - [http://arcade.photonstorm.com/](http://arcade.photonstorm.com/)
- Scirra Forums - [https://www.scirra.com/forum/](https://www.scirra.com/forum/)
- Develteam - [http://www.develteam.com/](http://www.develteam.com/)
- The VG Resource - [http://www.vg-resource.com/](http://www.vg-resource.com/)

## Special Thanks
A special thank you and show of appreciation to those that have contributed to this project:

- [GeekDude](https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=161) - ASCII map support
- [SnowFlake](https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=63313)/[joedf](https://autohotkey.com/boards/memberlist.php?mode=viewprofile&u=55) - ASCII map editor suggestions

*Please share any suggestions or ideas for improvement. It's always appreciated!*

## Screenshots
[Title Screen (640 x 640 px)](https://i.imgur.com/Anxokm6.png)  
[Floor 3 (640 x 640 px)](https://i.imgur.com/euWbCTN.png)  
[ASCII Map Editor (720x 762px)](https://i.imgur.com/uzVME5O.png)

## Downloads
**Project 2D**  
*The most recent release of Project 2D*  
[Project2D_rev2.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/Project2D_rev2.zip) (337 KB) - *March 13, 2017*

**ASCII Map Editor**  
*Visual editor for creating and editing the ASCII map files*  
[MapEdit_rev2.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/MapEdit_rev2.zip) (5.84 KB) - *March 13, 2017*

**Demo Tilemap**  
*Images collected from various sources*  
[Demo_Tilemap.png](https://github.com/westoncampbell/Project2D/releases/download/Archive/Demo_Tilemap.png) (7.85 KB) - *June 08, 2016*

**Archive**  
*These files are outdated and kept for archival purposes only. Please refer to the most recent releases for the latest additions and improvements.*  
[Project2D_rev1.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/Project2D_rev1.zip) (92.8 KB) - *June 08, 2016*  
[Project_2D_20150507002944.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/Project_2D_20150507002944.zip) (215 KB) - *May 07, 2015*  
[Project_2D_20150505210148.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/Project_2D_20150505210148.zip) (12 KB) - *May 05, 2015*  
[MapEdit_rev1.zip](https://github.com/westoncampbell/Project2D/releases/download/Archive/MapEdit_rev1.zip) (3.29 KB) - *June 14, 2016*
