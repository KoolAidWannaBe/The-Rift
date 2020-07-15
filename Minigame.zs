
namespace MinecartGame
{
	CONFIG START_POS = 108;
	CONFIG COMBO_TARGET = 51252;
	CONFIG CF_TRACK = CF_SCRIPT1;
	CONFIG CF_END = CF_SCRIPT2;
	CONFIG OBJECT_LAYER = 1;
	CONFIG END_DELAY = 60 * 5;
	CONFIG COMBO_HEROCART = 30344;
	CONFIG TILE_ARROW = 341;
	CONFIG TILE_INVIS = ::TILE_INVIS;
	CONFIG CSET_ARROW = 8;
	CONFIG SPD_ARROW = 8;
	CONFIG SPD_CART = 2;
	CONFIG SFX_CART = 0;
	CONFIG SFX_CART_DELAY = 1;
	CONFIG MAX_SHOTS = 2;
	
	CONFIG FLAG_TRACK = 0x01;
	CONFIG FLAG_BLOCK = 0x02;
	CONFIG FLAG_TARGET = 0x03;
	CONFIG FLAG_END = 0x04;
	
	int mineCartGame(ffc person, int targCombo, int targCSet, int screen, int map, int numscreens) //start
	{
		combodata cd = Game->LoadComboData(COMBO_TARGET);
		cd->OriginalTile = TILE_INVIS;
		cd->Tile = TILE_INVIS;
		int returnScreen = Game->GetCurScreen();
		int returnDMap = Game->GetCurDMap();
		int ox = Hero->X;
		int oy = Hero->Y;
		int od = Hero->Dir;
		bitmap b = Game->CreateBitmap(16 * numscreens, 11);
		generateMap(b, screen, map, numscreens);
		
		Hero->Invisible = true;
		Hero->X = ComboX(START_POS);
		Hero->Y = ComboY(START_POS);
		untyped arr[] = {Hero->X};
		int clk;
		until(Game->GetCurScreen() == screen)
		{
			TotalNoAction();
			moveCart(NULL, arr);
			Hero->X = arr[Z3CART_X];
			Screen->DrawCombo(4, Hero->X, Hero->Y - 16, COMBO_HEROCART + Hero->Dir, 1, 2, 6, -1, -1, 0, 0, 0, 0, 0, true, OP_OPAQUE);
			unless(clk++ % SFX_CART_DELAY) Audio->PlaySound(SFX_CART);
			if(Hero->X > 240)person->Flags[FFCF_LENSVIS] = true;
			Waitframe();
		}
		int scroll;
		arr[Z3CART_X] = 0;
		//int lx = -500, ly = -500, ld = -1;
		int score;
		lweapon lweap[MAX_SHOTS];
		while(true)
		{
			for(int q = 0; q < MAX_SHOTS; ++q)
			{
				unless(lweap[q]->isValid()) lweap[q] = NULL;
			}
			if(moveCart(b, arr) == FLAG_END) break;
			if(arr[Z3CART_X] < 120) Hero->X = arr[Z3CART_X];
			else
			{
				for(int q = 0; q < MAX_SHOTS; ++q)
				{
					unless(lweap[q]) continue;
					lweap[q]->X -= Hero->X - 120;
				}
				Hero->X = 120;
				scroll = arr[Z3CART_X] - 120;
			}
			for(int q = 0; q < MAX_SHOTS; ++q)
			{
				if(lweap[q])
				{
					if(lweap[q]->X < 0 || lweap[q]->X > 256 || lweap[q]->Y < 0 || lweap[q]->Y > 176)
					{
						Remove(lweap[q]);
						lweap[q] = NULL;
					}
				}
			}
			for(int q = 0; q < MAX_SHOTS; ++q)
			{
				if(!lweap[q] && (Input->Press[CB_A] || Input->Press[CB_B]))
				{
					lweap[q] = Screen->CreateLWeapon(LW_SCRIPT1);
					lweap[q]->Step = SPD_ARROW * 100;
					lweap[q]->CollDetection = false;
					lweap[q]->Dir = GetPressedDir();
					lweap[q]->X = Hero->X + dirX(lweap[q]->Dir) * 16;
					lweap[q]->Y = Hero->Y + dirY(lweap[q]->Dir) * 16;
					lweap[q]->CSet = CSET_ARROW;
					lweap[q]->OriginalTile = TILE_ARROW;
					switch(lweap[q]->Dir)
					{
						case DIR_DOWN:
							lweap[q]->Flip = FLIP_VERTICAL;
							break;
						case DIR_LEFT:
							lweap[q]->Flip = FLIP_HORIZONTAL;
							//fallthrough
						case DIR_RIGHT:
							++lweap[q]->OriginalTile;
							break;
					}
					lweap[q]->Tile = lweap[q]->OriginalTile;
					break;
				}
			}
			for(int q = 0; q < numscreens; ++q)
			{
				Screen->DrawScreen(7, map, screen + q, (q * 256) - scroll, 0, 0);
			}
			int sx = Div(scroll, 16);
			for(int x = 0; x < 17; ++x)
			{
				for(int y = 0; y < 12; ++y)
				{
					int c = b->GetPixel(x + sx, y) * 10000;
					for(int q; q < MAX_SHOTS; ++q)
					{
						unless(lweap[q]) continue;
						if(c == FLAG_BLOCK)
						{
							if(RectCollision(x * 16 - (scroll % 16), y * 16, x * 16 - (scroll % 16) + 15, y * 16 + 15, lweap[q]->X, lweap[q]->Y, lweap[q]->X + 15, lweap[q]->Y + 15))
							{
								Remove(lweap[q]);
								lweap[q] = NULL;
							}
						}
						else if(c == FLAG_TARGET)
						{
							if(RectCollision(x * 16 - (scroll % 16), y * 16, x * 16 - (scroll % 16) + 15, y * 16 + 15, lweap[q]->X, lweap[q]->Y, lweap[q]->X + 15, lweap[q]->Y + 15))
							{
								Remove(lweap[q]);
								lweap[q] = NULL;
								b->PutPixel(0, x + sx, y, 0, 0, 0, 0, OP_OPAQUE);
								++score;
							}
						}
					}
					if(c == FLAG_TARGET) Screen->FastCombo(7, x * 16 - (scroll % 16), y * 16, targCombo, targCSet, OP_OPAQUE);
				}	
			}
			Screen->DrawCombo(7, Hero->X, Hero->Y - 16, COMBO_HEROCART + Hero->Dir, 1, 2, 6, -1, -1, 0, 0, 0, 0, 0, true, OP_OPAQUE);
			for(int q = 0; q < MAX_SHOTS; ++q)
			{
				if(lweap[q])
				{
					Screen->DrawTile(7, lweap[q]->X, lweap[q]->Y, lweap[q]->Tile, 1, 1, lweap[q]->CSet, -1, -1, 0, 0, 0, lweap[q]->Flip, true, OP_OPAQUE);
				}
			}
			TotalNoAction();
			unless(clk++ % SFX_CART_DELAY) Audio->PlaySound(SFX_CART);
			Waitframe();
		}
		int loop;
		do
		{
			loop = (loop + SPD_CART) % 32;
			for(int q = 0; q < numscreens; ++q)
			{
				Screen->DrawScreen(7, map, screen + q, (q * 256) - (scroll + loop), 0, 0);
			}
			Screen->DrawCombo(7, Hero->X, Hero->Y - 16, COMBO_HEROCART + Hero->Dir, 1, 2, 6, -1, -1, 0, 0, 0, 0, 0, true, OP_OPAQUE);
			unless(clk++ % SFX_CART_DELAY) Audio->PlaySound(SFX_CART);
			TotalNoAction();
			Waitframe();
		}
		until(Input->Press[CB_A] || Input->Press[CB_START]);
		Hero->WarpEx({WT_IWARP, returnDMap, returnScreen, ox, oy, WARPEFFECT_NONE, 0, 0, od});
		Waitframe();
		person->Flags[FFCF_LENSVIS] = false;
		Hero->Invisible = false;
		b->Free();
		return score;
	} //end
	
