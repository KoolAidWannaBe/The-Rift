//start global constants / variables

CONFIG TILE_INVIS = 56;
CONFIG COMBO_INVIS = 448;
CONFIGB DEBUG = true;
DEFINE CR_MAGICDUST = CR_SCRIPT1;

enum Opt //start
{
	OPT_KEY,
	OPT_CORNERBUFFS,
	OPT_CORNERBUFFS_KEY,
	OPT_OPTIONS_FONT,
	SZ_OPT
};
untyped opt[SZ_OPT] = {KEY_TAB, false, KEY_B, OptMenu::MENU_FONT_DEFAULT};
//end 

enum Color //start
{
	C_TRANSBG	= -0x01,
	C_TRANS		=  0x00,
	C_WHITE		=  0x01,
	C_BLACK		=  0x0F,
	
	C_LGRAY		=  0x5C,
	C_GRAY		=  0x5D,
	C_DGRAY 	=  0x5E,
	C_RED		=  0x6D,
	C_DRED		=  0x6E,
	C_YELLOW	=  0x1A,
	C_GREEN		=  0x13,
	C_DGREEN	=  0x15,
	C_CYAN 		=  0x07,
	C_LILLAC	=  0x96
	
};
typedef const Color COLOR;
//end

//start global array

untyped G[MAX_INT];
enum
{
	GV_ANPC,
	GV_TANGO_SLOT_MAIN,
	GV_TANGO_SLOT_NPC,
	GV_FLAGS1
};

enum
{
	GF_TRACK_CLEARED,
	GF_TRACK_HEARTPIECE
};

//end

//end

@Author ("KoolAidWannaBe")
global script Active
{
	void run()
	{
		if(DEBUG) debug();
		ClearDebugTiles();
		OptMenu::init_menu_bitmap();
		TangoInit();
		while(true)
		{
			OptMenu::options();
			Tango_Update1();
			Waitdraw();
			Tango_Update2();
			Waitframe();
		}
	}
	void debug()
	{
		Game->Cheat = 4;
		//Crafting::loadRecipes(Crafting::CS_NONE);
	}
	void ClearDebugTiles()
	{
		int arr[] = {240, 241};
		for(int q = SizeOfArray(arr) - 1; q >= 0; --q)
		{
			CopyTile(TILE_INVIS, arr[q]);
		}
	}
}

namespace OptMenu //start
{
	//start States and Tabs
	enum MenuState
	{
		STATE_MAIN = -1,
		STATE_CORNERBUFFS,
		STATE_OPTKEY,
		STATE_CORNERBUFFKEY,
		STATE_FONT,
		STATE_RESET,
		STATE_MAX
	};
	
	enum MenuTab
	{
		TAB_INVALID = -1,
		TAB_OPT,
		TAB_CONTROL,
		TAB_SYSTEM,
		TAB_END
	};
	
	MenuState menuTabs[] = {STATE_CORNERBUFFS, STATE_OPTKEY, STATE_FONT, STATE_MAX};
	//end
	
	//start Menu constants and vars
	bitmap menu;
	
	CONFIG MENU_SPACING = 16;
	CONFIG MENU_FONT_DEFAULT = FONT_Z3SMALL;
	CONFIG MENU_FONT_TABS = FONT_Z3SMALL;
	CONFIG MENU_TAB_MARGIN = 24;
	CONFIG MENU_TOP_MARGIN_HEIGHT = 16 + MENU_TAB_MARGIN;
	CONFIG MENU_LEFT_MARGIN_WIDTH = 16;
	CONFIG MENU_RIGHT_MARGIN_WIDTH = 16;
	CONFIG MENU_BOTTOM_MARGIN_HEIGHT = 32;
	CONFIG MENU_LAYER = 7;
	CONFIG MENU_SCROLL_INC = 8;
	CONFIG MENU_SCROLL_SPEED = 8;
	CONFIG MENU_BEEP_SFX = 0;
	
	CONFIG INPUT_DELAY = 30;
	
	COLOR MENU_COLOR_INACTIVE_PERM  = C_WHITE;
	COLOR MENU_COLOR_INACTIVE_TEMP  = C_LGRAY;
	COLOR MENU_COLOR_DEACTIVATED	= C_DGRAY;
	COLOR MENU_COLOR_ACTIVE 		= C_YELLOW;
	COLOR MENU_COLOR_CONTROLS 		= C_LILLAC;
	COLOR MENU_COLOR_TABS 			= C_CYAN;
	
	CONFIGB MENU_ENFORCE_MARGINS = true;
	
