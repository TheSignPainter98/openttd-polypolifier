require("module.nut")
require("locations.nut")

class Welcomer extends Module
{
	welcomed_ids = null;
	companies = null;
	welcome_delay_months = null;

	constructor(companies)
	{
		::Module.constructor();
		welcomed_ids = [];
		this.companies = companies;
	}

	function Refresh()
	{
		welcome_delay_months = GetSetting(::WELCOME_DELAY);
	}

	function Save()
	{
		return welcomed_ids;
	}

	function Load(version, data)
	{
		parent.Load(version, data);
		welcomed_ids = data;
	}

	function OnQuarter(_)
	{
		GSLog.Error("Sending welcome messages");
		foreach (company in companies.GetInfoList())
			if (company.age_months > welcome_delay_months)
			{
				if (company.hq == GSMap.TILE_INVALID)
					GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.NO_HQ_REMINDER, company.id, company.id), company.id, Locs.NR_CAPITAL, Locs.CAPITAL);
				else if (!Util.In(welcomed_ids, company.id))
					GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.WELCOME_FIRST, company.id, company.id), company.id, GSNews.NR_TILE, company.hq);
				welcomed_ids.append(company.id);
			}
	}
}
