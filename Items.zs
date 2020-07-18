//~~~~~LifeRing~~~~~//
//D0: HP to heal while enemies on screen
//D1: How often to heal while enemies on screen
//D2: HP to heal while no enemies on screen
//D3: How often to heal while no enemies on screen
//start

itemdata script LifeRing
{
    void run(int hpActive, int timerActive, int hpIdle, int timerIdle)
    {
        int clk;
        while(true)
        {
			while(Hero->Action == LA_SCROLLING) 
				Waitframe();
            if(EnemiesAlive())
            {
                clk = (clk + 1) % timerActive;
                unless(clk) 
					Hero->HP += hpActive;
            }
            else
            {
                clk = (clk + 1) % timerIdle;
                unless(clk) 
					Hero->HP += hpIdle;
            }
            Waitframe();
        }
    }
}
//end














