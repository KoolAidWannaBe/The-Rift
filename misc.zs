//misc functions
bool subscreenHidden()
{
	return ScreenFlag(SF_VIEW, SFV_NOSUBSCREEN);
}

enum CompType //start
{
    LESS = -1, EQ, MORE
};

CompType comp(untyped arg1, untyped arg2)
{
    return (arg1 < arg2) ? LESS : ((arg1 == arg2) ? EQ : MORE);
} //end

//start Screen Freezing
enum FreezeState
{
	FREEZE_FORCE_NONE = -1,
	FREEZE_NONE,
	FREEZE_ACTION_BUT_FFC,
	FREEZE_ACTION
};
FreezeState curFrz = FREEZE_NONE;
bool indivFreeze[susptLAST];
bool forceActive[susptLAST];
void Screen_Freeze(FreezeState frz)
{
	curFrz = frz;
	//isFrozen = frz>FREEZE_NONE;
	switch(frz)
	{
		case FREEZE_FORCE_NONE:
		{
			for(int q = 0; q < susptLAST; ++q)
			{
				Game->Suspend[q] = false;
				indivFreeze[q] = false;
				forceActive[q] = false;
			}
			curFrz = FREEZE_NONE;
			break;
		}
		case FREEZE_NONE:
		{
			for(int q = 0; q < susptLAST; ++q)
			{
				Game->Suspend[q] = indivFreeze[q] && !forceActive[q];
			}
			break;
		}
		case FREEZE_ACTION_BUT_FFC:
		{
			for(int q = 0; q < susptLAST; ++q)
			{
				switch(q)
				{
					case susptCONTROLSTATE:
					case susptGLOBALGAME:
					case susptLINKACTIVE:
					case susptUPDATEFFC:
					case susptFFCSCRIPTS:
					case susptSCREENDRAW:
					case susptSCRIPDRAWCLEAR:
					case susptONEFRAMECONDS:
					case susptCOMBOANIM:
						Game->Suspend[q] = indivFreeze[q] && !forceActive[q];
						break;
					default:
						Game->Suspend[q] = !forceActive[q];
				}
			}
			break;
		}
		case FREEZE_ACTION:
		{
			for(int q = 0; q < susptLAST; ++q)
			{
				switch(q)
				{
					case susptCONTROLSTATE:
					case susptGLOBALGAME:
					case susptLINKACTIVE:
					case susptSCREENDRAW:
					case susptSCRIPDRAWCLEAR:
					case susptONEFRAMECONDS:
						Game->Suspend[q] = indivFreeze[q] && !forceActive[q];
						break;
					default:
						Game->Suspend[q] = !forceActive[q];
				}
			}
			break;
		}
	}
}

FreezeState Get_Freeze()
{
	return curFrz;
}

void FreezeOne(int q, bool frz)
{
	indivFreeze[q] = frz;
	Screen_Freeze(Get_Freeze()); //Refresh the freeze state
}

bool getFreezeOne(int q) {return indivFreeze[q];}

void ForceUnfreeze(int q, bool unfrz)
{
	forceActive[q] = unfrz;
	Screen_Freeze(Get_Freeze()); //Refresh the freeze state
}

bool getForceUnfreeze(int q) {return forceActive[q];}

//end

void TotalNoAction()//start
{
	for(int q = 0; q < CB_MAX; ++q)
	{
		Input->Button[q] = false;
		Input->Press[q] = false;
	}
}//end
void WaitTotalNoAction()//start
{
	WaitTotalNoAction(1);
}//end
void WaitTotalNoAction(int frames)//start
{
	for(int j = 0; j < frames; ++j)
	{
		TotalNoAction();
		Waitframe();
	}
}//end


