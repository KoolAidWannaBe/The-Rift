
enum NPCID
{
	N_NONE,
	N_CRAFTER,
	N_TRACKGUY 
};

CONFIG MAX_NAME_LENGTH = 75;

void getNPCName(char32 buf, NPCID index)
{
	switch(index)
	{
		case N_CRAFTER:
			strcpy(buf, "Crafter");
			break;
		case N_TRACKGUY:
			strcpy(buf, "Craig");
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
	
	//start interact
	void interact(ffc person, NPCID id) //start
	{
		interact(person, id, 0);
	} //end
	void interact(ffc person, NPCID id, int NPCSound) //start
	{
		interact(person, id, NPCSound, NULL);
	} //end
	void interact(ffc person, NPCID id, int NPCSound, untyped args) //start
	{
		using namespace Crafting;
		Audio->PlaySound(NPCSound);
		switch(id) //start
		{
			case N_CRAFTER: //start
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
			} //end
			
			case N_TRACKGUY: //start
			{
				tangoTemp = false;
				tangoTempI = 0;
				if(true || getBit(G[GV_FLAGS1], GF_TRACK_CLEARED))
				{
					//@26<<@choice(1)Yes@choice(2)No>>@domenu(1)@if(@equal(@chosen 1) @set(@ttemp 1))@close()
					ShowNPCStringAndWait("Thanks again for helping clear out those baddies. Wanna shoot some targets, or get passage through?"
					                     "@26<<@choice(1)Game@choice(2)Passage@choice(3)Neither>>@domenu(1)@set(@ttempi @chosen)@close()", id);
					switch(tangoTempI)
					{
						case 2:
							return;
						case 1:
							break;
						default:
							return;
					}
					ShowNPCStringAndWait("Hit the targets to get points; Hit all of them to get a special prize!@pressa()@26"
					                     "The price is ((20 rupees)).@26Wanna play?"
					                     "@26<<@choice(1)Yes@choice(2)No>>@domenu(1)@if(@equal(@chosen 1) @set(@ttemp 1))@close()", id);
					unless(tangoTemp) return;
					if(fullCounter(CR_RUPEES) < 20) 
					{
						ShowNPCStringAndWait("Looks like you don't have the cash. Come back when you've got more!", id);
						return;
					}
					Game->DCounter[CR_RUPEES] -= 20;
					person->Flags[FFCF_CARRYOVER] = true;
					ffc cart = Screen->LoadFFC(2);
					cart->Flags[FFCF_LENSVIS] = true;
					int score = MinecartGame::mineCartGame(person, 29358, 2, 1, 8, 8); //play the game
					person->Flags[FFCF_CARRYOVER] = false;
					Waitframe();
					switch(score)
					{
						case 15...24:
							ShowNPCStringAndWait("Pretty Good! Here's a reward.", id);
							itemsprite it = Screen->CreateItem(I_RUPEE20);
							it->X = Hero->X;
							it->Y = Hero->Y;
							it->Pickup = IP_HOLDUP;
							break;
						case 25...36:
							ShowNPCStringAndWait("Nice job! Hope this reward is worth it!", id);
							itemsprite it = Screen->CreateItem(I_RUPEE50);
							it->X = Hero->X;
							it->Y = Hero->Y;
							it->Pickup = IP_HOLDUP;
							break;
						case 37: //100% of targets
							ShowNPCStringAndWait("Wow Impressive, you got them all! Here's a reward!", id);
							int prize = getBit(G[GV_FLAGS1], GF_TRACK_HEARTPIECE) ? I_RUPEE100 : I_HCPIECE;
							G[GV_FLAGS1] = setBit(G[GV_FLAGS1], GF_TRACK_HEARTPIECE);
							itemsprite it = Screen->CreateItem(prize);
							it->X = Hero->X;
							it->Y = Hero->Y;
							it->Pickup = IP_HOLDUP;
							break;
						default:
							ShowNPCStringAndWait("Oh... well atleast you tried... Better luck next time!", id);
							break;
					}
					return;
				}	
				else
				{
					// minigame unavailable, passage unavailable, challenge.
					ShowNPCStringAndWait("", id);
				}
			} //end
		} //end
	} //end
	//end interacts
}


