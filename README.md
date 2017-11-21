# ONEMenu for PSVita

App Manager Plus has evolved to Onemenu for psvita! so, App manager Plus will no longer be updated.

![header](1MENUVITA.png)

**OneMenu for PSVita** is a simple to use UI which separates the installed games and apps into categories...<br>
Onemenu comes with a built in file explorer which has many advanced features such as installing/uninstalling apps/games, move the selected app/game to diferent partition (ux0-ur0-uma0) connect via ftp or usb to the pc, restart, shutdown, rebuild db...

# Controls:

### Changelog 1.01 ###
Please update your translations...Two new lines were added:<br>
*PGF Font*<br>
*PVF Font*<br>

- [FIX] Incorrect display of LiveArea app names.<br>
- [FIX] PS Button lock when using FTP and USB mode.<br>
- [FIX] Some errors in the internal code.<br>
- [FIX] Standard format month/day/year.<br>
- [NEW] Support to change the type of font (PGF<->PVF) in advanced options.<br>
- 3 added shortcuts:<br>
- L + R + Up: Restart ONEMenu.<br>
- L + R + Down: Restart PSvita.<br>
- L + R + Square: Shutdown PSvita.<br>

![header](1MENUVITA2.png)

**ONEMenu icons list:**

**UP/Down:**<br>
Category change (5 categories available: Vita/Hb games, PSM Games, PSP/Hbs Games, PS1 Games, Adrenaline Bubbles).<br>
**L/R:**<br>
Fast scrolling.<br>
**Start:**<br>
Opens a submenu with a list of system apps.<br>
**Triangle:**<br>
Open Submenu:<br>

	Uninstall		Allows to uninstall selected app/game.
	Remove manual		Allows to eliminate the game/app manual.
	Switch app		Allows to move the selected app/game between the 3 available partitions (ux0-ur0-uma0).

**Slides**					2 options:.<br>

	Up: Clasic Menu style with mirrored icons and the category slides above the icons list.
	Down: Simple menu similar to PS4 with the category slide below, this option does not have the icons reflections.

**Show PICS**				Allows to show the selected game PIC in the submenu.<br>

![header](1MENUVITA3.png)

**Explorer Files**

![header](1MENUVITA4.png)

**Triangle:**

	Opens SubMenu1 with basic functions as Copy, Move, Install games as vpk or folder, Install CustomThemes, etc...

**Start:**

	Opens SubMenu2 with advanced functions as FTP and USB connection, Restart or Shutdown the PSVita, Update and/or Rebuild Database (app.db), Option for vpks/isos/cso Search, Change Available Themes for ONEMenu and Uninstall CustomThemes.

### NOTE:<br>
When a CustomTheme is installed the corresponding folder and files are moved to ux0:data/customtheme and for uninstalling any of these CustomThemes you'll be given the option to eliminate the folder and files of the CustomTheme, if you choose not to eliminate them, then the resources of said CustomTheme will be moved to the path ux0:data/uninstall_customtheme for reinstalling in the futured.<br>

The Themes for ONEMenu have to be placed in the path ux0:data/ONEMENU/themes following mostly the same instructions as for AppManager Themes.<br>

# Theme Personalization

**Themes for ONEMenu**

![header](themes1.png)

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


**buttons2.png**    Image Sprites (120*20)
  
**wifi.png**        Image Sprites (132*22)

**cover.png**       Image for Song Cover in Music section (369x369)

**music.png**       Image for Music section (960*544)

**ftp.png**         Background Image for FTP port message (960*544)

**list.png**        Image for ExplorerFiles and vpk/iso/cso search results found on memory card (960*544)

**menu.png**        Image for blitting the options submenu (167*443)

**themesmanager.png**		Background Image for ONEMenu theme selection section (960*544)

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

**PSVita.png**    PSVita/Hbs Games (250*66).<br>

**PSM.png**    PSM Games (250*66).<br>

**PSP.png**    PSP/Hbs Games (250*66).<br>

**PS1.png**    PS1 Games (250*66).<br>

**adrbb.png**    Adrenaline Bubbles Games (250*66).<br>
  
# Create a ini file

**theme.ini**

This .ini file stores the text printing colors according to file extension.<br>
*Change only the Hex-Dec part for the desired color. (ABGR format)<br>

TITLE = "Name of your theme".<br>
AUTHOR = "Name of Author".<br>

*# Text and background color.*<br>
TXTCOLOR		= 0xFFFFFFFF<br>
TXTBKGCOLOR		= 0x64000000

*#Header color.*<br>
TITLECOLOR      = 0xFF9999FF

*#Submenu color bar on selected icon.*<br>
BARCOLOR        = 0x64330066

*#Path text color (File Explorer).*<br>
PATHCOLOR       = 0xA09999FF

*#Date and time indicator text color.*<br>
DATETIMECOLOR   = 0xFF7300E6

#File type text color for File Explorer.<br>
SELCOLOR        = 0x64530689<br>
SFOCOLOR        = 0XFFFF07FF<br>
BINCOLOR        = 0XFF0041C3<br>
MUSICCOLOR      = 0xFFFFFF00<br>
IMAGECOLOR      = 0xFF00FF00<br>
ARCHIVECOLOR    = 0xFFFF00CC<br>
MARKEDCOLOR     = 0x2AFF00FF<br>
FTPCOLOR	= 0xFFFF66FF<br>

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

ONEMenu Themes must be placed in the next path:.<br>
ux0:data/ONEMENU/themes/yournameTheme

![header](themes2.png)

# Language

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

Then you have to place at the following path:
ux0:data/ONEMenu/lang/

*Remember to translate only the quoted words from english_us.txt.

# Credits
*Xerpi* for vita2d.<br>
*TheFloW* Pkg installer & USB Modules.<br>
*Yifan-lu, XYZ and Davee* and every coder and dev contributing to Vitasdk.<br>
*Team Molecule* for Henkaku.<br>
Testers:<br>
*([thehero_](https://twitter.com/TheheroGAC)).*<br>
*([Applelo1](https://twitter.com/Applelo1)).*<br>
*([Tuto Pro Play](https://twitter.com/Tuto_Pro_Play)).*<br>