	DEFINE MENU_SCREEN_WIDTH = 256;
	DEFINE MENU_NUM_BITMAPS = TAB_END + 1;
	DEFINE MENU_LEFT_MARGIN = MENU_LEFT_MARGIN_WIDTH;
	DEFINE MENU_RIGHT_MARGIN = 255 - MENU_RIGHT_MARGIN_WIDTH;
	DEFINE MENU_BOTTOM_MARGIN = 168 - MENU_BOTTOM_MARGIN_HEIGHT;
	
	DEFINE MENU_CONTROL_X = 0;
	DEFINE MENU_CONTROL_Y = 0;
	DEFINE MENU_START_TABS_X = MENU_SCREEN_WIDTH;
	DEFINE MENU_PERM_Y = 0;
	
	DEFINE MENU_BITMAP_WIDTH = MENU_SCREEN_WIDTH * MENU_NUM_BITMAPS;
	DEFINE MENU_TABS_WIDTH = TAB_END * MENU_SCREEN_WIDTH;
	
	DEFINE MENU_CONTROL_LIST = MENU_SCREEN_WIDTH * 2;
	
	DEFINE MIN_FONT = FONT_Z1;
	DEFINE MAX_FONT = FONT_LISA;
	
	int MenuVars[MV_MAX];
	enum MV
	{
		MV_FONT_HEIGHT, 
		MV_MAX_OPT_PER_TAB,
		MV_M_HEIGHT,
		MV_OPT_HEIGHT,
		MV_TEMP_Y,
		MV_BMP_HEIGHT,
		MV_MAX_SCROLL,
		MV_TOP_MENU,
		MV_VIS_SCREEN_HEIGHT,
		MV_TOP_MARGIN,
		MV_TAB_LABEL_Y,
		MV_MAX
	};
	//end
	
	void updateSize() //start
	{
		MenuVars[MV_TOP_MENU] = subscreenHidden() ? 0 : -56;
		MenuVars[MV_VIS_SCREEN_HEIGHT] = 168 - MenuVars[MV_TOP_MENU];
		MenuVars[MV_TOP_MARGIN] = MenuVars[MV_TOP_MENU] + MENU_TOP_MARGIN_HEIGHT;
		MenuVars[MV_TAB_LABEL_Y] = MenuVars[MV_TOP_MARGIN] - Text->FontHeight(MENU_FONT_TABS) - MENU_TAB_MARGIN;
	} //end
	void updateOptFont(int font) //start
	{
		updateSize();
		opt[OPT_OPTIONS_FONT] = font;
		MenuVars[MV_FONT_HEIGHT] = Text->FontHeight(opt[OPT_OPTIONS_FONT]);
		MenuVars[MV_M_HEIGHT] = (MenuVars[MV_MAX_OPT_PER_TAB] * (MENU_SPACING + MenuVars[MV_FONT_HEIGHT] * 2)) - MENU_SPACING + MENU_TOP_MARGIN_HEIGHT + MENU_BOTTOM_MARGIN_HEIGHT;
		MenuVars[MV_OPT_HEIGHT] = Max(MenuVars[MV_M_HEIGHT], MenuVars[MV_VIS_SCREEN_HEIGHT]);
		MenuVars[MV_TEMP_Y] = MenuVars[MV_OPT_HEIGHT];
		MenuVars[MV_MAX_SCROLL] = MenuVars[MV_OPT_HEIGHT] - MenuVars[MV_VIS_SCREEN_HEIGHT];
		MenuVars[MV_BMP_HEIGHT] = MenuVars[MV_OPT_HEIGHT] * 2;
		init_menu_bitmap(true);			//force recreate bitmap for new size
		menu->Rectangle(0, 0, 0, MENU_BITMAP_WIDTH, MenuVars[MV_BMP_HEIGHT], C_TRANS, 1, 0, 0, 0, true, OP_OPAQUE); //clear bitmap for 1 frame before reloading
		reloadMenuBitmap(menu);
	} //end
	
	void incOptFont(int dir) //start
	{
		if(dir == DIR_UP)
		{
			do
			{
				if(++opt[OPT_OPTIONS_FONT] > MAX_FONT) opt[OPT_OPTIONS_FONT] = MIN_FONT;
			}
			until(validFont(opt[OPT_OPTIONS_FONT]));
		}
		else if(dir == DIR_DOWN)
		{
			do
			{
				if(--opt[OPT_OPTIONS_FONT] < MIN_FONT) opt[OPT_OPTIONS_FONT] = MAX_FONT;
			}
			until(validFont(opt[OPT_OPTIONS_FONT]));
		}
		updateOptFont(opt[OPT_OPTIONS_FONT]);
	} //end
	
