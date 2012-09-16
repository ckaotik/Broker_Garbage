Broker_Garbage - Loot Manager
==============
!requires Broker_Garbage main addon!

Author: ckaotik
Version: 5.0v1
WoW Version: 5.0.5

!included in Broker_Garbage download package!
WoWInterface: http://www.wowinterface.com/downloads/info15531-Broker_Garbage.html
Curse:        http://wow.curse.com/downloads/wow-addons/details/broker_garbage.aspx
GitHub:		  http://www.github.com/ckaotik/Broker_Garbage


1. What it does
-----------------
The Loot Manager component of Broker_Garbage handles everything that's connected to looting. It offers autoloot functionality, selective autoloot, autodestroy and a handful of other settings.
For selective looting, the Loot Manager relies heavily on Broker_Garbage's list system.

2. First Start
-----------------
When you first start off, make sure you already set up Broker_Garbage correctly.
Go to the options panel and open up Broker_Garbage - you will see a 'Loot Manager' tab added.

In there you can make all the necessary settings to get running. See more under 5. 'What the options do'.


3. What the options do
-----------------
You can always see a short explanation in the ingame tooltips when hovering these settings!

-- Loot Behaviour
Autoloot
	This is one of the main features of the Broker_Garbage Loot Manager. With Autoloot enabled, the addon will loot interesting items and leave out uninteresting ones.

	'Interesting' in this case means: Items on your Keep List will always be looted while items on your Include List (Blacklist) aren't looted by the Loot Manager. Also, if an item is worth less than you minimum item value, it won't be looted.

	If you don't generally want to autoloot, you can choose to still autoloot in special situations (see below)

Autoloot: 'Pickpocket'
	Check this to only autoloot if you're a rogue and currently sneaking when the loot window opens.

Autoloot: 'Fishing'
	Check this to only loot when fishing.

Autoloot: 'Skinning'
	Check this to only loot when you are skilled in Skinning and your target is a dead beast.
	This causes BG-LootManager to try and clear all the loot in the loot window, so you can do your job.

Use in combat
	If you have this checkbox checked, Broker_Garbage-LootManager will work in combat as well. This option does not affect any regular Broker_Garbage functions, however, if you do not like "stuff going on in your bags" while you fight big bad monsters, disable this checkbox.

Close Loot Window
	When BG-LootManager determines "it's done", it may automatically close the loot window. However, this may interfere with other addons.

Close Loot Window: Keep private open
	If you choose to automatically close the loot window, you may check this checkbox to keep your private loot open.
	What is private loot? Mining, Skinning or opening containers like lockboxes creates loot that only you may take.

Clear All
	Check this to always take every item possible, even when you're not going to skin your target.

Accept BoP
	Check this to automatically accept BoP items. You might still see the binding popup for a short while but it will eventually vanish automatically if this is checked.

Loot 'Junk'
	Check this to loot items that Broker_Garbage classified as 'Junk'. Leave this unchecked to not loot these items.

Loot 'Keep'
	Check this to always loot items that Broker_Garbage classified as 'Keep'. If disabled, regular loot restrictions/settings will be considered.

-- Inventory
Autodestroy
	Autodestroy will take care of your bag space. If the Loot Manager finds an item it absolutely wants to loot, it might destroy a cheap item from your bags if this option is enabled.
	You can set the minimum amount of free bag space. If for example you always want to have at least three free inventory slots, set it to 3 and the Loot Manager will destroy stuff if it would fill up those supposed-to-be-free slots.

Autodestroy: Enforce
	This will destroy over-limit items the moment you loot something. If you leave it unchecked, the items will be deleted only if you run our of bag space and want to loot something new.

	Autodestroy together with Autoloot and Auto Sell lets you take full advantage of the Loot Manager - you'll have almost nothing left to do ;)

Minimum Inventory Space
	Set the threshold for when Auto destroy might trigger.

-- Thresholds
Minimum loot value
	Items worth less (using auction addons and list settings) than this value will not be looted.

Minimum item quality
	Items below this quality will not be looted

-- Notifications
Here you can check several situations in which BG-LootManager should print an information message to your chat frame.


4. Slash Commands
-----------------
The Loot Manager adds two additional slash commands to Broker_Garbage:

Command: minvalue, value
	Parameter: <value in copper>
		Set the minimum item value for Broker_Garbage-LootManager to pick up items.

	Comand: minfreeslots, freeslots, minfree, slots, free
	Parameter: <amount>
		Set the minimum amount of free bag slots for Broker_Garbage-LootManager's auto destroy.
