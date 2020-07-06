
enum NPCID
{
	N_NONE,
	N_CRAFTER
};

CONFIG MAX_NAME_LENGTH = 75;

void getNPCName(char32 buf, NPCID index)
{
	switch(index)
	{
		case N_CRAFTER:
			strcpy(buf, "Crafter");
			break;
	}
}

ffc script NPC 
{
	void run(NPCID id, bool special) //start
	{
		unless(special) while(true)
		{
			if(AgainstPosition(this->X, this->Y + this->EffectHeight - 16) && Input->Press[CB_A])
			{
				Input->Button[CB_A] = false;
				Input->Press[CB_A] = false;
				interact(this, id);
			}
			Waitframe();
		}
		else 
		{
			switch(id)
			{
				default:
				1;
			}
			while(true)
			{
				switch(id)
				{
					default:
					1;
				}
				Waitframe();
			}
		}
	} //end
	
	void interact(ffc person, NPCID id)
	{
		interact(person, id, 0);
	}
	
	void interact(ffc person, NPCID id, int NPCSound)
	{
		interact(person, id, NPCSound, NULL);
	}
	
	void interact(ffc person, NPCID id, int NPCSound, untyped args)
	{
		using namespace Crafting;
		Audio->PlaySound(NPCSound);
		switch(id)
		{
			case N_CRAFTER:
			{
				ShowNPCStringAndWait("Hi!", id);
				untyped craftable[REC_MAX];
				bitmap b = loadRecipes(CS_ARMORSHOP, craftable);
				DEFINE NUM_OPTS = craftable[0];
				if(NUM_OPTS <= 0)
				{
					ShowNPCStringAndWait("Nothing is craftable right now.", id);
					break;
				}
				int index;
				int scroll;
				TotalNoAction();
				while(true)
				{
					if(Input->Press[CB_DOWN])
					{
						++index;
						if(index >= NUM_OPTS)
						{
							index = 0;
							scroll = 0;
						}
						if(index > scroll + 2) ++scroll;
					}
					else if(Input->Press[CB_UP])
					{
						--index;
						if(index < 0)
						{
							index = NUM_OPTS - 1;
							scroll = Max(NUM_OPTS - 3, 0);
						}
						if(index < scroll) --scroll;
					}
					Screen->Rectangle(7, 32, 23, 223, 74, C_WHITE, 1, 0, 0, 0, true, OP_OPAQUE);
					Screen->Rectangle(7, 34, 25, 221, 72, C_BLACK, 1, 0, 0, 0, true, OP_OPAQUE);
					b->Blit(7, RT_SCREEN, 0, 16 * scroll, 188, 48, 34, 25, 188, 48, 0, 0, 0, BITDX_NORMAL, 0, true);
					Screen->Rectangle(7, 34, 25 + 16 * (index - scroll), 221, 40 + 16 * (index - scroll), C_LGRAY, 1, 0, 0, 0, false, OP_OPAQUE);
					if(Input->Press[CB_A]) break;
					if(Input->Press[CB_B]) return;
					Waitframe();
				}
				int r = -1;
				for(int q = 1; q < REC_MAX; ++q)
				{
					if(craftable[q])
					{
						if(++r == index)
						{
							craft(<Recipe>q);
							char32 buf[512];
							getOutputString(buf, <Recipe>q);
							ShowNPCStringAndWait(buf, id);
							return;
						}
					}
					
				}
				break;
			}
		}
	}
}