void getFontName(char32 buf, int font) //start
{
	switch(font)
	{
		case FONT_Z1:
			strcpy(buf, "Zelda NES");
			break;
			
		case FONT_Z3:
			strcpy(buf, "Link to the Past");
			break;
			
		case FONT_Z3SMALL:
			strcpy(buf, "LttP Small");
			break;
			
		case FONT_DEF:
			strcpy(buf, "Allegro Default");
			break;
			
		case FONT_L:
			strcpy(buf, "GUI Font Bold");
			break;
			
		case FONT_L2:
			strcpy(buf, "GUI Font");
			break;
			
		case FONT_P:
			strcpy(buf, "GUI Font Narrow");
			break;
			
		case FONT_MATRIX:
			strcpy(buf, "Zelda NES (Matrix)");
			break;
			
		case FONT_ZTIME:
			strcpy(buf, "BS Time (Incomplete)");
			break;
			
		case FONT_S:
			strcpy(buf, "Small");
			break;
			
		case FONT_S2:
			strcpy(buf, "Small 2");
			break;
			
		case FONT_SP:
			strcpy(buf, "S. Proportional");
			break;
			
		case FONT_SUBSCREEN1:
			strcpy(buf, "SS 1 (Numerals)");
			break;
			
		case FONT_SUBSCREEN2:
			strcpy(buf, "SS 2 (Incomplete)");
			break;
			
		case FONT_SUBSCREEN3:
			strcpy(buf, "SS 3");
			break;
			
		case FONT_SUBSCREEN4:
			strcpy(buf, "SS 4 (Numerals)");
			break;
			
		case FONT_LA:
			strcpy(buf, "Link's Awakening");
			break;
			
		case FONT_GORON:
			strcpy(buf, "Goron");
			break;
			
		case FONT_ZORAN:
			strcpy(buf, "Zoran");
			break;
			
		case FONT_HYLIAN1:
			strcpy(buf, "Hylian 1");
			break;
			
		case FONT_HYLIAN2:
			strcpy(buf, "Hylian 2");
			break;
			
		case FONT_HYLIAN3:
			strcpy(buf, "Hylian 3");
			break;
			
		case FONT_HYLIAN4:
			strcpy(buf, "Hylian 4");
			break;
			
		case FONT_GBORACLE:
			strcpy(buf, "Oracle");
			break;
			
		case FONT_GBORACLEP:
			strcpy(buf, "Oracle Proportional");
			break;
			
		case FONT_DSPHANTOM:
			strcpy(buf, "Phantom");
			break;
			
		case FONT_DSPHANTOMP:
			strcpy(buf, "Phantom Proportional");
			break;
			
		case FONT_ATARI800:
			strcpy(buf, "Atari 800");
			break;
			
		case FONT_ACORN:
			strcpy(buf, "Acorn");
			break;
			
		case FONT_ADOS:
			strcpy(buf, "ADOS");
			break;
			
		case FONT_ALLEGRO:
			strcpy(buf, "Allegro");
			break;
			
		case FONT_APPLE2:
			strcpy(buf, "Apple II");
			break;
			
		case FONT_APPLE2_80COL:
			strcpy(buf, "Apple II 80 Column");
			break;
			
		case FONT_APPLE2GS:
			strcpy(buf, "Apple IIgs");
			break;
			
		case FONT_AQUARIUS:
			strcpy(buf, "Aquarius");
			break;
			
		case FONT_ATARI400:
			strcpy(buf, "Atari 400");
			break;
			
		case FONT_C64:
			strcpy(buf, "C64");
			break;
			
		case FONT_C64_HIRES:
			strcpy(buf, "C64 HiRes");
			break;
			
		case FONT_CGA:
			strcpy(buf, "IBM CGA");
			break;
			
		case FONT_COCO:
			strcpy(buf, "COCO Mode I");
			break;
			
		case FONT_COCO2:
			strcpy(buf, "COCO Mode II");
			break;
			
		case FONT_COUPE:
			strcpy(buf, "Coupe");
			break;
			
		case FONT_CPC:
			strcpy(buf, "Amstrad CPC");
			break;
			
		case FONT_FANTASY:
			strcpy(buf, "Fantasy Letters");
			break;
			
		case FONT_FDS_KANA:
			strcpy(buf, "FDS Katakana");
			break;
			
		case FONT_FDSLIKE:
			strcpy(buf, "FDSesque");
			break;
			
		case FONT_FDS_ROMAN:
			strcpy(buf, "FDS Roman");
			break;
			
		case FONT_FF:
			strcpy(buf, "FF");
			break;
			
		case FONT_FUTHARK:
			strcpy(buf, "Elder Futhark");
			break;
			
		case FONT_GAIA:
			strcpy(buf, "Gaia");
			break;
			
		case FONT_HIRA:
			strcpy(buf, "Hira");
			break;
			
		case FONT_JP:
			strcpy(buf, "JP Unsorted");
			break;
			
		case FONT_KONG:
			strcpy(buf, "Kong");
			break;
			
		case FONT_MANA:
			strcpy(buf, "Mana");
			break;
			
		case FONT_MARIOLAND:
			strcpy(buf, "Mario");
			break;
			
		case FONT_MOT:
			strcpy(buf, "Mot CPU");
			break;
			
		case FONT_MSX0:
			strcpy(buf, "MSX Mode 0");
			break;
			
		case FONT_MSX1:
			strcpy(buf, "MSX Mode 1");
			break;
			
		case FONT_PET:
			strcpy(buf, "PET");
			break;
			
		case FONT_PSTART:
			strcpy(buf, "Homebrew");
			break;
			
		case FONT_SATURN:
			strcpy(buf, "Mr. Saturn");
			break;
			
		case FONT_SCIFI:
			strcpy(buf, "Sci-Fi");
			break;
			
		case FONT_SHERWOOD:
			strcpy(buf, "Sherwood");
			break;
			
		case FONT_SINQL:
			strcpy(buf, "Sinclair QL");
			break;
			
		case FONT_SPECTRUM:
			strcpy(buf, "Spectrum");
			break;
			
		case FONT_SPECTRUM_LG:
			strcpy(buf, "Spectrum Large");
			break;
			
		case FONT_TI99:
			strcpy(buf, "TI99");
			break;
			
		case FONT_TRS:
			strcpy(buf, "TRS");
			break;
			
		case FONT_Z2:
			strcpy(buf, "Zelda 2");
			break;
			
		case FONT_LISA:
			strcpy(buf, "Lisa");
			break;
	}
} //end

