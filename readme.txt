Broker_Garbage
==============
Author: ckaotik
Version: 3.3v23
WoW Version: 3.3.3 (TOC 30300)

WoWInterface: http://www.wowinterface.com/downloads/info15531-Broker_Garbage.html
Curse:        http://wow.curse.com/downloads/wow-addons/details/broker_garbage.aspx


1. What it does
-----------------
Broker_Garbage is a LDB plugin that will show your least valuable items, their value and their amount in a tooltip. Then it enables you to drop them with just one click, making life for those tight-bagged people among us easier.
As you probably don't want to drop everything just by it's vendor price, Broker_Garbage takes into account auction prices (you would need to have an auction price addon active) and different lists for managing exclusions and other "special" behaviour.

2. First Start
-----------------
Depending on your LDB display addon you may or may not already see the Broker_Garbage plugin on it. If you don't, please check if you need to enable it in oder to be displayed (e.g. for DockingStation). It will be listed as "Garbage".
If you still can't find it, have a look at your options panel (ESC - Interface - Addon Tab - look for Broker_Garbage). Should you not find it there it might be because it caused an error (you can turn on Lua error messages in the Interface menu).

If you get past that point (and really, you should) it's about time to set up your lists. For more information on lists, have at look at 5. List Management.
1) Set up items you never want to delete, on any character, in your Exclude List. Then, select them and push "Promote" to put them on your global Exclude List.
2) Now, go ahead and add character specific items to your Exclude List (same as above, just no "Promote")
3) With that taken care of you might want to think of items that always fill your inventory even though you don't need them or they can be easily gotten back. These items belong on your Include List. Examples for this list are Argentum Lance, Light Feather (if you have a Mage/Priest that needs them, put it on their (local) Exclude list.) and the likes.


3. I got an error!!!11!1!
-----------------
Well, that's not good, but it's good ;) If you report an error I can have a look to fix it. Of course, there shouldn't be any errors in the first place but you know ... I'm only human, too.
To report a bug just log on to WoWInterface.com or curse.com and leave me a message or a comment (the full links can be found at the top of this file) giving as much information as you can. On curse it even offers a bug tracker and I wouldn't mind you using it. Some info you should always include:

* When did it happen? (on login, on /reload, when selling, ...)
* What happened? ("The tooltip went blank.", "The tooltip sticks to the cursor.", ...)
* Comment ("Could be because addon XY does weird things.", "Didn't happen on my pally char".)


4. Feature Suggestions
-----------------
Got a feature idea? Then tell me! Send me a message on curse/wowinterface or comment my addon on any of those sites. I'll make sure to read it!

Still, do not feel bad if it doesn't make it into the addon. In that case I will most likely try to get you an individual solution - or include it at a later time.


5. List Management
-----------------
There are several lists for you to use. Please be aware that itemIDs are prioritized above LPT category strings, so if for example you had "Misc.Reagent.Class.Priest" on your Exclude List but 17056 (Light Feather) on your Include List, the feathers would be considered as included items.

* Whitelist: Exclude List
Items on here will be "saved" from any actions - they will not be sold, dropped or anything else.
Grayed out items on there are items that are on your global list, active for all characters. Colorful ones are just for your current character.

* Whitelist: 'Force Vendor Price' List
Items on this list will never have their auction value used. This is useful for food, drinks and other things people tend to put on the AH at unbelievable prices.

* Blacklist: Include List
Items on this list will be always be shown in the drop Tooltip, no matter what Quality Treshold you might have set. If you have too many, you won't see any other items in the tooltip. Caution!
Grayed out items on there are items that are on your global list, active for all characters. Colorful ones are just for your current character.
Since 3.3v17 include list items also can have a limit set. Use this if for example you only want to keep 5 Soulshards. Excess items will be listed in the Tooltip!

* Blacklist: Auto-Sell List
Items on this list will be sold whenever you talk to a vendor. Items of higher quality than your Quality Treshold WILL be sold, just keep that in mind.

Each of these lists except the 'Force Vendor Price' list have a global (affects all your characters) and local (only affects the current character) component. You can broadcast items on your local lists as global by selecting them and then clicking on the promote icon next to the list.

