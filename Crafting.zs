
namespace Crafting
{
	#option BINARY_32BIT on
	
	DEFINE REC_ARR_SIZE = 32;
	CONFIG COUNTER_FONT = FONT_Z3SMALL;
	CONFIG TILE_RARROW = 52260;

	enum Recipe
	{
		REC_NONE,
		REC_MAGIC_BOOMERANG,
		REC_LIGHT_ARROW,
		REC_MAX
	};

	enum CraftingStation
	{
		CS_NONE,
		CS_GENERAL = 1b,
		CS_ARMORSHOP = 10b
	};

	CraftingStation getStation(Recipe r)
	{
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
			case REC_LIGHT_ARROW:
				return CS_ARMORSHOP;
			default:
				return CS_NONE;
		}
	}
	
	void loadRecipe(untyped arr, Recipe r)
	{
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
				memcpy(arr, {0, 23, -CR_MAGICDUST, 15, 0}, 5);
				break;
			case REC_LIGHT_ARROW:
				memcpy(arr, {0, 13, -CR_MAGICDUST, 10, 0}, 5);
				break;
		}
		arr[0] = getStation(r);
	}
	
	bool canCraft(Recipe r, CraftingStation s)
	{
		if(s == CS_NONE) return true;
		untyped arr[REC_ARR_SIZE];
		loadRecipe(arr, r);
		unless(arr[0] == CS_NONE || arr[0] & s)
			return false;
		for(int q = 1; arr[q]; ++q)
		{
			if(arr[q] < 0)
			{
				unless(fullCounter(-arr[q]) >= arr[q + 1])
					return false;
				++q;
			}
			else
			{
				unless(Hero->Item[arr[q]])
					return false;
			}
		}
		return true;
	}
	
	void craft(Recipe r)
	{
		untyped arr[REC_ARR_SIZE];
		loadRecipe(arr, r);
		for(int q = 1; arr[q]; ++q)
		{
			if(arr[q] < 0)
			{
				Game->DCounter[-arr[q]] -= arr[q + 1];
				++q;
			}
			else
			{
				Hero->Item[arr[q]] = false;
			}
		}
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
				Hero->Item[24] = true;
				break;
			case REC_LIGHT_ARROW:
				Hero->Item[136] = true;
				break;
		}
	}
	void getOutputString(char32 buf, Recipe r)
	{
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
				strcpy(buf, "You crafted a ((Magic Boomerang))!");
				break;
			case REC_LIGHT_ARROW:
				strcpy(buf, "You crafted a ((Light Arrow))!");
				break;
		}
	}
	bitmap loadRecipes(CraftingStation s, untyped craftable)
	{
		int c;
		for(int q = 1; q < REC_MAX; ++q)
		{
			if(canCraft(<Recipe>q, s))
			{
				++c;
				craftable[q] = true;
			}			
		}
		craftable[0] = c;
		bitmap b = Game->CreateBitmap(188, 16 * c);
		int rIndex;
		for(int q = 1; q < REC_MAX; ++q)
		{
			unless(craftable[q]) continue;
			untyped arr[REC_ARR_SIZE];
			loadRecipe(arr, <Recipe> q);
			int index;
			for(int p = 1; arr[p]; ++p)
			{
				if(arr[p] < 0)
				{
					b->FastTile(0, 16 * index, 16 * rIndex, getCounterTile(-arr[p]), 0, OP_OPAQUE);
					char32 buf[11];
					itoa(buf, arr[++p]);
					b->DrawString(0, 16 * ++index - 1, 16 * rIndex + (16 - Text->FontHeight(COUNTER_FONT)), 
					              COUNTER_FONT, C_WHITE, C_TRANSBG, TF_RIGHT, buf, OP_OPAQUE);
				}
				else
				{
					itemdata ID = Game->LoadItemData(arr[p]);
					b->FastTile(0, 16 * index++, 16 * rIndex, ID->Tile, ID->CSet, OP_OPAQUE);
				}
			}
			b->FastTile(0, 188 - 32, 16 * rIndex, TILE_RARROW, 0, OP_OPAQUE);
			b->FastTile(0, 188 - 16, 16 * rIndex, getOutputTile(<Recipe>q), getOutputCSet(<Recipe>q), OP_OPAQUE);
			++rIndex;
		}
		b->Write(7, "recipe.png", true);
		return b;
	}
	
	int getCounterTile(int counter)
	{
		switch(counter)
		{
			case CR_MAGICDUST:
				return 52001;
			default:
				return TILE_INVIS;
		}
	}
	
	int getOutputTile(Recipe r)
	{
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
				return Game->LoadItemData(24)->Tile;
			case REC_LIGHT_ARROW:
				return Game->LoadItemData(136)->Tile;
			default:
				return TILE_INVIS;
		}
	}
	
	int getOutputCSet(Recipe r)
	{
		switch(r)
		{
			case REC_MAGIC_BOOMERANG:
				return Game->LoadItemData(24)->CSet;
			case REC_LIGHT_ARROW:
				return Game->LoadItemData(136)->CSet;
			default:
				return 0;
		}
	}
	
}








