Broker_Garbage - Loot Manager
==============
!included in Broker_Garbage Curse/WoWI download!
!requires Broker_Garbage main addon!

Author: ckaotik
Version: 4.0v7
WoW Version: 4.0.3

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

3. I got an error!!!11!1!
-----------------
Well, that's not good, but it's good ;) If you report an error I can have a look to fix it. Of course, there shouldn't be any errors in the first place but you know ... I'm only human, too.
To report a bug just log on to WoWInterface.com, Curse.com or github.com/ckaotik/ and leave me a message, comment or issue (the full links can be found at the top of this file) giving as much information as you can. On curse it even offers a bug tracker and I wouldn't mind you using it. Some info you should always include:

* What version were you using, and where?
* When did it happen? (on login, on /reload, when selling, ...)
* What happened? ("The tooltip went blank.", "The tooltip sticks to the cursor.", ...)
* Comment ("Could be because addon XY does weird things.", "Didn't happen on my pally char".)


4. Feature Suggestions
-----------------
Got a feature idea? Then tell me! Send me a message on curse/wowinterface or comment my addon on any of those sites. I'll make sure to read it!

Still, do not feel bad if it doesn't make it into the addon. In that case I will most likely try to get you an individual solution - or include it at a later time.


5. What the options do
-----------------
Autoloot
	This is one of the main features of the Broker_Garbage Loot Manager. With Autoloot enabled, the addon will loot interesting items and leave out uninteresting ones.
	
	'Interesting' in this case means: Items on your Exclude List (Whitelist) will always be looted while items on your Include List (Blacklist) aren't looted by the Loot Manager. Also, if an item is worth less than you minimum item value, it won't be looted.
	
	If you don't generally want to autoloot, you can choose to still autoloot in special situations. 
	
	'Pickpocket' will kick in if you're a rogue and currently sneaking
	'Fishing' takes action if you are - surprise - fishing.
	'Skinning' is an option to autoloot only skinnable mobs (that you have anough skill to skin) as you can't skin them as long as they hold any loot.

Autodestroy
	Autodestroy will take care of your bag space. If the Loot Manager finds an item it absolutely wants to loot, it will destroy a cheap item out of your bags if this option is enabled.
	You can set the minimum amount of free bag space. If for example you always want to have at least three free inventory slots, set it to 3 and the Loot Manager will destroy stuff if it would fill up those supposed-to-be-free slots.
	
	Autodestroy > Force will destroy over-limit items the moment you loot something. If you leave it unchecked, the items will be deleted only if you run our of bag space and want to loot something new.
	
	Autodestroy together with Autoloot lets you take full advantage of the Loot Manager - you'll have almost nothing left to do ;)

Use in combat
	If you have this checkbox checked, Broker_Garbage-LootManager will work in combat as well. This option does not affect any regular Broker_Garbage functions, it is basically just there to avoid 'addon blocked' issues. (For whatever reason LootSlot() and CloseLoot() are protected.)
	If you don't mind getting this (mostly) minor taint, check this. If you want to make sure nothing will taint, then simply leave it off :)


6. Slash Commands
-----------------
The Loot Manager adds an additional slash command to Broker_Garbage:

	/garbage value <value in copper> -or- /garbage minvalue <value in copper>
Sets the minimum item value in order for the item to be looted. '0' means every item may be looted.

	/garbage freeslots <number> -or- /garbage slots <number>
Sets the number of slots to always keep free. This is the same setting as the slider in the options panel, just that you can insert any positive number (i.e. also numbers > 30). Just make sure you know the consequences!

7. How you can help
-----------------
I still need a few translations to get done. If you would like to help me with that, please do so on http://wow.curseforge.com/addons/broker_garbage/localization/  .
Likewise, I need people to test the addon with different auction addons. If you have one that isn't yet supported, make a Feature Suggestion (see 4.).