	bool validFont(int font) //start
	{
		switch (font)
		{
			case FONT_ZTIME:
			case FONT_SUBSCREEN1:
			case FONT_SUBSCREEN2:
			case FONT_SUBSCREEN4:
			case FONT_GORON:
			case FONT_ZORAN:
			case FONT_HYLIAN1:
			case FONT_HYLIAN2:
			case FONT_HYLIAN3:
			case FONT_HYLIAN4:
			case FONT_DSPHANTOM:
			case FONT_APPLE2_80COL:
			case FONT_C64_HIRES:
			case FONT_COCO:
			case FONT_FDS_KANA:
			case FONT_FUTHARK:
			case FONT_HIRA:
			case FONT_JP:
			case FONT_SPECTRUM_LG:
				return false;
			default: 
				return true;
		}
	} //end
	
	int optionScrollCheck(MenuState option, int scroll) //start
	{
		option = <MenuState>(option - menuTabs[getTab(option)]);
		int optTop = menuPosY(option);
		int optBot = optTop + MenuVars[MV_FONT_HEIGHT] + MENU_SPACING;
		if(optTop < scroll + (MENU_ENFORCE_MARGINS ? MENU_TOP_MARGIN_HEIGHT : 0))
			return -1;
		if(optBot > scroll + MenuVars[MV_VIS_SCREEN_HEIGHT] - (MENU_ENFORCE_MARGINS ? MENU_BOTTOM_MARGIN_HEIGHT : 0))
			return 1;
		return 0;
	} //end
	
	//start Init Stuff
	void init()
	{
		for(int q = 0; q < TAB_END; ++q)
		{
			int numOpt = tabNumOpts(<MenuTab>q);
			if (numOpt > MenuVars[MV_MAX_OPT_PER_TAB]) MenuVars[MV_MAX_OPT_PER_TAB] = numOpt;
		}
		updateOptFont(opt[OPT_OPTIONS_FONT]);
	}
	
	void init_menu_bitmap()
	{
		init_menu_bitmap(false);
	}
	void init_menu_bitmap(bool force)
	{
		printf("menu:%d\n", menu); 
		unless(menu->isAllocated()) menu = Game->CreateBitmap(MENU_BITMAP_WIDTH, MenuVars[MV_BMP_HEIGHT]);
		else if(force || !menu->isValid())
		{
			menu->Free();
			menu = Game->CreateBitmap(MENU_BITMAP_WIDTH, MenuVars[MV_BMP_HEIGHT]);
		}		
		printf("menu:%d\n", menu); 
	}
	//end
	
