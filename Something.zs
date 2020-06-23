#option SHORT_CIRCUIT on
#option TRUE_INT_SIZE on
typedef const int	DEFINE;
typedef const int 	CONFIG;
typedef const bool 	CONFIGB;

#include "std.zh"

enum Opt
{
	OPT_KEY,
	OPT_CORNERBUFFS,
	OPT_CORNERBUFFS_KEY,
	OPT_OPTIONS_FONT,
	SZ_OPT
};
untyped opt[SZ_OPT] = {KEY_TAB, false, KEY_B, OptMenu::MENU_FONT_DEFAULT};

enum Color
{
	C_TRANSBG	= -0x01,
	C_TRANS		=  0x00,
	C_WHITE		=  0x01,
	C_BLACK		=  0x0F,
	
	C_LGRAY		=  0x01,
	C_DGRAY 	=  0x01,
	C_RED		=  0x01,
	C_DRED		=  0x01,
	C_YELLOW	=  0x01,
	C_GREEN		=  0x01,
	C_DGREEN	=  0x01,
	C_CYAN 		=  0x01,
	C_LILLAC	=  0x01
	
};
typedef const Color COLOR;

@Author ("KoolAidWannaBe")
global script Active
{
	void run()
	{
		OptMenu::init_menu_bitmap();
		while(true)
		{
			options();
			Waitframe();
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
	
	MenuState menuTabs[] = {STATE_CORNERBUFFS, STATE_OPTKEY, STATE_RESET, STATE_MAX};
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
			int numOpt = tabNumOpt(<MenuTab>q);
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
		if(force || !menu->isValid()) menu->Create(0, MENU_BITMAP_WIDTH, MenuVars[MV_BMP_HEIGHT]);
	}
	//end
	
	void options() //start
	{
		if(Input->KeyPress[opt[OPT_KEY]])
		{
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
			hidePassive(true);
			flashScreen(C_BLACK, true);
			WaitTotalNoAction();
			reloadMenuBitmap(menu);
			
			while(true)
			{
				Waitdraw();
				if(cooldown > 0) --cooldown;
				inputTimer = ++inputTimer%INPUT_DELAY;
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
							case:
								//UNFINISHED
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
					case:
					//UNFINISHED
				} //end
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
                        menu->Blit(MENU_LAYER, RT_SCREEN, MENU_START_TABS_X, scroll + MenuVars[MV_TEMPY], 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], wid, MenuVars[MV_TOP_MENU], 256 - wid, MenuVars[MV_VIS_SCREEN_HEIGHT], 0, 0, 0, 0, 0, true);
					}
					
				}
				if(MENU_ENFORCE_MARGINS)
				{
					Screen->Rectangle(MENU_LAYER, 0,                 MenuVars[MV_TOP_MENU],              256,                  MenuVars[MV_TOP_MARGIN] - 1, BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, 0,                 MenuVars[MV_TOP_MENU],              MENU_LEFT_MARGIN - 1, 176,                         BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, MENU_RIGHT_MARGIN, MenuVars[MV_TOP_MENU],              256,                  176,                         BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(MENU_LAYER, 0,                 168 - MENU_BOTTOM_MARGIN_HEIGHT,    256,                  176,                         BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
				}
				//OptMenuTab names
				char buf1[32], buf2[32], buf3[32];
				getTabName(buf1, wrapOptTab(<OptMenuTab>(tab-1)));
				getTabName(buf2, wrapOptTab(<OptMenuTab>tab));
				getTabName(buf3, wrapOptTab(<OptMenuTab>(tab+1)));
				Screen->DrawString(MENU_LAYER,  64, MenuVars[MV_TABLABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf1, OP_OPAQUE);
				Screen->DrawString(MENU_LAYER, 128, MenuVars[MV_TABLABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf2, OP_OPAQUE);
				Screen->DrawString(MENU_LAYER, 192, MenuVars[MV_TABLABEL_Y], MENU_FONT_TABS, MENU_COLOR_TABS, C_TRANSBG, TF_CENTERED, buf3, OP_OPAQUE);
				//Controls
				//UNFINISHED DrawStrings(MENU_LAYER, 128, MENU_BOTTOM_MARGIN + Text->FontHeight(MENU_FONT_TABS), MENU_FONT_TABS, MENU_COLOR_CONTROLS, C_TRANSBG, TF_CENTERED, "ENTER/(A): Confirm | BACKSPACE/(B): Back\n(START): Info | (UP)/(DOWN): Switch options\n(LEFT)/(RIGHT): Switch Tabs", OP_OPAQUE, 2, 256-(MENU_RIGHT_MARGIN_WIDTH + MENU_LEFT_MARGIN_WIDTH));
				//
				if(keyCheck(KEY_U))	menu->Write(7, "MenuBitmap.png", true);
				TotalNoAction();
				Waitframe();
			}
			TotalNoAction();
			reloadOptions();
			//UNFINISHED Screen Freezing
			hidePassive(false);
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
} //end








