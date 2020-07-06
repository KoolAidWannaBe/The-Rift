CONFIG COMBO_SHOP_INVIS = COMBO_INVIS; //A non-combo-0 invisible combo
CONFIG COMBO_SHOP_OUT_OF_STOCK = 65028; //A combo to display if the shop is "out of stock"
CONFIG FONT_PRICEDISPLAY = FONT_Z3SMALL; //Font to use for the price display
COLOR COLOR_PRICETEXT = C_WHITE; //Color for price display
CONFIG LAYER_PRICETEXT = 2;
bool UniqueShopData[2000]; //Must be larger than the highest shopIndex you use!
ffc script FFCShop
{
	void run(int itemID, int price, int shopSpecial, int visualYOffset, int priceYOffset, bool reqBottle, bool hidePrice, int shopIndex)
	{
		this->Data=COMBO_SHOP_INVIS;
		this->Y += visualYOffset;
		itemdata idata = Game->LoadItemData(itemID);
		if(shopSpecial != 0)
		{
			//If this shop needs to do anything special, put that code here.
			//For instance, not allowing buying a given item more than once, or something.
			switch(shopSpecial)
			{
				case 1:
					unless(idata->Keep) shopSpecial = 0; //Only works for equipment items!
					break;
				case 2:
					if(shopIndex<0) shopSpecial = 0; //Don't run on a negative index!
					break;
			}
		}
		unless(itemID) Quit(); //No item to sell.
		int shopbuystr[] = "Hello, would you like to buy ((@string(@shopstr))) for [[@number(@sprice)]] rupees? @26<<@choice(1)Yes@choice(2)No>>@domenu(1)@if(@equal(@chosen 1) @set(@ttemp 1))@close()";
		int boughtstr[] = "Thank you for your purchase!";
		int notboughtstr[] = "No? Well if you need anything else, just ask.";
		int nobottlestr[] = "This ((@string(@shopstr))) costs [[@number(@sprice)]] rupees.@pressa() I can't sell you this unless you have an ((Empty Bottle))!";
		int nomoneystr[] = "This ((@string(@shopstr))) costs [[@number(@sprice)]] rupees. Come back with more money!";
		itemsprite thisVisual;
		int priceStr[16];
		itoa(priceStr, price);
		while(true)
		{
			until(AgainstPosition(this->X, this->Y-visualYOffset) && Hero->PressA)
			{
				switch(shopSpecial)
				{
					case 1:
					{
						if(Hero->Item[itemID])
						{
							//Set the "out of stock" combo, and remove the dummy item.
							this->Data = COMBO_SHOP_OUT_OF_STOCK;
							if(thisVisual->isValid())
								Remove(thisVisual);
							while(Hero->Item[itemID])
								Waitframe();
							this->Data = COMBO_SHOP_INVIS;
						}
						break;
					}
					case 2:
					{
						if(UniqueShopData[shopIndex]) //Permanently out of stock!
						{
							if(thisVisual->isValid())
								Remove(thisVisual);
							this->Data = COMBO_SHOP_OUT_OF_STOCK;
							Quit();
						}
						break;
					}
				}
				
				unless(thisVisual->isValid()) //Make sure the dummy item is always displaying while the shop is active
				{
					thisVisual = CreateItemAt(itemID, this->X, this->Y);
					thisVisual->Pickup=IP_DUMMY;
				}
				unless(hidePrice) drawPriceString(this->X+8, this->Y+16+priceYOffset-visualYOffset, priceStr);
				Waitframe();
			}
			Hero->InputA = false;
			Hero->PressA = false;
			//Set shop vars
			tangoTemp=false; //Set the default answer, if the menu is canceled out of, to "no"
			remchr(shopString,0);
			idata->GetName(shopString); //Load the item name into '@shopstr'
			shopPrice=price; //Load the item price into '@sprice'
			//
			//bool hasEmptyBottle = CanFillBottle(); //Use this version if Moosh's EmptyBottles script is being used
			bool hasEmptyBottle = false; //Use this version if Moosh's EmptyBottles script is NOT being used
			if((fullCounter(CR_RUPEES))>=price&&(!reqBottle||hasEmptyBottle))
			{
				ShowStringAndWait(shopbuystr); //Sets 'tangoTemp = true' if player says yes to buy item
				if(tangoTemp)
				{
					ShowStringAndWait(boughtstr);
					item itm = CreateItemAt(itemID, Hero->X, Hero->Y);
					itm->Pickup = IP_HOLDUP;
					Game->DCounter[CR_RUPEES] -= price;
					
					switch(shopSpecial)
					{
						case 1:
						{
							Remove(thisVisual);
							this->Data = COMBO_SHOP_OUT_OF_STOCK;
							WaitNoAction(10);
							break;
						}
						case 2:
						{
							Remove(thisVisual);
							this->Data = COMBO_SHOP_OUT_OF_STOCK;
							UniqueShopData[shopIndex] = true;
							WaitNoAction(10);
							Quit();
						}
						default:
						{
							for(int q = 0; q < 10; ++q)
							{
								unless(hidePrice) drawPriceString(this->X+8, this->Y+16+priceYOffset-visualYOffset, priceStr);
								WaitNoAction();
							}
							break;
						}
					}
				}
				else ShowStringAndWait(notboughtstr);
			}
			else if(reqBottle&&!hasEmptyBottle)
			{
				ShowStringAndWait(nobottlestr);
			}
			else
			{
				ShowStringAndWait(nomoneystr);
			}
		}
	}
	void drawPriceString(int x, int y, int priceStr)
	{
		Screen->DrawString(LAYER_PRICETEXT, x, y, FONT_PRICEDISPLAY, COLOR_PRICETEXT, -1, TF_CENTERED, priceStr, OP_OPAQUE);
	}
}
