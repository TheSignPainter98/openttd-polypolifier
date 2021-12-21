require("module.nut")
require("util.nut")

class SupermarketFounder extends Module
{
	name_distance = null;
	run = null;
	supermarket_names = [
		"Aldi",
		"Tesco",
		"Sainsbury's",
		"Lidl",
		"Marks and Spencer",
		"Waitrose",
		"Asda",
	];

	function Refresh()
	{
		name_distance = GetSetting(::SUPERMARKET_SIGN_MIN_DISTANCE);
		run = GetSetting(::SUPERMARKET_SIGNS);
	}

	function OnYear(_)
	{
		if (!run)
			return;

		foreach (iid,_ in GSIndustryList())
		{
			// Ensure valid
			if (!GSIndustry.IsValidIndustry(iid))
				continue;

			// Ensure general store
			local name = GSIndustry.GetName(iid);
			local name_parts = Util.Words(name);
			local nname_parts = name_parts.len();
			if (nname_parts < 2 || name_parts[nname_parts - 2] != "General" || name_parts[nname_parts - 1] != "Store")
				continue;

			// Ensure reasonably far from the centre of town
			local tile = GSIndustry.GetLocation(iid);
			local distance = GSTown.GetDistanceManhattanToTile(GSTile.GetClosestTown(tile), tile)
			if (distance <= name_distance)
				continue;

			// Check no sign already present
			local sign_present = false;
			foreach (sign,_ in GSSignList())
				if (GSSign.GetLocation(sign) == tile)
				{
					sign_present = true;
					break;
				}
			if (sign_present)
				continue;

			// Make a sign
			local supermarket_name = supermarket_names[GSDate.GetYear(GSDate.GetCurrentDate()) % supermarket_names.len()];
			try
			{
				GSLog.Error("Creating '" + supermarket_name + "' sign above " + name);
				GSSign.BuildSign(tile, supermarket_name);
				break;
			}
			catch (ex)
			{
				GSLog.Error("Failed to create a '" + supermarket_name + "' sign above " + name + ": " + ex);
			}
		}
	}
}
