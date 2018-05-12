# ONEMenu for PSVita

![header](screenshots/1MENUVITA.png)

**OneMenu for PSVita** is a simple to use UI which separates the installed games and apps into categories.<br>
Onemenu comes with a built in file explorer which has many advanced features such as installing/uninstalling apps/games, move the selected app/game to diferent partition (ux0-ur0-uma0) connect via ftp or usb to the pc, restart, shutdown, rebuild db.

### Changelog 2.05 ###
- Edit param.sfo (decrypted).<br>
- Fix automatic network update (Add TLS v1.2 Support).<br>
- Updated to the latest version of ONElua.<br>

## ONEMenu icons ##

![header](screenshots/1MENUVITA2.png)

**UP/Down:** Category change (5 categories available: Vita/Hb games, PSM Games, PSP/Hbs Games, PS1 Games, Adrenaline Bubbles).<br>
**L/R:** Fast scrolling.<br>
**Start:** Opens a submenu with a list of system apps.<br>

**Triangle:** Open Submenus<br>

* NOTE: Press L/R to alternate between submenus (options).

#### Submenu 1: <br>

**LiveArea Apps** Allows to install games in ux0:app (Thanks the plugin Nonpdrm from TheFloW).

**Uninstall**     Allows to uninstall selected app/game.

**Rip Game**      Allows to free up some space by eliminating some game folders/files such as: Game Manual, and some folders/files from ux0:app/(GAMEID) since those folders/files are also at ux0:patch/(GAMEID) (ux0:Repatch/(GAMEID)).

This option is based in TheRadziu's Tutorial https://github.com/TheRadziu/NoNpDRM-modding/wiki#saving-memory-space-while-using-mods
* NOTE: Be very carefull after using this option, because, if the folders/files get deleted from ux0:patch/(GAMEID) o ux0:rePatch/(GAMEID) the game will stop booting cause there won't be any folders/files left at ux0:app/(GAMEID)

**Switch app**    Allows to move the selected app/game between the 3 available partitions (ux0-ur0-uma0).

**Show PICS**     Allows to show the selected game PIC in the submenu.<br>

**Mark Favorite** Allows to mark a game/app as favorite.<br>


#### Submenu 2: <br>

**Themes ONEMenu** This option now allows to download and change themes for ONEMenu (moved to this submenu for best accessibility).

**Style**       Allows to interchange ONEMenu category slides position and icon list style.
	Up: Clasic Menu style with mirrored icons and the category slides above the icons list.
	Down: Simple menu similar to PS4 with the category slide below, this option does not have the icons reflections.

**Scan Favorites** If this option gets enabled, when ONEMenu is restarted the icon list will only show the games/apps marked as "Favorite", is necesary to have marked one game/app at least to enable the option. 
If you want to have all the games/apps listed again then this option must be disabled.

**Sort Category by** Allows to sort the icon list by Title (alphabetically) or Gameid.

**Enable AutoUpdate** Enable/Disable the AutoUpdate feature to allow or block future ONEMenu updates.

![header](screenshots/1MENUVITA3.png) 

## ONEMenu Explorer Files ##

![header](screenshots/1MENUVITA4.png)

**Triangle:** Open Submenus<br>

* NOTE: Press L/R to alternate between submenus (options).

#### Submenu 1 with basic functions as:

Copy<br>
Move<br>
Extract (zips and rars).<br>
Delete<br>
Rename<br>
MakeDir<br>
Size    (folder/file size)<br>

Install games as vpk or folder<br>
Export multimedia files (mp4, mp3, png, jpg).<br>


#### Submenu 2 with advanced functions as:

FTP<br>
USB connection<br>
Livearea Apps (install games in ux0:app)<br>
Update Database (app.db)<br>
Rebuild Database (app.db)<br>
Reload config.txt<br>
Favorites section to manage the games/apps marked as faverites and/or enable the option to scan only the favorites the next time you open ONEMenu.<br>

### Language and Personalization ###

**Language**

You can translate the file ux0:data/ONEMENU/english_us.txt and rename it to corresponding language:.<br>

JAPANESE.txt<br>
ENGLISH_US.txt<br>
FRENCH.txt<br>
SPANISH.txt<br>
GERMAN.txt<br>
ITALIAN.txt<br>
DUTCH.txt<br>
PORTUGUESE.txt<br>
RUSSIAN.txt<br>
KOREAN.txt<br>
CHINESE_T.txt<br>
CHINESE_S.txt<br>
FINNISH.txt<br>
SWEDISH.txt<br>
DANISH.txt<br>
NORWEGIAN.txt<br>
POLISH.txt<br>
PORTUGUESE_BR.txt<br>
ENGLISH_GB.txt<br>
TURKISH.txt<br>

*Remember to translate only the quoted words from english_us.txt.

**Themes for ONEMenu**

Note: Remember an option its been added to download themes directly to the path mentioned below :)

The Themes for ONEMenu have to be placed in the path ux0:data/ONEMENU/themes.<br>

![header](screenshots/themes1.png)