	void options() //start
	{
		if(Input->KeyPress[opt[OPT_KEY]])
		{
			Screen_Freeze(FREEZE_ACTION);
			int scroll = 0;
			int mainOption = 0;
			int subOption = 0;
			int tab = 0;
			int x = getTabPos(<MenuTab>tab);
			int lastLR = -1;
			int cooldown = 0;
			int inputTimer = 0;
			MenuState state = STATE_MAIN;
			updateOptFont(opt[OPT_OPTIONS_FONT]);
			flashScreen(C_BLACK, true);
			WaitTotalNoAction();
			reloadMenuBitmap(menu);
			
			while(true)
			{
				Waitdraw();
				if(cooldown > 0) --cooldown;
				inputTimer = ++inputTimer % INPUT_DELAY;
				loadMenuTempBitmap(menu);
				bool confirm = Input->Press[CB_A] || keyCheck(KEY_ENTER) || keyCheck(KEY_ENTER_PAD);
				bool deny = Input->Press[CB_B] || keyCheck(KEY_BACKSPACE);
				const bool up = Input->Press[CB_UP] || (Input->Button[CB_UP] && !inputTimer);
				const bool down = Input->Press[CB_DOWN] || (Input->Button[CB_DOWN] && !inputTimer);
				const bool left = Input->Press[CB_LEFT] || (Input->Button[CB_LEFT] && !inputTimer);
				const bool right = Input->Press[CB_RIGHT] || (Input->Button[CB_RIGHT] && !inputTimer);
				if(Input->Press[CB_UP] || Input->Press[CB_DOWN] || Input->Press[CB_LEFT] || Input->Press[CB_RIGHT]) inputTimer = 0;
				if(confirm || deny || up || down || left || right) Audio->PlaySound(MENU_BEEP_SFX);
				if(deny)
				{
					if(state == STATE_MAIN)
						break;
					else state = STATE_MAIN;
				}
				else if(Input->KeyPress[opt[OPT_KEY]])
					break;
				switch (state) //start
				{
					case STATE_MAIN: //start
					{
						unless(mainOption - menuTabs[getTab(<MenuState>mainOption)]) scroll = 0;
						else 
						{
							while(optionScrollCheck(<MenuState>mainOption, scroll) == 1)
								scroll += MENU_SCROLL_INC;
							while(optionScrollCheck(<MenuState>mainOption, scroll) == -1)
								scroll -= MENU_SCROLL_INC;
							scroll = VBound(scroll, MenuVars[MV_MAX_SCROLL], 0);
						}
						switch (mainOption)
						{
							case STATE_CORNERBUFFS:
								DrawMenuString("Buffs In Corner", menu, 2, getTabPos(<MenuState>mainOption) + MENU_LEFT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption), MENU_COLOR_ACTIVE, TF_NORMAL);
								break;
							case STATE_OPTKEY:
								DrawMenuString("Options Menu", menu, 2, getTabPos(<MenuState>mainOption) + MENU_LEFT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption), MENU_COLOR_ACTIVE, TF_NORMAL);
								break;
							case STATE_CORNERBUFFKEY:
								DrawMenuString("Toggle Buff Placement", menu, 2, getTabPos(<MenuState>mainOption) + MENU_LEFT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption), MENU_COLOR_ACTIVE, TF_NORMAL);
								break;
							case STATE_FONT:
								DrawMenuString("Font", menu, 2, getTabPos(<MenuState>mainOption) + MENU_LEFT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption), MENU_COLOR_ACTIVE, TF_NORMAL);
								break;
							case STATE_RESET:
								DrawMenuString("Reset All to Default", menu, 2, getTabPos(<MenuState>mainOption) + MENU_LEFT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption), MENU_COLOR_ACTIVE, TF_NORMAL);
								break;
						}
						if(confirm)
						{
							state = <MenuState>mainOption;
							subOption = 0;
						}
						else if(up)
							--mainOption;
						else if(down)
							++mainOption;
						else unless(cooldown)
						{
							if(left)
							{
								lastLR = DIR_LEFT;
								if(--tab < 0) tab += TAB_END;
								mainOption = menuTabs[tab];
								cooldown = 10;
							}
							else if(right) 
							{
								lastLR = DIR_RIGHT;
								if(++tab >= TAB_END) tab -= TAB_END;
								mainOption = menuTabs[tab];
								cooldown = 10;
							}
						}
						//limit options scrolling to within tab
						mainOption = wrapOpt(<MenuState> mainOption, tab);
						break;
					} //end
					
					case STATE_CORNERBUFFS: //start
					{
						DrawMenuString(opt[OPT_CORNERBUFFS] ? "   On" : "Off", menu, 2, getTabPos(<MenuState>mainOption) + MENU_RIGHT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption) + MenuVars[MV_FONT_HEIGHT], opt[OPT_CORNERBUFFS] ? C_GREEN : C_RED, TF_RIGHT);
						if(confirm) opt[OPT_CORNERBUFFS] = !opt[OPT_CORNERBUFFS];
						break;
					} //end
					case STATE_OPTKEY: //start
					{
						char32 buf[64];
						KeyToString(opt[OPT_KEY], buf, true, true);
						DrawMenuString(buf, menu, 2, getTabPos(<MenuState>mainOption) + MENU_RIGHT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption) + MenuVars[MV_FONT_HEIGHT], MENU_COLOR_ACTIVE, TF_RIGHT);
						if(Input->Button[CB_A]) break;	//Dont take input while A is held
						int key = getKeyPress();
						switch (isValidKey(key))
						{
							case KV_VALID:
								opt[OPT_KEY] = key;
								//Fall-through
							case KV_QUIT:
								state = STATE_MAIN;
								//Game->TypingMode = false;
								break;
						}
						break;
					} //end
					case STATE_CORNERBUFFKEY: //start
					{
						char32 buf[64];
						KeyToString(opt[OPT_CORNERBUFFS_KEY], buf, true, true);
						DrawMenuString(buf, menu, 2, getTabPos(<MenuState>mainOption) + MENU_RIGHT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption) + MenuVars[MV_FONT_HEIGHT], MENU_COLOR_ACTIVE, TF_RIGHT);
						if(Input->Button[CB_A]) break;	//Dont take input while A is held
						int key = getKeyPress();
						switch (isValidKey(key))
						{
							case KV_VALID:
								opt[OPT_CORNERBUFFS_KEY] = key;
								//Fall-through
							case KV_QUIT:
								state = STATE_MAIN;
								Game->TypingMode = false;
								break;
						}
						break;
					} //end
					case STATE_FONT: //start
					{
						char32 buf[64];
						getFontName(buf, opt[OPT_OPTIONS_FONT]);
						DrawMenuString(buf, menu, 2, getTabPos(<MenuState>mainOption) + MENU_RIGHT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption) + MenuVars[MV_FONT_HEIGHT], MENU_COLOR_ACTIVE, TF_RIGHT);
						if(down || right) incOptFont(DIR_UP);
						else if (up || left) incOptFont(DIR_DOWN);
						break;
					} //end
					case STATE_RESET: //start
					{
						DrawMenuString("Are you sure?", menu, 2, getTabPos(<MenuState>mainOption) + MENU_RIGHT_MARGIN, MenuVars[MV_TEMP_Y] + menuPosY(<MenuState>mainOption) + MenuVars[MV_FONT_HEIGHT], MENU_COLOR_ACTIVE, TF_RIGHT);
						if(confirm)
						{
							resetAllOpts();
							return;
						}
					} //end
				} //end
				Screen->Rectangle(MENU_LAYER, 0, MenuVars[MV_TOP_MENU], 256, MenuVars[MV_VIS_SCREEN_HEIGHT], C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
				
				//start Tab calcs
				
				int destX = getTabPos(<MenuTab>tab);
				if(destX != x)
				{
					int cmp = comp(destX, x);
					int ldist, rdist;
					for(int lx = x; lx != destX; --lx)
					{
						if(lx < MENU_START_TABS_X) lx += MENU_TABS_WIDTH;
						++ldist;
					}
					for(int rx = x; rx != destX; ++rx)
					{
						if(rx >= MENU_START_TABS_X + MENU_TABS_WIDTH - 1) rx -= MENU_TABS_WIDTH;
						++rdist;
					}
					x += ldist < rdist ? -MENU_SCROLL_SPEED : (rdist < ldist ? MENU_SCROLL_SPEED : (lastLR == DIR_LEFT ? -MENU_SCROLL_SPEED : MENU_SCROLL_SPEED));
					if(cmp != comp(destX, x)) x = destX;
					else if(x < MENU_START_TABS_X) x += MENU_TABS_WIDTH;
					else if(x >= MENU_START_TABS_X + MENU_TABS_WIDTH) x -= MENU_TABS_WIDTH;
				}
				
				//end
				
				if(Input->Button[CB_START])
					menu->Blit(MENU_LAYER, RT_SCREEN, MENU_CONTROL_X, MENU_CONTROL_Y, 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, MenuVars[MV_TOP_MENU], 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, BITDX_NORMAL, 0, true);
				else 
				{
					menu->Blit(MENU_LAYER, RT_SCREEN, x, scroll + MENU_PERM_Y, 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, MenuVars[MV_TOP_MENU], 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, BITDX_NORMAL, 0, true);
					menu->Blit(MENU_LAYER, RT_SCREEN, x, scroll + MenuVars[MV_TEMP_Y], 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, MenuVars[MV_TOP_MENU], 256, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, BITDX_NORMAL, 0, true);
					int wid = MENU_BITMAP_WIDTH - x + 1;
					if(wid < 256)
					{
						menu->Blit(MENU_LAYER, RT_SCREEN, MENU_START_TABS_X, scroll + MENU_PERM_Y, 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], wid, MenuVars[MV_TOP_MENU], 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, 0, 0, true);
                        menu->Blit(MENU_LAYER, RT_SCREEN, MENU_START_TABS_X, scroll + MenuVars[MV_TEMP_Y], 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], wid, MenuVars[MV_TOP_MENU], 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, 0, 0, true);
					}
					
				}
				if(MENU_ENFORCE_MARGINS)
				{
					Screen->Rectangle(MENU_LAYER, 0,                 MenuVars[MV_TOP_MENU],              256,                  MenuVars[MV_TOP_MARGIN] - 1, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, 0,                 MenuVars[MV_TOP_MENU],              MENU_LEFT_MARGIN - 1, 176,                         C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, MENU_RIGHT_MARGIN, MenuVars[MV_TOP_MENU],              256,                  176,                         C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, 0,                 168 - MENU_BOTTOM_MARGIN_HEIGHT,    256,                  176,                         C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
				}
				//OptMenuTab names
				char32 buf1[32], buf2[32], buf3[32];
				getTabName(buf1, wrapOptTab(<MenuTab>(tab -1 )));
				getTabName(buf2, wrapOptTab(<MenuTab>tab));
				getTabName(buf3, wrapOptTab(<MenuTab>(tab + 1)));
				Screen->DrawString(MENU_LAYER,  64, MenuVars[MV_TAB_LABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf1, OP_OPAQUE);
				Screen->DrawString(MENU_LAYER, 128, MenuVars[MV_TAB_LABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf2, OP_OPAQUE);
				Screen->DrawString(MENU_LAYER, 192, MenuVars[MV_TAB_LABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf3, OP_OPAQUE);
				//Controls
				DrawStrings(MENU_LAYER, 128, MENU_BOTTOM_MARGIN + Text->FontHeight(MENU_FONT_TABS), MENU_FONT_TABS, MENU_COLOR_CONTROLS, C_TRANSBG, TF_CENTERED, "ENTER/(A): Confirm | BACKSPACE/(B): Back\n(START): Info | (UP)/(DOWN): Switch options\n(LEFT)/(RIGHT): Switch Tabs", OP_OPAQUE, 2, 256-(MENU_RIGHT_MARGIN_WIDTH + MENU_LEFT_MARGIN_WIDTH));
				
				if(keyCheck(KEY_U))	menu->Write(7, "MenuBitmap.png", true);
				TotalNoAction();
				Waitframe();
			}
			TotalNoAction();
			reloadOptions();
			Screen_Freeze(FREEZE_NONE);
		}
	} //end
	
	bool keyCheck(int key) //start
	{
		for(int q = 0; q<14; ++q)
		{
			if(Input->KeyBindings[q] == key) return false;
		}
		return Input->KeyPress[key]; 
	} //end
	
	int menuPosY(MenuState opt)
	{
		int optHei = opt - menuTabs[getTab(opt)];
		return MENU_TOP_MARGIN_HEIGHT + ((MENU_SPACING + MenuVars[MV_FONT_HEIGHT] * 2) * optHei);
	}
	
	int tabNumOpts(MenuState opt)
	{
		return tabNumOpts(getTab(opt));
	}
	
	int tabNumOpts(MenuTab tab)
	{
		return menuTabs[tab + 1] - menuTabs[tab];
	}
	
	void reloadOptions()
	{
		Status::statusPos = opt[OPT_CORNERBUFFS] ? Status::SP_TOP_LEFT : Status::SP_ABOVE_HEAD;
	}
	
	//start drawing
	void reloadMenuBitmap(bitmap menu) //start
	{
		menu->Rectangle(0, 0, 0, MENU_BITMAP_WIDTH, MenuVars[MV_BMP_HEIGHT], C_TRANS, 1, 0, 0, 0, true, OP_OPAQUE);
		int x = MENU_START_TABS_X + MENU_LEFT_MARGIN_WIDTH;
		DEFINE TOP_Y = MENU_TOP_MARGIN_HEIGHT;
		int y = TOP_Y;
		
		//
		// "Options"
		//
		
		DrawMenuString("Buffs In Corner", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_NORMAL);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		//
		// "Controls"
		//
		
		x += MENU_SCREEN_WIDTH;
		y = TOP_Y;
		
		DrawMenuString("Options Menu", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_NORMAL);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		DrawMenuString("Toggle Buff Placement", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_NORMAL);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		//
		// "System"
		//
		
		x += MENU_SCREEN_WIDTH;
		y = TOP_Y;
		
		DrawMenuString("Font", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_NORMAL);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		DrawMenuString("Reset All to Default", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_NORMAL);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		///////////////////////////////////////////////////////
		// ""
		///////////////////////////////////////////////////////
		
		x = MENU_CONTROL_X + 128;
		y = TOP_Y;
		
		DrawMenuStrings("When control binding:\nPress any keyboard key to bind it.\nConflicting binds may cause issues.", menu, 0, x, y, MENU_COLOR_INACTIVE_PERM, TF_CENTERED, 0, 256 - (MENU_RIGHT_MARGIN_WIDTH + MENU_LEFT_MARGIN_WIDTH));
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
	} //end
	
	void loadMenuTempBitmap(bitmap menu) //start
	{
		menu->Rectangle(0, MENU_START_TABS_X, MenuVars[MV_TEMP_Y], MENU_BITMAP_WIDTH, MenuVars[MV_OPT_HEIGHT] * 2, C_TRANS, 1, 0, 0, 0, true, OP_OPAQUE);
		int x = MENU_START_TABS_X + MENU_RIGHT_MARGIN;
		DEFINE TOP_Y = MenuVars[MV_TEMP_Y] + MENU_TOP_MARGIN_HEIGHT + MenuVars[MV_FONT_HEIGHT];
		int y = TOP_Y;
		
		//
		// "Options"
		//
		
		DrawMenuString(opt[OPT_CORNERBUFFS] ? "   On" : "Off", menu, 1, x, y, opt[OPT_CORNERBUFFS] ? C_DGREEN : C_DRED, TF_RIGHT);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		//
		// "Controls"
		//
		
		x += MENU_SCREEN_WIDTH;
		y = TOP_Y;
		
		char32 buf0[64];
		KeyToString (opt[OPT_KEY], buf0, true, true);
		
		DrawMenuString(buf0, menu, 1, x, y, MENU_COLOR_INACTIVE_TEMP, TF_RIGHT);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		char32 buf1[64];
		KeyToString (opt[OPT_CORNERBUFFS_KEY], buf1, true, true);
		
		DrawMenuString(buf1, menu, 1, x, y, MENU_COLOR_INACTIVE_TEMP, TF_RIGHT);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		//
		// "System"
		//
		
		x += MENU_SCREEN_WIDTH;
		y = TOP_Y;
		
		char32 buf2[32];
		getFontName(buf2, opt[OPT_OPTIONS_FONT]);
		
		DrawMenuString(buf2, menu, 1, x, y, MENU_COLOR_INACTIVE_TEMP, TF_RIGHT);
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
		//reset default; no temp text
		y += MenuVars[MV_FONT_HEIGHT] * 2 + MENU_SPACING;
		
	} //end
	
	
	//start draw menu string
	void DrawMenuString(char32 str, bitmap menu, int layer, int x, int y, int color, int format)
	{
		DrawMenuString(str, menu, layer, x, y, color, format, false);
	}
	
	void DrawMenuString(char32 str, bitmap menu, int layer, int x, int y, int color, int format, bool transbg)
	{
		menu->DrawString(layer, x, y, opt[OPT_OPTIONS_FONT], color, transbg ? C_TRANSBG : C_BLACK, format, str, OP_OPAQUE);
	}
	
	void DrawMenuStrings(char32 str, bitmap menu, int layer, int x, int y, int color, int format, int verticalSpacing, int maxWidth)
	{
		DrawMenuStrings(str, menu, layer, x, y, color, format, false, verticalSpacing, maxWidth);
	}
	
	void DrawMenuStrings(char32 str, bitmap menu, int layer, int x, int y, int color, int format, bool transbg, int verticalSpacing, int maxWidth)
	{
		DrawStringsBitmap(menu, layer, x, y, opt[OPT_OPTIONS_FONT], color, transbg ? C_TRANSBG : C_BLACK, format, str, OP_OPAQUE, verticalSpacing, maxWidth);
	} //end

	//end
	
	enum KeyValidation
	{
		KV_QUIT = -1,
		KV_INVALID,
		KV_VALID
	};
	
	KeyValidation isValidKey(int key)
	{
		switch (key)
		{
			case 0:
			case KEY_ENTER:
			case KEY_ENTER_PAD:
				return KV_INVALID;
			case KEY_BACKSPACE:
			case KEY_ESC:
				return KV_QUIT;
			default:
				for(int q = 0; q < 14; ++q) 
					if(key == Input->KeyBindings[q]) return (q == CB_B ? KV_QUIT : KV_INVALID);
				return KV_VALID;
		}
	}
	
	//start tabs stuff
	MenuTab getTab(MenuState opt)
	{
		if(opt == STATE_MAIN) return TAB_INVALID;
		
		int tab = 0;
		for(;tab < TAB_END; ++tab)
		{
			if(opt < menuTabs[tab + 1]) break;
		}
		return (tab == TAB_END ? TAB_INVALID : <MenuTab>tab);
	}
	
	int getTabPos(MenuState opt)
	{
		return getTabPos(getTab(opt));
	}
	
	int getTabPos(MenuTab tab)
	{
		if(tab == TAB_INVALID) return -1;
		return MENU_START_TABS_X + (MENU_SCREEN_WIDTH * tab);
	}
	
	void getTabName(char32 buf, MenuTab tab)
	{
		switch (tab)
		{
			case TAB_OPT:
				strcat(buf, "Options");
				break;
			case TAB_CONTROL:
				strcat(buf, "Controls");
				break;
			case TAB_SYSTEM:
				strcat(buf, "System");
				break;
		}
	}
	
	MenuTab wrapOptTab(MenuTab tab)
	{
		int t = tab;
		if(t >= TAB_END) t %= TAB_END;
		while(t <= TAB_INVALID) t += TAB_END;
		return <MenuTab> t;
	}
	
	MenuState wrapOpt(MenuState opt, int tab)
	{
		if(getTab(opt) != tab)
		{
			if(opt < menuTabs[tab]) return <MenuState> (menuTabs[tab + 1] - 1);
			else if(opt > menuTabs[tab]) return menuTabs[tab];
		}
		return opt;
	} //end
	
	void resetAllOpts()
	{
		opt[OPT_KEY] = KEY_TAB;
		opt[OPT_CORNERBUFFS] = false;
		opt[OPT_CORNERBUFFS_KEY] = KEY_B;
		opt[OPT_OPTIONS_FONT] = FONT_Z3SMALL;
	}
	
} //end

