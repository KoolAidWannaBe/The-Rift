
lweapon script SineWave
{
	void run(int amp, int freq)
	{
		this->Angle = DirRad(this->Dir);
		this->Angular = true;
		int x = this->X, y = this->Y;
		int clk;
		int dist;
		while(true)
		{
			clk += freq;
			clk %= 360;
			
			x += RadianCos(this->Angle) * this->Step * .01;
			y += RadianSin(this->Angle) * this->Step * .01;
			
			dist = Sin(clk) * amp;
			
			this->X = x + VectorX(dist, RadtoDeg(this->Angle) - 90);
			this->Y = y + VectorY(dist, RadtoDeg(this->Angle) - 90);
			Waitframe();
		}
	}
}


itemdata script MultiShot
{
	void run(int count, int arc, int type, int cooldown, int step)
	{
		fireMultiShot(this, count, arc, type, Hero->X, Hero->Y, Hero->Z, WrapDegrees(DirAngle(Hero->Dir) - (arc * (count - 1)) / 2), step);
		Waitframes(cooldown);
	}
}

itemdata script TotemSummon
{
	void run(int totemMax, int offset, int count, int arc, int type, int lifeTime, int firerate, int step)
	{
		int index;
		int totemScript = Game->GetLWeaponScript("Totem");
		
		for(int q = Screen->NumLWeapons(); q > 0; --q)
		{
			lweapon weap = Screen->LoadLWeapon(q);
			unless(weap->Script == totemScript) continue;
			unless(weap->InitD[0] == this) continue;
			if(++index >= totemMax) 
				weap->DeadState = WDS_DEAD;
		}
		lweapon totem = Screen->CreateLWeapon(LW_SCRIPT10);
		totem->UseSprite(this->Sprites[2]);
		totem->CollDetection = false;
		totem->X = Hero->X;
		totem->Y = Hero->Y;
		totem->Z = Hero->Z;
		totem->MoveFlags[0] = true;
		totem->MoveFlags[1] = true;
		totem->Angular = true;
		totem->Angle = DegtoRad(DirAngle(Hero->Dir) + offset);
		totem->Script = totemScript;
		totem->InitD[0] = this;
		totem->InitD[1] = count;
		totem->InitD[2] = arc;
		totem->InitD[3] = type;
		totem->InitD[4] = lifeTime;
		totem->InitD[5] = firerate;
		totem->InitD[6] = step;
	}
}

lweapon script Totem
{
	void run(itemdata parent, int count, int arc, int type, int lifeTime, int firerate, int step)
	{
		firerate = Floor(firerate ? firerate * 60 : 60);
		lifeTime *= 60;
		int clk;
		until(this->DeadState == WDS_DEAD)
		{
			unless(++clk % firerate)
			{
				fireMultiShot(parent, count, arc, type, this->X, this->Y, this->Z, RadtoDeg(this->Angle), step);
			}
			Waitframe();
			unless(--lifeTime > 0) 
				this->DeadState = WDS_DEAD;
			if(this->Falling) return;
		}
		unless(parent->Sprites[1]) return;
		lweapon spr = Screen->CreateLWeapon(LW_SPARKLE);
		spr->X = this->X;
		spr->Y = this->Y;
		spr->Z = this->Z;
		spr->UseSprite(parent->Sprites[1]);
	}
}
 
void fireMultiShot(itemdata parent, int count, int arc, int type, int x, int y, int z, int angle, int step)
{
	for(int q = 0; q < count; ++q)
	{
		lweapon weap = Screen->CreateLWeapon(type);
		weap->X = x;
		weap->Y = y;
		weap->Z = z;
		weap->Angular = true;
		weap->Angle = DegtoRad(angle);
		if(parent)
		{
			weap->Damage = parent->Power * 2;
			weap->UseSprite(parent->Sprites[0]);
			weap->Weapon = parent->Weapon;
			weap->Defense = parent->Defense;
			weap->Script = parent->WeaponScript;
			for(int j = 0; j < 8; ++j)
			{
				weap->InitD[j] = parent->WeaponInitD[j];
			}
		}
		weap->Rotation = WrapDegrees(angle + 90);
		weap->Step = step;
		angle = WrapDegrees(angle + arc);
	}
}






