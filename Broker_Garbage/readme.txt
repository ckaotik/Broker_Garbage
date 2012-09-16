Broker_Garbage
==============
Author: ckaotik
Version: 5.0v1
WoW Version: 5.0.5

WoWInterface: http://www.wowinterface.com/downloads/info15531-Broker_Garbage.html
Curse:        http://wow.curse.com/downloads/wow-addons/details/broker_garbage.aspx
GitHub:		  http://www.github.com/ckaotik/Broker_Garbage


1. What it does
-----------------
Broker_Garbage is a LDB plugin that will show your least valuable items, their value and amount in a tooltip. Then it enables you to drop them with just one click, making life for those tight-bagged players among us easier.
As you probably don't want to judge everything just by it's vendor price, Broker_Garbage takes into account various auction prices (you need to have a supported auction price addon) and different lists for managing exclusions and other "special" behaviour.

2. First Start
-----------------
Depending on your LDB display addon you may or may not already see the Broker_Garbage plugin on it. If you don't, please check if you need to manually enable it in oder to be displayed (e.g. in DockingStation's config dialogue). It will be listed as either "Garbage" or "Broker_Garbage".
If you still can't find it, have a look at your options panel (ESC - Interface - AddOns tab - look for Broker_Garbage). Should you not find it there it might be because it caused an error (you can turn on Lua error messages in the Interface menu) or it's not activated in the Login screen.

If you get past that point (and really, you should) it's about time to set up your lists. For more information on lists, have at look at 5. (List Management) and/or read the ingame help section of Broker_Garbage's options panel.
1) Set up items you never want to delete, on any character, in your Keep List. Then, select them and push "Promote" to put them on your global (character wide) Keep List.
2) Now, go ahead and add character specific items to your Keep List (same as above, just no "Promote")
3) With that taken care of you might want to think of items that always fill your inventory even though you don't need them or they can be easily gotten back. These items belong on your Junk List. Examples for this list are Argentum Lance, Light Feather and the likes (if you are playing a character that needs them as reagents, they will most likely already be on that character's Keep List by default).


3. Something went horribly wrong / It won't work / It's weird!
-----------------
Well, that's not good, but it's good ;) If you report an error I can take a look to fix it. Of course, there shouldn't be any errors in the first place but you know ... I'm only human, too.
To report a bug just log on to WoWInterface.com or curse.com and leave me a message or a comment (the full links can be found at the top of this file) giving as much information as you can. On curse you can even use a proper bug tracker (It would be awesome if you did!).

Some info you should always include:
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

Items on this list that use a limit will be kept up to their limit, and any further items will be considered as regular items.

* Blacklist: Junk List
Items on this list will be always be shown in the LDB tooltip, no matter what Quality Treshold you might have set. If you have too many, you might not see any other items in the tooltip.

Items on this list that use a limit will be kept up to their limit, any excess items will however be handled like regular Junk List items (and therefore be shown in the tooltip).
Use this if for example you only want to keep 20 Bandages or one stack (= 20) of summoned food.

* Sell List
Items on this list will be sold whenever you talk to a vendor.
Items of higher quality than your Quality Treshold WILL be sold, just keep that in mind.

Items on this list that use a limit will be kept up to their limit, any excess items will be sold when at a vendor.

* Fixed Price List
Items on this list are either values by their vendor price, in case you just added an item, -or- use a completely custom price value you can set up in the Interface Options panel of Broker_Garbage using the gold coin icon.
Vendor pricing is useful for food, drinks and other things people tend to put on the AH at unbelievable prices.
Custom pricing it useful for items such as raid feasts, which have a low vendor price but are usually regarded worth a lot more.

Items on this list cannot have a limit applied.


Each of these lists except for 'Fixed Price' have a global (affects all your characters) and local (only affects the current character) component. You can promote/demote items between the two by selecting them and then clicking on the Promote/Demote icon below the list.
Global items will have a "G" shown in their top left corner.