void flashScreen(Color color, bool subscreen) //start
{
	Screen->Rectangle(7, 0, subscreen?-56:0, 256, 176, color, 1, 0, 0, 0, true, OP_OPAQUE);
}//end
void flashScreenTrans(Color color, bool subscreen) //start
{
	Screen->Rectangle(7, 0, subscreen?-56:0, 256, 176, color, 1, 0, 0, 0, true, OP_TRANS);
}//end


bool AgainstPosition(int x, int y) //start
{
	return AgainstPosition(x, y, Hero->BigHitbox, true);
} //end
bool AgainstPosition(int x, int y, bool largeHitbox, bool anySide) //start
{
	if(largeHitbox && !anySide)
	{
		return Hero->Z == 0 && (Hero->Dir == DIR_UP && Hero->Y == y+16 && Abs(Hero->X - x) < 8);
	}
	else unless(largeHitbox || anySide)
	{
		return Hero->Z == 0 && (Hero->Dir == DIR_UP && Hero->Y == y+8 && Abs(Hero->X - x) < 8);
	}
	else if (largeHitbox && anySide)
	{
		return Hero->Z == 0 && ((Hero->Dir == DIR_UP && Hero->Y == y+16 && Abs(Hero->X - x) < 8)||(Hero->Dir == DIR_DOWN && Hero->Y == y-16 && Abs(Hero->X-x) < 8)||(Hero->Dir == DIR_LEFT && Hero->X == x+16 && Abs(Hero->Y-y) < 8)||(Hero->Dir == DIR_RIGHT && Hero->X == x-16 && Abs(Hero->Y-y) < 8));
	}
	else if (!largeHitbox && anySide)
	{
		return Hero->Z == 0 && ((Hero->Dir == DIR_UP && Hero->Y == y+8 && Abs(Hero->X - x) < 8)||(Hero->Dir == DIR_DOWN && Hero->Y == y-16 && Abs(Hero->X-x) < 8)||(Hero->Dir == DIR_LEFT && Hero->X == x+16 && Abs(Hero->Y-y) < 8)||(Hero->Dir == DIR_RIGHT && Hero->X == x-16 && Abs(Hero->Y-y) < 8));
	}
	return false;
} //end
int fullCounter(int counter) //start //Use this to make sure draining rupees are not counted when determining if you have enough money.
{
	return Game->Counter[counter]+Game->DCounter[counter];
} //end
	
//start Keyboard
void KeyToString(int key, char32 buf)
{
	KeyToString(key, buf, false);
}

void KeyToString(int key, char32 buf, bool ShowPad)
{
	KeyToString(key, buf, ShowPad, false);
}

