Broker_Garbage
==============
Author: ckaotik
Version: 7.1v1
WoW Version: 7.1.0

WoWInterface: http://www.wowinterface.com/downloads/info15531-Broker_Garbage.html
Curse:        http://wow.curse.com/downloads/wow-addons/details/broker_garbage.aspx
GitHub:		  http://www.github.com/ckaotik/Broker_Garbage


1. What it does
-----------------
Broker_Garbage is a LibDataBroker (LDB) plugin that displays your least valuable items. It enables you to easily sell, destroy or disenchant them with a single click, making life for those struggling for bag space.
As you probably don't want to judge everything just by it's vendor price, Broker_Garbage takes into account various auction prices (you need to have a supported auction price addon) and different lists for managing exclusions and other "special" behaviour.

2. First Start
-----------------
Depending on your LDB display addon you may or may not already see the Broker_Garbage plugin on it. If you don't, please check if you need to manually enable it in oder to be displayed (e.g. in DockingStation's config dialog). It will be listed as either "Garbage" or "Broker_Garbage".
If you still can't find it, have a look at your options panel (ESC - Interface - AddOns tab - look for Broker_Garbage). Should you not find it there it might be because it caused an error (you can turn on Lua error messages in the Interface menu) or it's not activated in the Login screen.
You should also take a look at the ingame addon settings, located in Interface - AddOns - Broker_Garbage. All settings provide explanation tooltips.

Once the plugin is enabled, the plugin will display the cheapest item found in your inventory by default. Hovering the plugin displays a tooltip containing all items and some of their details that Broker_Garbage considers expendable.


3. Something went horribly wrong / It won't work / It's weird!
-----------------
Well, that's not good, but it's good that you found it! If you report an error I can take a look to fix it. Of course, there shouldn't be any errors in the first place but you know ... we're all human.
To report a bug, you have multiple options. If you file an issue on the Curse issue tracker, the chances of getting a fix are highest. Otherwise, you can always leave a private message or a comment on WoWInterface or Curse.

Always try to provide as much information as you can. Some info you should include:
* When did it happen? (on login, on /reload, when selling, ...)
* What happened? ("The tooltip went blank.", "The tooltip sticks to the cursor.", ...)
* Comment ("Could be because addon XY does weird things.", "Didn't happen on my pally char".)


4. List Management
-----------------
Items (and item categories!) can be assigned to lists that change the way Broker_Garbage treats these items. The following lists are available:

- Keep: Items on this list will never be deleted or sold.
- Junk: Items on this list will always be considered as "junk" and are suggested to be dropped before any other items.
  Items on this list may also be configured to be automatically sold when talking to a merchant.
- Prices: You may manually override the monetary value of any item, either to a specific value (e.g. 0c) or to always use the item's vendor price (this can be useful for items with unrealistic auction values).
  These price overrides apply globally and are used by all characters.

Please be aware that itemIDs are prioritized above LibPeriodicTable (LPT) categories, so if for example you had "Misc.Reagent.Class.Priest" on your Keep List but 17056 (Light Feather) on your Junk List, the feathers would still be considered as junk items.


5. The Loot Manager
-----------------
The Loot Manager is a separate addon ("Broker_Garbage-LootManager") and can take control of looting for you. It can be configured in the "Loot Manager" section of the Broker_Garbage settings, and can be enabled either globally or for specific use cases (e.g. when fishing).


6. How to adjust the LDB display text
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


7. Slash Commands
-----------------
Broker_Garbage provides the slash commands /garbage and /junk. Their functionality is currently being reworked, therefore this documentation is incomplete. Using the slash command without any further parameters will output a short description of the available commands.
