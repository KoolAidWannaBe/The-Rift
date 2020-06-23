//This is going to be an attmpt at a potions script


//this heals the Hero
CONFIG HP_HEAL_SCALE = HP_PER_HEART * 4; //1 heart is 16 Hp
CONFIG MP_HEAL_SCALE = MP_PER_BLOCK; //irdk 32 a block

item script RedPotion1
{
	void run()
	{
		if(!sfx)  = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 1;
	}
}

item script RedPotion2
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 2;
	}
}

item script RedPotion3
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 4;
	}
}

item script GreenPotion1
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Mp += MP_HEAL_SCALE * 1;
	}
}

item script GreenPotion2
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Mp += MP_HEAL_SCALE * 2;
	}
}

item script GreenPotion3
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Mp += MP_HEAL_SCALE * 3;
	}
}

item script BluePotion1
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 1;
		Hero->Mp += MP_HEAL_SCALE * 1;
	}
}

item script BluePotion2
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 2;
		Hero->Mp += MP_HEAL_SCALE * 2;
	}
}

item script BluePotion3
{
	void run()
	{
		if(!sfx) sfx = SFX_REFILL;
		Game->Playsound(sfx)
		Hero->Hp += HP_HEAL_SCALE * 4;
		Hero->Mp += MP_HEAL_SCALE * 3;
	}
}



//Warmth potion (+warmed), chill potion(+chilled), herbs(Heal poison), 
/*
item script WarmthPotion
{
	void run()
	{
		int clk;
		while(temperature < 0)
		{
			if(++clk == 10)
			{
				temperature += 1;
				clk = 0;
			}
		}
	}
}

item script ChillPotion
{
	void run()
	{
		while(temperature > 0)
		{
			if(ChillCount == 10)
			{
				temperature -= 1;
				ChillCount = 0;
			}
			++ChillCount
		}
	}
}

1030

*/