6. 'Source' information on the tooltip
-----------------
If you check 'Show Source' in the options panel, the tooltip will display an additional column with color coded letters. These are to show you which item price Broker_Garbage decided on using. Possible codes are:

	grey		I 	Item is regarded as a junk item
	orange 		V	Item has its vendor price considered
	dark orange	V 	Item will be sold at the next vendor
	yellow 		C 	Item has a custom price set
	green 		A 	Item has its auction value considered
	purple 		D 	Item should be disenchanted 				If you are an Enchanter, you should see a disenchant icon next to this label!
	blue 		U 	Item is unusable (e.g. plate chest on a priest) and might be sold
	turkoise 	O 	Item is outdated via TopFit and might be sold


7. Periodic Table -or- How to put entire categories onto those lists
-----------------
Starting in version 3.3v11 you can add category strings to make your life easier. To do so, go to your settings panel for the list you wish to add it to and right-click on the 'plus' icon. You will see a list of all categories LibPeriodicTable has to offer (or at least the parts of it that I chose to include).
Navigate your way through the menu and add any category you like simply by clicking on it.
To remove a category simply do as you would with any other item on your list: Select it and then hit the 'Minus' icon.
If you want to test which items are on what lists, just use the 'Category Test' panel in the options.

Why are these categories only in English? There's a simple answer to that: Because that's what LPT does. This also means that these strings are not able to be localized.

8. How to adjust the LDB display text
-----------------
In 3.3v15 I added the possibility to adjust the LDB display text to your liking. To do so, simply change the text on the Interface Options panel of Broker_Garbage or type "/junk format 'formatstring'" (without any quotation marks) where formatstring is your desired output format. The LDB display format supports several parameters:

	[itemname]		item name/link
	[itemicon]		the item's icon that you see e.g. in you bags
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


10. Slash Commands
-----------------
Broker_Garbage supports a hand full of slash aliases, /junk, /garbage or short, /garb. Each of these support several commands called via
	/junk <command> <argument>

Most commands are also available in the Interface Options panel. Available commands include:

	Command: config, option, options, menu
	Parameter: -
		All of these just open up the Interface Options window for Broker_Garbage's settings

	Command: add
	Parameter: <list name> <itemLink or itemID or category string>
		Add an item or category to the given list. See list of accepted list names below.

	Command: remove
	Parameter: <list name> <itemLink or itemID or category string>
		Remove an item or category from the given list. See list of accepted list names below.

	-- Possible list names:
	--	"Keep" list:		keep, exclude, treasure
	--	"Junk" list: 		junk, include, garbage
	--	"Auto Sell" list: 	autoSellList, autoselllist, autosell, vendor
	--	"Fixed Price" list:	forceVendorPrice, forcevendorprice, forceprice, vendorprice

	Command: cache, updatecache, resetcache, update
	Parameter: <itemID> (optional)
		Update an item's cached date. If no itemID is supplied, all caches will be cleared, including dynamic caching used by category list entries.

	Command: format, display
	Parameter: <formatstring>
		See information on this one above, in part 8.

	Command: tooltiplines, numlines
	Parameter: <amount>
		Sets the number of lines the LDB tooltip will display.

	Command: tooltipheight, height
	Parameter: <pixel height>
		Sets the height in pixels of the LDB tooltip.

	Command: limit
	Parameter: <itemLink or itemID or category string> <amount>
		This will add the corresponding item or category to this character's junk list and add a the supplied limit value.

	Command: globallimit, glimit
	Parameter: <itemLink or itemID or category string> <amount>
		Same as the above, just adds the item to the global junk list.

	Command: minvalue, value
	Parameter: <value in copper>
		Set the minimum item value for Broker_Garbage-LootManager to pick up items.
		-- This command requires Broker_Garbage-LootManager

	Comand: minfreeslots, freeslots, minfree, slots, free
	Parameter: <amount>
		Set the minimum amount of free bag slots for Broker_Garbage-LootManager's auto destroy.
		-- This command requires Broker_Garbage-LootManager

	Command: categories, category, list, lists
	Parameter: <itemID or itemLink>
		List all used categories an item belongs to.


11. How you can help
-----------------
Do you have awesome feature suggestions? Or possibly found a rare bug? Drop me a comment to let me know!
Likewise, I need people to test the addon (period) with different auction addons. If you have one that isn't yet supported, make a Feature Suggestion (see 4.).
