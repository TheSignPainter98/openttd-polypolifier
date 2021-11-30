require("module.nut")

class Welcomer extends Module
{
	welcomed_ids = null;
	companies = null;
	welcome_delay_months = null;

	constructor(companies)
	{
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
		{
			if (!Util.In(welcomed_ids, company.id) && company.age_months > welcome_delay_months)
				if (company.hq == GSMap.TILE_INVALID)
					GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.ANNOUNCEMENT_NO_HQ, company.id + 1), company.id, GSNews.NR_NONE, 0);
				else
					GSNews.Create(GSNews.NT_GENERAL, ANNOUNCEMENT_HQ, company.id, GSNews.NR_NONE, company.hq);
		}
	}
}