++ Create a new folder with the theme name and place the next resources inside:.<br>

**font.ttf**        Font ttf for your Theme (Optional).<br>

**back.png**        Background image for your icons (960*544).<br>

**icodef.png**      Default icon to blit instead of the app/game icon0 when the original icon0 can't be loaded (100*100).<br>

**buttons1.png**    Image Sprites (160*20).<br>


  1. position 0				Cross button

  1. position 1				Triangle button

  1. position 2				Square button

  1. position 3				Circle button

  1. position 4				Plugin icon for games with plugins enabled to it's GAMEID in the config.txt

  1. position 5				Clon icon for cloned psp bubbles.

  1. position 6				For battery in use.

  1. position 7				For battery charging.

  1. position 8				For Favorites.


**buttons2.png**    Image Sprites (120*20)
  
**wifi.png**        Image Sprites (132*22)

**cover.png**       Image for Song Cover in Music section (369x369)

**music.png**       Image for Music section (960*544)

**editor.png**     Image for the Text Editor (960*544)

**ftp.png**         Background Image for FTP port message (960*544)

**list.png**        Image for ExplorerFiles and vpk/iso/cso search results found on memory card (960*544)

**themesmanager.png** Background Image for ONEMenu theme selection section (960*544)

**preview.png**     Your image preview for your theme for ONEMenu (391*219)

**icons.png**       Sprites (112x16) must follow next order:

  1. position 0			    Icon to blit for general files

  1. position 1				Icon to blit for folders

  1. position 2				Icon to blit for: pbp, prx, bin, suprx, skprx files

  1. position 3				Icon to blit for: png, gif, jpg, bmp image files

  1. position 4				Icon to blit for: mp3, s3m, wav, at3, ogg sound files

  1. position 5				Icon to blit for: vpk, rar, zip files

  1. position 6				Icon to blit for: iso, cso, dax files


*Label Categories*

**PSVITA.png**   PSVita Games (250*66).<br>

**HBVITA.png**   Homebrews Vita (250*66).<br>

**PSM.png**      PSM Games (250*66).<br>

**RETRO.png**    PSP & PS1 Games (250*66).<br>

**ADRBB.png**    Adrenaline Bubbles Games (250*66).<br>


# Create a ini file

**theme.ini**

This .ini file stores the text printing colors according to file extension.<br>
*Change only the Hex-Dec part for the desired color. (ABGR format)<br>

TITLE = "Name of your theme".<br>
AUTHOR = "Name of Author".<br>

*# Text and background color.*<br>
TXTCOLOR		= 0xFFFFFFFF<br>
TXTBKGCOLOR		= 0x64000000

*#Submenu color bar on selected icon.*<br>
BARCOLOR        = 0x64330066

*#Header color.*<br>
TITLECOLOR      = 0xFF9999FF

*#Path text color (File Explorer).*<br>
PATHCOLOR       = 0xA09999FF

*#Date and time indicator text color.*<br>
DATETIMECOLOR   = 0xFF7300E6

*#Folder/File count in the file explorer.*<br>
COUNTCOLOR	= 0XFF0000FF

*#Draw the bars in the callbacks section.*<br>
CBACKSBARCOLOR	= 0x64FFFFFF

#File type text color for File Explorer.*<br>
SELCOLOR        = 0x64530689<br>
SFOCOLOR        = 0XFFFF07FF<br>
BINCOLOR        = 0XFF0041C3<br>
MUSICCOLOR      = 0xFFFFFF00<br>
IMAGECOLOR      = 0xFF00FF00<br>
ARCHIVECOLOR    = 0xFFFF00CC<br>
MARKEDCOLOR     = 0x2AFF00FF<br>
FTPCOLOR		= 0xFFFF66FF<br>

*#Battery percentage text color.*<br>
PERCENTCOLOR	= 0x6426004D

*#Battery status indicator bar color.*<br>
BATTERYCOLOR	= 0x6453CE43<br>
LOWBATTERYCOLOR	= 0xFF0000B3<br>

*#Rectangle and gradient color for selected icon (PS4 Theme).*<br>
GRADRECTCOLOR	= 0x64330066<br>
GRADSHADOWCOLOR = 0xC8FFFFFF<br>

*Change only the Hex-Dec part for the desired color. (ABGR format)<br>
Recommended website: ([Colors Hex](https://www.w3schools.com/colors/colors_hexadecimal.asp)).<br>

![header](screenshots/themes2.png)


# Credits
*Xerpi* for vita2d.<br>
*TheFloW* Pkg installer & USB Modules.<br>
*Yifan-lu, XYZ and Davee* and every coder and dev contributing to Vitasdk.<br>
*Team Molecule* for Henkaku.<br>
*WZ-JK* For Graphics.<br>
Testers:<br>
*([thehero_](https://twitter.com/TheheroGAC)).*<br>
*([Applelo1](https://twitter.com/Applelo1)).*<br>
*([Tuto Pro Play](https://twitter.com/Tuto_Pro_Play)).*<br>

