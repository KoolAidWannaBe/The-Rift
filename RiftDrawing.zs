ffc script LightAura
{
	void run(int radiusStart, int growFactor, int speed, int color)
	{
		int radius = radiusStart;
		int speedCount;
		while(true)
		{
			if(speedCount >= speed)
			{
				radius = radiusStart + Rand(growFactor);
				speedCount = 0;
			}
			Screen->Circle(6, this->X + 8, this->Y + 8, radius, color, 1, 0, 0, 0, true, OP_TRANS);
			++speedCount;
			Waitframe();
		}
	}
}
