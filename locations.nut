require("module.nut")

class Locations extends Module
{
	CAPITAL_NAME = "London";

	NR_CAPITAL = GSNews.NR_NONE;
	CAPITAL = -1;

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
				CAPITAL = town;
				break;
			}
	}
}

Locs <- Locations();