int statuses[Status::NUM_STATUSES];
namespace Status //start
{
	enum Status
	{
		POISON,
		VENOM,
		NUM_STATUSES
	};
	
	enum StatusPos
	{
		SP_ABOVE_HEAD,
		SP_TOP_LEFT
	};
	
	DEFINE STATUS_HEIGHT = 8;
	DEFINE STATUS_WIDTH = 12;
	
	CONFIG STATUS_FONT = FONT_Z3SMALL;
	COLOR STATUS_TEXT_COLOR = C_WHITE;
	
	bitmap status_bmp;
	
	StatusPos statusPos = SP_ABOVE_HEAD;
	
	@Author ("KoolAidWannaBe")
	hero script HActive
	{
		void run()
		{
			statusPos = opt[OPT_CORNERBUFFS] ? SP_TOP_LEFT : SP_ABOVE_HEAD;
			clearStatuses();
			if(status_bmp && status_bmp->isAllocated())
				status_bmp->Free();
			DEFINE WIDTH = NUM_STATUSES * STATUS_WIDTH;
			DEFINE FONT_HEIGHT = Text->FontHeight(STATUS_FONT);
			DEFINE HEIGHT = STATUS_HEIGHT + FONT_HEIGHT;
			
			status_bmp = Game->CreateBitmap(WIDTH, HEIGHT);
			while(true)
			{
				if(Input->KeyPress[opt[OPT_CORNERBUFFS_KEY]]) 
				{
					opt[OPT_CORNERBUFFS] = !opt[OPT_CORNERBUFFS];
					OptMenu::reloadOptions();
				}
				status_bmp->Clear(0);
				updateStatuses();
				int activeStatuses = 0;
				int statusSeconds[NUM_STATUSES];
				for(int q = 0; q < NUM_STATUSES; ++q)
				{
					if(statuses[q] > 0)
					{
						++activeStatuses;
						statusSeconds[q] = Ceiling(statuses[q]/60);
					}
				}
				int index;
				DEFINE START_X = (NUM_STATUSES - activeStatuses) * (STATUS_WIDTH / 2);
				
				for(int q = 0; q < NUM_STATUSES; ++q)
				{
					unless(statuses[q] > 0) continue;
					status_bmp->FastTile(0, START_X + (index * STATUS_WIDTH), FONT_HEIGHT, getTile(<Status>q), 0, OP_OPAQUE);
					char32 buf[16];
					itoa(buf, statusSeconds[q]);
					status_bmp->DrawString(0, START_X + (index++ * STATUS_WIDTH) + (STATUS_WIDTH / 2), 0, STATUS_FONT, 
					                       STATUS_TEXT_COLOR, C_TRANSBG, TF_CENTERED, buf, OP_OPAQUE);
				}
				status_bmp->Blit(7, RT_SCREEN, 0, 0, WIDTH, HEIGHT, getStatusX(statusPos, WIDTH), 
				                 getStatusY(statusPos, HEIGHT), WIDTH, HEIGHT, 0, 0, 0, BITDX_NORMAL, 0, true);
				Waitframe();
			}
		}
	}
	