	enum 
	{
		Z3CART_X
	};
	
	int moveCart(bitmap b, untyped arr) //start
	{
		if(arr[Z3CART_X] % 16 || Hero->Y % 16)
		{
			arr[Z3CART_X] += dirX(Hero->Dir) * SPD_CART;
			Hero->Y += dirY(Hero->Dir) * SPD_CART;
			return 0;
		}
		if(b) //start
		{
			if(b->GetPixel(Div(arr[Z3CART_X], 16) + 1, Div(Hero->Y, 16)) * 10000 == FLAG_TRACK)
			{
				arr[Z3CART_X] += SPD_CART;
				Hero->Dir = DIR_RIGHT;
				return 0;
			}
			if(Hero->Dir == DIR_DOWN)
			{
				if(b->GetPixel(Div(arr[Z3CART_X], 16), Div(Hero->Y, 16) + 1) * 10000 == FLAG_TRACK)
				{
					Hero->Y += SPD_CART;
					Hero->Dir = DIR_DOWN;
					return 0;
				}
				if(b->GetPixel(Div(arr[Z3CART_X], 16), Div(Hero->Y, 16) - 1) * 10000 == FLAG_TRACK)
				{
					Hero->Y -= SPD_CART;
					Hero->Dir = DIR_UP;
					return 0;
				}
			}
			else
			{
				if(b->GetPixel(Div(arr[Z3CART_X], 16), Div(Hero->Y, 16) - 1) * 10000 == FLAG_TRACK)
				{
					Hero->Y -= SPD_CART;
					Hero->Dir = DIR_UP;
					return 0;
				}
				if(b->GetPixel(Div(arr[Z3CART_X], 16), Div(Hero->Y, 16) + 1) * 10000 == FLAG_TRACK)
				{
					Hero->Y += SPD_CART;
					Hero->Dir = DIR_DOWN;
					return 0;
				}
			}
			return b->GetPixel(Div(arr[Z3CART_X], 16) + 1, Div(Hero->Y, 16)) * 10000;
		} //end
		else // start
		{
			mapdata m = Game->LoadMapData(Game->GetCurMap(), Game->GetCurScreen());
			mapdata m2 = (OBJECT_LAYER ? (m->LayerMap[OBJECT_LAYER] ? Game->LoadMapData(m->LayerMap[OBJECT_LAYER], m->LayerScreen[OBJECT_LAYER]) : NULL) : m);
			unless(m2) return 0;
			int pos = ComboAt(arr[Z3CART_X] + 16, Hero->Y);
			if(((arr[Z3CART_X] + 16) > 255) || m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK) 
			{
				arr[Z3CART_X] += SPD_CART;
				Hero->Dir = DIR_RIGHT;
				return 0;
			}
			if(Hero->Dir == DIR_DOWN)
			{
				pos = ComboAt(arr[Z3CART_X], Hero->Y + 16);
				if(m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK) 
				{
					Hero->Y += SPD_CART;
					Hero->Dir = DIR_DOWN;
					return 0;
				}
				pos = ComboAt(arr[Z3CART_X], Hero->Y - 16);
				if(m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK) 
				{
					Hero->Y -= SPD_CART;
					Hero->Dir = DIR_UP;
					return 0;
				}
			}
			else
			{
				pos = ComboAt(arr[Z3CART_X], Hero->Y - 16);
				if(m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK) 
				{
					Hero->Y -= SPD_CART;
					Hero->Dir = DIR_UP;
					return 0;
				}
				pos = ComboAt(arr[Z3CART_X], Hero->Y + 16);
				if(m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK) 
				{
					Hero->Y += SPD_CART;
					Hero->Dir = DIR_DOWN;
					return 0;
				}
			}
		} //end
		return 0;
	} //end
	void generateMap(bitmap b, int screen, int map, int numscreens) //start
	{
		b->Clear(0);
		for(int q = 0; q < numscreens; ++q)
		{
			mapdata m = Game->LoadMapData(map, screen + q);
			mapdata m2 = (OBJECT_LAYER ? (m->LayerMap[OBJECT_LAYER] ? Game->LoadMapData(m->LayerMap[OBJECT_LAYER], m->LayerScreen[OBJECT_LAYER]) : NULL) : m);
			unless(m2) continue;
			for(int x = 0; x < 256; x += 16)
			{
				for(int y = 0; y < 176; y += 16)
				{
					int pos = ComboAt(x, y);
					int c;
					if(m2->ComboF[pos] == CF_TRACK || m2->ComboI[pos] == CF_TRACK)
					{
						c = FLAG_TRACK;
					}
					else if(m2->ComboF[pos] == CF_END || m2->ComboI[pos] == CF_END)
					{
						c = FLAG_END;
					}
					else if(m2->ComboD[pos] == COMBO_TARGET)
					{
						c = FLAG_TARGET;
					}
					else switch(m2->ComboT[pos])
					{
						case CT_BLOCKALL:
						case CT_BLOCKARROW1:
						case CT_BLOCKARROW2:
						case CT_BLOCKARROW3:
							c = FLAG_BLOCK;
					}
					if(c)
						b->PutPixel(0, (q * 16) + (x / 16), y / 16, c, 0, 0, 0, OP_OPAQUE);
				}
			}
		}
	} //end
	int GetPressedDir() //start
	{
		if(Input->Button[CB_RIGHT]) return DIR_RIGHT;
		if(Input->Button[CB_UP]) return DIR_UP;
		if(Input->Button[CB_DOWN]) return DIR_DOWN;
		if(Input->Button[CB_LEFT]) return DIR_LEFT;
		return Hero->Dir;
	} //end
}



