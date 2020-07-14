

DEFINE TAU = 360;

ffc script CircularMotion
{
    void run(int radius, int speed, int angle, int radius2, int angle2)
    {
        if(radius2 == 0) radius2 = radius; //Circle
        if(angle < 0) angle = Rand(360); //Random Start
        int cx = this->X;
        int cy = this->Y;
        while(true)
        {
            angle += speed;
            if(angle < -360)angle+=360; //Wrap if below -360.
            else if(angle > 360)angle-=360; //Wrap if above 360.
            if(angle2==0)
            {
                this->X = cx + radius*Cos(angle);
                this->Y = cy + radius2*Sin(angle);
            }
            else //Rotate at center.
            {
                this->X = cx + radius*Cos(angle) *Cos(angle2) - radius2*Sin(angle)*Sin(angle2);
                this->Y = cy + radius2*Sin(angle)*Cos(angle2) + radius*Cos(angle)*Sin(angle2);
            }
            Waitframe();
        }
    }
}

ffc script CircMove
{
	void run(int a, int v, int theta)
	{
		int x = this->X;
		int y = this->Y;
		if(theta < 0) theta = Rand(180);
		while(true)
		{
			theta += v;
			WrapDegrees(theta);
			this->X = x + a * Cos(theta);
			this->Y = y + a * Sin(theta);
			Waitframe();
		}
	}
}

ffc script OvMove
{
	void run(int a, int b, int v, int theta, int phi)
	{
		int x = this->X;
		int y = this->Y;
		if(theta < 0) theta = Rand(180);
		while(true)
		{
			theta += v;
			WrapDegrees(theta);
			this->X = x + a * Cos(theta) * Cos(phi) - b * Sin(theta) * Sin(phi);
			this->Y = y + b * Sin(theta) * Cos(phi) + a * Cos(theta) * Sin(phi);
			Waitframe();
		}
	}
}

ffc script CircOvMove
{
	void run(int a, int b, int v, int theta, int phi) 
	{
		int x = this->X;
		int y = this->Y;
		if(b == 0) b = a;
		if (theta < 0) theta = Rand(180);
		while(true)
		{
			theta += v;
			WrapDegrees(theta);
			this->X = (phi == 0) ? x + a * Cos(theta) : x + a * Cos(theta) * Cos(phi) - b * Sin(theta) * Sin(phi);
			this->Y = (phi == 0) ? y + b * Sin(theta) : y + b * Sin(theta) * Cos(phi) + a * Cos(theta) * Sin(phi);
			Waitframe();
		}
	}
}




//a and b as radii on the x and y axis respectivly.
//Theta (th) is the starting position of the ffc in degrees
//v is the speed of rotation
//phi(ph) is the angle of rotation of the oval.