	void updateStatuses()
	{
		if(statuses[VENOM] > 0 && statuses[POISON] > 0) statuses[POISON] = 0;
		for(int q = 0; q < NUM_STATUSES; ++q)
		{
			if(statuses[q] > 0) 
			{
				--statuses[q];
				switch(q)
				{
					case POISON:
						unless(statuses[q] % 60)
							Hero->HP -= 4;
						break;
					case VENOM:
						unless(statuses[q] % 60)
						{
							Hero->HP -= 8;
							unless(statuses[q]) statuses[POISON] *= -1;
						}
						break;
				}
			}
		}
	}
	
	void clearStatuses()
	{
		memset(statuses, 0, NUM_STATUSES);
	}
	
	int getTile(Status s)
	{
		switch(s)
		{
			case POISON:
				return 214241;
			case VENOM:
				return 214242;
		}
		return NULL;
	}
	
	int getStatusX(StatusPos pos, int width)
	{
		switch(pos)
		{
			case SP_ABOVE_HEAD:
				return Hero->X + 8 - (width/2);
			case SP_TOP_LEFT:
				return 0;
		}
	}
	
	int getStatusY(StatusPos pos, int height)
	{
		switch(pos)
		{
			case SP_ABOVE_HEAD:
				return Hero->Y - 4 - height;
			case SP_TOP_LEFT:
				return 0;
		}
	}
	
	
	
} //end
typedef Status::Status Status;