void KeyToString(int key, char32 buf, bool ShowPad, bool AllCaps)
{
	switch(key)
	{
		case KEY_TAB:
			strcat(buf, "Tab");
			break;
		
		case KEY_BACKSPACE:
			strcat(buf, "Back");
			break;
			
		case KEY_ENTER:
		case KEY_ENTER_PAD:
			strcat(buf, "Enter");
			if(ShowPad && key == KEY_ENTER_PAD) strcat(buf, " (Pad)");
			break;
			
		case KEY_SPACE:
			strcat(buf, "Space");
			break;
			
		case KEY_DEL:
		case KEY_DEL_PAD:
			strcat(buf, "Del");
			if(ShowPad && key == KEY_DEL_PAD) strcat(buf, " (Pad)");
			break;
			
		case KEY_HOME:
			strcat(buf, "Home");
			break;
			
		case KEY_END:
			strcat(buf, "End");
			break;
			
		case KEY_PGUP:
			strcat(buf, "PgUp");
			break;
			
		case KEY_PGDN:
			strcat(buf, "PgDn");
			break;
			
		case KEY_UP:
			strcat(buf, "Up");
			break;
			
		case KEY_DOWN:
			strcat(buf, "Down");
			break;
			
		case KEY_LEFT:
			strcat(buf, "Left");
			break;
			
		case KEY_RIGHT:
			strcat(buf, "Right");
			break;
		
		case KEY_PRTSCR:
			strcat(buf, "PrintScr");
			break;
			
		case KEY_PAUSE:
			strcat(buf, "Pause");
			break;
		
		case KEY_ESC:
			strcat(buf, "Esc");
			break;
			
		case KEY_F1:
		case KEY_F2:
		case KEY_F3:
		case KEY_F4:
		case KEY_F5:
		case KEY_F6:
		case KEY_F7:
		case KEY_F8:
		case KEY_F9:
			strcat(buf, {'F', key - KEY_F1 + '1', 0});
			break;
			
		case KEY_F10:
		case KEY_F11:
		case KEY_F12:
			strcat(buf, {'F', '1', key - KEY_F10 + '0', 0});
			break;
			
		case KEY_LCONTROL:
			strcat(buf, "LCtrl");
			break;
			
		case KEY_RCONTROL:
			strcat(buf, "RCtrl");
			break;
			
		case KEY_LSHIFT:
			strcat(buf, "LShift");
			break;
			
		case KEY_RSHIFT:
			strcat(buf, "RShift");
			break;
			
		case KEY_ALT:
			strcat(buf, "LAlt");
			break;
			
		case KEY_ALTGR:
			strcat(buf, "RAlt");
			break;
			
		case KEY_LWIN:
			strcat(buf, "LWin");
			break;
			
		case KEY_RWIN:
			strcat(buf, "RWin");
			break;
			
		case KEY_MENU:
			strcat(buf, "Menu");
			break;
			
		case KEY_SCRLOCK:
			strcat(buf, "ScrLock");
			break;
		
		case KEY_NUMLOCK:
			strcat(buf, "NumLock");
			break;
		
		case KEY_CAPSLOCK:
			strcat(buf, "CapsLock");
			break;
			
		case KEY_COMMAND:
			strcat(buf, "Cmd");
			break;
			
		default:
			char32 keyChar = KeyToChar(key, false, false);
			strcat(buf, <char32[2]>{AllCaps ? LowerToUpper(keyChar) : keyChar});
			if(ShowPad)
			{
				switch(key)
				{
					case KEY_SLASH_PAD:
					case KEY_MINUS_PAD:
					case KEY_PLUS_PAD:
					case KEY_ASTERISK:
					case KEY_EQUALS_PAD:
					case KEY_0_PAD:
					case KEY_1_PAD:
					case KEY_2_PAD:
					case KEY_3_PAD:
					case KEY_4_PAD:
					case KEY_5_PAD:
					case KEY_6_PAD:
					case KEY_7_PAD:
					case KEY_8_PAD:
					case KEY_9_PAD:
						strcat(buf, " (Pad)");
				}
			}
	}
}

DEFINE KEY_FINAL = 127;

int getKeyPress()
{
	for(int key = 0; key < KEY_FINAL; ++key)
	{
		if(Input->KeyPress[key]) return key;
	}
	return 0;
}
//end


