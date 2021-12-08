require("module.nut")

NO_CAPITAL_FOUND <- -1;

class Locations extends Module
{
	CAPITAL_NAME = "London";

	NR_CAPITAL = GSNews.NR_NONE;
	CAPITAL = NO_CAPITAL_FOUND;
	CAPITAL_IDX = NO_CAPITAL_FOUND;

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
				break;
			}
	}
}

Locs <- Locations();
