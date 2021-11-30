require("module.nut")

class RatingMedic extends Module
{
	RATING_CHANGE_KILL_TREE = -35;
	RATING_CHANGE_PLANT_TREE = 7;
	TREE_PLANT_RATING_CAP = 220;

	tiles = null;
	tree_tiles = null;
	prev_tree_tiles = null;
	size_x = null;
	size_y = null;

	constructor()
	{
		::Module.constructor();
		size_x = GSMap.GetMapSizeX();
		size_y = GSMap.GetMapSizeY();

		tree_tiles = GSTileList();
		prev_tree_tiles = GSTileList();
	}

	function PostInit()
	{
		RefreshTileList();
	}

	function RefreshTileList()
	{
		tiles = GSTileList();
		for (local x = 0; x < size_x; x++)
			for (local y = 0; y < size_x; y++)
			{
				local t = GSMap.GetTileIndex(x, y);
				if (GSMap.IsValidTile(t) && GSTown.IsValidTown(GSTile.GetTownAuthority(t)))
					tiles.AddTile(t);
			}
	}

	function OnQuarter(_)
	{
		RefreshTileList(); // This is only required if town-founding is enabled.
	}

	function OnMonth(_)
	{
		foreach (tile in tiles)
		{
			local town = GSTile.GetTownAuthority(tile);
			local company = GSTile.GetOwner(tile);
			// Ignore un-owned tiles and those outside of authorities.
			if (!GSTown.IsValidTown(town) || company == GSCompany.COMPANY_INVALID)
				continue;
			if (GSTile.HasTreeOnTile(tile))
				tree_tiles.AddTiles(tile);
			else if (prev_tree_tiles.HasItem(tile)) // Tree has been removed
				GSTown.ChangeRating(town, company, GetRatingFix(company, town));
		}

		prev_tree_tiles = tree_tiles;
	}

	function GetRatingFix(company, town)
	{
		local rating = GSTown.GetDetailedRating(town, company);
		if (rating > TREE_PLANT_RATING_CAP)
			return -RATING_CHANGE_KILL_TREE;
		if (rating + RATING_CHANGE_PLANT_TREE <= TREE_PLANT_RATING_CAP)
			return -RATING_CHANGE_KILL_TREE + RATING_CHANGE_PLANT_TREE;
		return TREE_PLANT_RATING_CAP - rating;
	}
}
