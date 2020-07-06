//VERSION 1.01
//Author: Venrob

Requires: 'VenrobTangoHandler', version 1.01+

FFCShop Setup:

COMBO_SHOP_INVIS - An invisible combo that is not combo 0.
COMBO_SHOP_OUT_OF_STOCK - A combo to display if the shop is "out of stock" (via 'shopSpecial==1', if Link already has the item; see below)

FONT_PRICEDISPLAY - the font for the price display
COLOR_PRICETEXT - the color of the price display text
LAYER_PRICETEXT - the layer to draw the price text to. Layer 2 or lower will draw under Link.

//USAGE:
//d0 - item ID
//d1 - Price
//d2 - Special.
	//By default, a value of 1 will make the item only available if you do not own it. 
	//By default, a value of 2 will make it so that when this item is bought, you cannot EVER buy it (or any other item sharing the same d7 parameter) again.
//d3 - Y-Offset for the item icon
//d4 - Y-Offset for the price text
//d5 - Requires bottle. Set this to 1 if this is a bottle-filling item from Moosh's EmptyBottle script. Leave it at 0 otherwise.
//d6 - Hide price. Set this to 1 to not display the price below the FFC.
//d7 - Shop Index. This is used to differentiate shops by a global index, used for a special value of 2. Set to -1 if you don't care about this.

To change the messages:
Modify the strings inside the 'void run' function.
shopbuystr - the prompt to buy something. This should run a menu, and run '@set(@ttemp 1)' if the item is going to be bought.
boughtstr - displayed after you buy the item
notboughtstr - displayed if you say no to buying the item
nobottlestr - displayed if you are missing a required empty bottle
nomoneystr - displayed if you don't have enough money