6. 'Source' information on the tooltip
-----------------
If you check 'Show Source' in the options panel, the tooltip will display an additional column with color coded letters. These are to show you which item price Broker_Garbage decided on using. Possible codes are:
	orange V		This item has its vendor price set as the highest value.
	dark orange V 	This item is on your Auto-Sell list or Force Vendor Price list. It uses the vendor price
	green A			This item has its auction value shown
	blue G			You have 'Sell Gear' checked and this item will be sold when at a merchant. It uses the vendor price.
	white I			This item is on your include list and therefore displayed first.

7. Periodic Table -or- How to put entire categories onto those stupid lists
-----------------
Starting in version 3.3v11 you can add category strings to make your life easier. To do so, go to your settings panel for the list you wish to add it to and right-click on the 'plus' icon. You will see a list of all categories LibPeriodicTable (LPT) has to offer (or at least the parts of it that I chose to include).
Navigate your way through the menu and add any category you like simply by clicking on it.
To remove a category simply do as you would with any other item on your list: Select it and then hit the corresponding 'minus' icon.
If you want to test which items are on what lists, just use the 'Test category strings' panel in the options.

Why these categories are only in English? There's a simple answer to that: Because that's what LPT does and I do not want to localize the complete LPT. Sorry for that, but it's kind of not my job to do that ;)

8. How to adjust the LDB display text
-----------------
In 3.3v15 I added the possibility to adjust the LDB display text to your liking. To do so, simply change the text on the Basic Options panel or type "/garbage format 'formatstring'" where formatstring is your desired output format (withouth quotation marks). The LDB display format supports several parameters:

	[itemname]		item link
	[itemcount]		item count
	[itemvalue]		item value
	
	[freeslots]		number of free slots
	[totalslots]	number of maximum bag capacity
	
	[bagspacecolor]	colors the following text corresponding to your bag situation
	[endcolor]		resets the coloring
	
	[junkvalue]		the amount a vendor would give you, if you autosold stuff

Some examples:

[Hearthstone]x1 (0c) - 8/32					can be achieved with
	[itemname]x[itemcount] ([itemvalue]) - [bagspacecolor][freeslots]/[totalslots][endcolor]

[Hearthstone] - (18/48) - 0c				can be achieved with
	[itemname] - ([freeslots]/[totalslots]) - [itemvalue]

18 / 3g14s8c - [Hearthstone]						can be achieved with
	[freeslots] / [junkvalue] - [itemname]

9. The Loot Manager
-----------------
The Loot Manager has several settings for you to play around with. It is a seperate addon that can be (de)activated in the addons panel and ingame in the options panel.
For more information on the Loot Manager, see its own readme.txt .

Items on your Include List (see it as a Blacklist) will never be looted, while Broker_Garbage will always try its best to loot those items that are on your Exclude List (works as a Whitelist).

10. Slash Commands
-----------------
Broker_Garbage supports a hand full of slash commands. These are /garbage or short, /garb. Parameters supported:
	
	/garb format <formatstring>
See information on this one above, in part 7.
	
	/garb stats -or- /garb total -or- /garbage trash
Prints very simplified statistics to the chat frame. Further statistics/details can be found in the options menu.

	/garb option -or- /garb options -or- /garb menu -or- /garb config
All of these just open up the config window ;)

	/garb limit <itemLink or itemID> <amount>
This will add the corresponding item to the character's include list and add a limit to it.
	
	/garb glimit -or- /garb globallimit
Same as the above, just adds the item to the global include list.

	/garb value <value in copper> -or- /garb minvalue <value in copper>
Sets the minimum item value in order for the item to be looted. '0' means every item may be looted. This only works if the Loot Manager is active.

10. How you can help
-----------------
I still need a few translations to get done. If you would like to help me with that, please do so on http://wow.curseforge.com/addons/broker_garbage/localization/  .
Likewise, I need people to test the addon with different auction addons. If you have one that isn't yet supported, make a Feature Suggestion (see 4.).
