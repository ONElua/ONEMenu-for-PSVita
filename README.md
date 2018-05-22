# ONEMenu for PSVita

![header](screenshots/1MENUVITA.png)

**OneMenu for PSVita** is a simple to use UI which separates the installed games and apps into categories.<br>
Onemenu comes with a built in file explorer which has many advanced features such as installing/uninstalling apps/games, move the selected app/game to diferent partition (ux0-ur0-uma0) connect via ftp or usb to the pc, restart, shutdown, rebuild db.

### Changelog 3.00 ###
- Now the submenu in main screen have 2 pages (press triangle to open, and alternate pages with L and R), Same for submenu in Explorer.<br>
- Added the option to download and install ONEMenu themes to the main screen submenu.<br>
- Added the option "RELOAD Content" Allows to install games (NONPDRM) in ux0:app (Thanks the plugin Nonpdrm from TheFloW).<br>
- Added the option "Rip Game" to the main screen submenu, allows to free up some space by eliminating some game folders/files.<br>
- Optimized the code a litle.<br>

### Changelog 2.05 ###
- Edit param.sfo (decrypted).<br>
- Fix automatic network update (Add TLS v1.2 Support).<br>
- Updated to the latest version of ONElua.<br>

## ONEMenu icons ##

![header](screenshots/1MENUVITA.png)

**UP/Down:** Category change (5 categories available: Vita/Hb games, PSM Games, PSP/Hbs Games, PS1 Games, Adrenaline Bubbles).<br>
**L/R:** Fast scrolling.<br>
**Start:** Opens a submenu with a list of system apps.<br>

**Triangle:** Open Submenus<br>

* NOTE: Press L/R to alternate between submenus (options).

#### Submenu 1: <br>

![header](screenshots/1MENUVITA2.png)

**RELOAD Content** Allows to install games in ux0:app (Thanks the plugin Nonpdrm from TheFloW).

**Uninstall**     Allows to uninstall selected app/game.

**Rip Game**      Allows to free up some space by eliminating some game folders/files such as: Game Manual, and some folders/files from ux0:app/(GAMEID) since those folders/files are also at ux0:patch/(GAMEID) (ux0:Repatch/(GAMEID)).

This option is based in TheRadziu's Tutorial https://github.com/TheRadziu/NoNpDRM-modding/wiki#saving-memory-space-while-using-mods
* NOTE: Be very carefull after using this option, because, if the folders/files get deleted from ux0:patch/(GAMEID) o ux0:rePatch/(GAMEID) the game will stop booting cause there won't be any folders/files left at ux0:app/(GAMEID)

**Switch app**    Allows to move the selected app/game between the 3 available partitions (ux0-ur0-uma0).

**Show PICS**     Allows to show the selected game PIC in the submenu.<br>

**Mark Favorite** Allows to mark a game/app as favorite.<br>


#### Submenu 2: <br>

![header](screenshots/1MENUVITA3.png)

**Themes ONEMenu** This option now allows to download and change themes for ONEMenu (moved to this submenu for best accessibility).

**Style**       Allows to interchange ONEMenu category slides position and icon list style.
	Up: Clasic Menu style with mirrored icons and the category slides above the icons list.
	Down: Simple menu similar to PS4 with the category slide below, this option does not have the icons reflections.

**Scan Favorites** If this option gets enabled, when ONEMenu is restarted the icon list will only show the games/apps marked as "Favorite", is necesary to have marked one game/app at least to enable the option. 
If you want to have all the games/apps listed again then this option must be disabled.

**Sort Category by** Allows to sort the icon list by Title (alphabetically) or Gameid.

**Enable AutoUpdate** Enable/Disable the AutoUpdate feature to allow or block future ONEMenu updates.


## ONEMenu Explorer Files ##

**Triangle:** Open Submenus<br>

* NOTE: Press L/R to alternate between submenus (options).

#### Submenu 1 with basic functions as:

![header](screenshots/1MENUVITA4.png)

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

![header](screenshots/1MENUVITA5.png)

FTP<br>
USB connection<br>
Livearea Apps (install games in ux0:app)<br>
Update Database (app.db)<br>
Rebuild Database (app.db)<br>
Reload config.txt<br>
Favorites section to manage the games/apps marked as faverites and/or enable the option to scan only the favorites the next time you open ONEMenu.<br>

# Credits
*Xerpi* for vita2d.<br>
*TheFloW* Pkg installer & USB Modules.<br>
*Yifan-lu, XYZ and Davee* and every coder and dev contributing to Vitasdk.<br>
*Team Molecule* for Henkaku.<br>
*WZ-JK* For Graphics.<br>
Testers:<br>
*([BaltazaR4](https://twitter.com/baltazarregala4)).*<br>
*([thehero_](https://twitter.com/TheheroGAC)).*<br>
*([Applelo1](https://twitter.com/Applelo1)).*<br>
*([Tuto Pro Play](https://twitter.com/Tuto_Pro_Play)).*<br>

