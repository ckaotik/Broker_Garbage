Broker_Garbage
==============
Author: ckaotik
Version: 3.3v9
WoW Version: 3.3 (TOC 30300)

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
To report a bug just log on to WoWInterface.com or curse.com and leave me a message or a comment (the full links can be found at the top of this file) giving as much information as you can. On curse it even offers a bug tracker and I wouldn't mind you using it.

* When did it happen? (on login, on /reload, when selling, ...)
* What happened? ("The tooltip went blank.", "The tooltip sticks to the cursor.", ...)
* Comment ("Could be because addon XY does weird things.", "Didn't happen on my pally char".)


4. Feature Suggestions
-----------------
Got a feature idea? Then tell me! Send me a message on curse/wowinterface or comment my addon on any of those sites. I'll make sure to read it!

Still, do not feel bad if it doesn't make it into the addon. In that case I will most likely try to get you an individual solution - or include it at a later time.


5. List Management
-----------------
There are several lists for you to use:

* Exclude List
Items on here will be "saved" from any actions - they will not be sold, dropped or anything else.
Grayed out items on there are items that are on your global list, active for all characters. Colorful ones are just for your current character.

* 'Force Vendor Price' List
Items on this list will never have their auction value used. This is useful for food, drinks and other things people tend to put on the AH at unbelievable prices.

* Include List
Items on this list will be always be shown in the drop Tooltip, no matter what Quality Treshold you might have set. Caution!
Grayed out items on there are items that are on your global list, active for all characters. Colorful ones are just for your current character.

* Auto-Sell List
Items on this list will be sold whenever you talk to a vendor. Items of higher quality than your Quality Treshold WILL be sold.

Each of these lists except the 'Force Vendor Price' list have a global (affects all your characters) and local (only affects the current character) component. You can broadcast items on your local lists as global by selecting them and then clicking on the promote icon next to the list.


6. How you can help
-----------------
I still need a few translations to get done. If you would like to help me with that, please do so on http://wow.curseforge.com/addons/broker_garbage/localization/  .
Likewise, I need people to test the addon with different auction addons. If you have one that isn't yet supported, make a Feature Suggestion (see 4.).
