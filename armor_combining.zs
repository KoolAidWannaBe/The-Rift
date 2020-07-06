
//combines items if player says yes

script ItemCombiner	//idk what type of script this is
{

	void run(int checkedItem, int checkedItem2, int combinedItem, int pickupString)
	{
		if(Hero->Item[checkedItem] && Hero->Item[checkedItem2])
		{
			Hero->Item[combinedItem] = true;
			Screen->Message(pickupString);
		}
	}
}


