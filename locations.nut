require("module.nut")

NO_CAPITAL_FOUND <- -1;

class Locations extends Module
{
	CAPITAL_NAME = "London";
	LARGE_CITY_NAME = "Béal Feirste";

	NR_CAPITAL = GSNews.NR_NONE;
	CAPITAL = NO_CAPITAL_FOUND;
	CAPITAL_IDX = NO_CAPITAL_FOUND;
	LARGE_CITY = 0;

	function PostInit()
	{
		Refresh();
	}

	function Refresh()
	{
		foreach (town,_ in GSTownList())
			if (GSTown.GetName(town) == CAPITAL_NAME)
			{
				NR_CAPITAL = GSNews.NR_TOWN;
				CAPITAL_IDX = town;
				CAPITAL = GSTown.GetLocation(town);
			}
			else if (GSTown.GetName(town) == LARGE_CITY_NAME)
			{
				LARGE_CITY = town;
			}
	}
}

Locs <- Locations();
