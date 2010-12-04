Broker_Garbage
==============
Author: ckaotik
Version: 4.0v5
WoW Version: 4.0.3

WoWInterface: http://www.wowinterface.com/downloads/info15531-Broker_Garbage.html	(with Loot Manager)
Curse:        http://wow.curse.com/downloads/wow-addons/details/broker_garbage.aspx	(with Loot Manager)
GitHub:		  http://www.github.com/ckaotik/Broker_Garbage							(without Loot Manager)


1. What it does
-----------------
Broker_Garbage is a LDB plugin that will show your least valuable items, their value and their amount in a tooltip. Then it enables you to drop them with just one click, making life for those tight-bagged people among us easier.
As you probably don't want to drop everything just by it's vendor price, Broker_Garbage takes into account auction prices (you would need to have an auction price addon active) and different lists for managing exclusions and other "special" behaviour.

2. First Start
-----------------
Depending on your LDB display addon you may or may not already see the Broker_Garbage plugin on it. If you don't, please check if you need to enable it in oder to be displayed (e.g. for DockingStation). It will be listed as either "Garbage" or "Broker_Garbage".
If you still can't find it, have a look at your options panel (ESC - Interface - AddOns tab - look for Broker_Garbage). Should you not find it there it might be because it caused an error (you can turn on Lua error messages in the Interface menu) or it's not activated in the Login screen.

If you get past that point (and really, you should) it's about time to set up your lists. For more information on lists, have at look at 5. List Management.
1) Set up items you never want to delete, on any character, in your Keep List. Then, select them and push "Promote" to put them on your global Keep List.
2) Now, go ahead and add character specific items to your Keep List (same as above, just no "Promote")
3) With that taken care of you might want to think of items that always fill your inventory even though you don't need them or they can be easily gotten back. These items belong on your Junk List. Examples for this list are Argentum Lance, Light Feather (if you have a Mage/Priest that needs them, by default they will be put on their (local) Keep List) and the likes.


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
There are several lists for you to use. Please be aware that itemIDs are prioritized above LibPeriodicTable (LPT) category strings, so if for example you had "Misc.Reagent.Class.Priest" on your Keep List but 17056 (Light Feather) on your Junk List, the feathers would be considered as junk items.

* Whitelist: Keep List
Items on here will be "saved" from any actions - they will not be sold, dropped or anything else.

* Blacklist: Junk List
Items on this list will be always be shown in the drop Tooltip, no matter what Quality Treshold you might have set. If you have too many, you won't see any other items in the tooltip. Caution!

Junk List items can have a set limit. Use this if for example you only want to keep 5 Soulshards. Excess items will be listed in the Tooltip!

* Vendor Price List
Items on this list will never have their auction value used. This is useful for food, drinks and other things people tend to put on the AH at unbelievable prices.

* Sell List
Items on this list will be sold whenever you talk to a vendor. Items of higher quality than your Quality Treshold WILL be sold, just keep that in mind.

Each of these lists except for 'Vendor Price' have a global (affects all your characters) and local (only affects the current character) component. You can promote/demote items between the two by selecting them and then clicking on the Promote/Demote icon below the list.
Global items will have a "G" shown in their top left corner.

6. 'Source' information on the tooltip
-----------------
If you check 'Show Source' in the options panel, the tooltip will display an additional column with color coded letters. These are to show you which item price Broker_Garbage decided on using. Possible codes are:
	orange V		This item has its vendor price set as the highest value.
	dark orange V 	This item is on your Sell List or Vendor Price List. It uses the item's vendor price
	green A			This item has its auction value used
	blue G			You have 'Sell Gear' checked and this item will be sold when at a merchant. It uses the vendor price.
	white I			This item is on your Junk List and therefore is displayed first.

7. Periodic Table -or- How to put entire categories onto those stupid lists
-----------------
Starting in version 3.3v11 you can add category strings to make your life easier. To do so, go to your settings panel for the list you wish to add it to and right-click on the 'plus' icon. You will see a list of all categories LibPeriodicTable has to offer (or at least the parts of it that I chose to include).
Navigate your way through the menu and add any category you like simply by clicking on it.
To remove a category simply do as you would with any other item on your list: Select it and then hit the 'Minus' icon.
If you want to test which items are on what lists, just use the 'Category Test' panel in the options.

Why are these categories only in English? There's a simple answer to that: Because that's what LPT does and I do not want to localize the complete LPT. Sorry for that, but it's kind of not my job to do that ;)

8. How to adjust the LDB display text
-----------------
In 3.3v15 I added the possibility to adjust the LDB display text to your liking. To do so, simply change the text on the General Options panel or type "/garbage format 'formatstring'" (without any quotation marks) where formatstring is your desired output format. The LDB display format supports several parameters:

	[itemname]		item name/link
	[itemcount]		item count
	[itemvalue]		item value
	
	[freeslots]		number of free inventory slots
	[totalslots]	total number of inventory slots
	
	[basicfree]		number of general type free bag slots (i.e. bags that can hold any item)
	[basicslots]	total number of general type bag slots
	[specialfree]	number of special type free bag slots (i.e. mining bags)
	[specialslots]	total number of special type bag slots
	
	[bagspacecolor]	colors the following text corresponding to your bag situation
	[basicbagcolor]	colors the following text corresponding to your basic bag situation
	[specialbagcolor]	colors the following text corresponding to your specialty bag situation
	[endcolor]		resets the coloring
	
	[junkvalue]		the amount a vendor would give you for your junk/auto sell items

Some examples:

[Hearthstone]x1 (0c) - 8/32					can be achieved with
	[itemname]x[itemcount] ([itemvalue]) - [bagspacecolor][freeslots]/[totalslots][endcolor]

0c [Hearthstone]x1 - 13/9/136				can be achieved with
	[itemvalue] [itemname]x[itemcount] - [basicbagcolor][basicfree][endcolor]/[specialbagcolor][specialfree][endcolor]/[bagspacecolor][freeslots][endcolor]

[Hearthstone] - (18/48) - 0c				can be achieved with
	[itemname] - ([freeslots]/[totalslots]) - [itemvalue]

18 / 3g14s8c - [Hearthstone]						can be achieved with
	[freeslots] / [junkvalue] - [itemname]

9. The Loot Manager
-----------------
The Loot Manager has several settings for you to play around with. It is a seperate addon that can be (de)activated in the addons panel and ingame in the options panel.
For more information on the Loot Manager, see its own readme.txt .

Items on your Junk List will never be looted, while the Loot Manager will always try its best to loot those items that are on your Keep List.

10. Slash Commands
-----------------
Broker_Garbage supports a hand full of slash commands. These are /garbage or short, /garb. Parameters supported:
	
	/garbage format <formatstring>
See information on this one above, in part 8.
	
	/garbage option -or- /garbage options -or- /garbage menu -or- /garbage config
All of these just open up the config window ;)

	/garbage limit <itemLink or itemID> <amount>
This will add the corresponding item to the character's include list and add a limit to it.
	
	/garbage glimit -or- /garbage globallimit
Same as the above, just adds the item to the global include list.

	/garbage tooltiplines -or- /garbage numlines
Sets the number of lines the tooltip will display. This setting can also be changed in the options panel.

	/garbage tooltipheight -or- /garbage height
Sets the height of the LDB tooltip. This setting can also be changed in the options panel

11. How you can help
-----------------
I still need a few translations to get done. If you would like to help me with that, please do so on http://wow.curseforge.com/addons/broker_garbage/localization/  .
Likewise, I need people to test the addon with different auction addons. If you have one that isn't yet supported, make a Feature Suggestion (see 4.).
