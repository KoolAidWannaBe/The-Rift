
CONFIG FADE_SPEED = 4;

dmapdata script ActiveSubscreen
{
	void run() //start
	{
		untyped arr[ARR_SIZE];
		fadeOut(FADE_SPEED);
		for(int f = -63; f < 0; f += FADE_SPEED)
		{
			Graphics->ClearTint();
			Graphics->Tint(f, f, f);
			doFrame(arr, false);
			WaitTotalNoAction();
		}
		Graphics->ClearTint();
		do
		{
			doFrame(arr, true);
			Waitframe();
		}
		until(Input->Press[CB_START]);
		for(int f = 0; f > -63; f -= FADE_SPEED)
		{
			Graphics->ClearTint();
			Graphics->Tint(f, f, f);
			doFrame(arr, false);
			WaitTotalNoAction();
		}
		fadeIn(FADE_SPEED);
	} //end
	
	enum
	{
		CURSOR_INDX, PANEL,
		ARR_SIZE
	};
	
	enum
	{
		PNL_ITEMS, PNL_KEY, PNL_MAP, PNL_EQP,
		NUM_PANELS
	};
	
	void doFrame(untyped arr, bool active)
	{
		ColorScreen(7, C_BLACK, true);
		if(active)
		{
			if(Input->Press[CB_L])
			{
				--arr[PANEL];
				if(arr[PANEL] < 0)
					arr[PANEL] += NUM_PANELS;
			}
			else if(Input->Press[CB_R])
			{
				arr[PANEL] = (arr[PANEL] + 1) % NUM_PANELS;
			}
		}
		char32 namebuf[64];
		switch(arr[PANEL])
		{
			case PNL_ITEMS: //start 
			{
				break;
			} //end
			case PNL_KEY: //start 
			{
				break;
			} //end
			case PNL_MAP: //start 
			{
				break;
			} //end
			case PNL_EQP: //start 
			{
				break;
			} //end
		}
	}
}















