
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
	void run(int count, int arc, int type, int cooldown)
	{
		//if(LoadLWeaponOf(type)) return;
		int angle = WrapDegrees(DirAngle(Hero->Dir) - (arc * (count - 1)) / 2);
		for(int q = 0; q < count; ++q)
		{
			lweapon weap = Screen->CreateLWeapon(type);
			weap->X = Hero->X;
			weap->Y = Hero->Y;
			weap->Z = Hero->Z;
			weap->Angular = true;
			weap->Angle = DegtoRad(angle);
			weap->UseSprite(this->Sprites[0]);
			weap->Weapon = this->Weapon;
			weap->Defense = this->Defense;
			weap->Script = this->WeaponScript;
			weap->Rotation = WrapDegrees(angle + 90);
			angle = WrapDegrees(angle + arc);
		}
		Waitframes(cooldown);
	}
}











