require("locations.nut");
require("module.nut");
require("setting_names.nut");

class PollAnnuity extends Module
{
	pot = null;
	companies = null;
	annuity = null;

	constructor(pot, companies)
	{
		::Module.constructor();
		this.pot = pot;
		this.companies = companies;
	}

	function Refresh()
	{
		annuity = GetSetting(::ANNUITY);
	}

	function OnQuarter(args)
	{
		local quarter = args[0];
		local year = args[1];

		GSLog.Error("Poll annuity checking quarter: " + quarter)
		if (quarter != 2)
			return;

		GSLog.Error("Granting Poll annuity");

		local n_active_companies = 0;
		foreach (company in companies.GetInfoList())
			if (company.active)
				n_active_companies++;

		local total_to_grant = n_active_companies * annuity;
		if (!pot.CanGrant(total_to_grant))
			return;

		foreach (company in companies.GetInfoList())
		{
			// Don't pay inactive companies
			if (!company.active)
				continue;

			// Don't pay non-resident companies
			if (company.hq == GSMap.TILE_INVALID)
			{
				GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.POLL_ANNUITY_MISSED, poll_annuity, company.id, company.id), company.id, Locs.NR_CAPITAL, Locs.CAPITAL);
				continue;
			}

			pot.Grant(company, annuity);
			GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.POLL_ANNUITIED, poll_annuity), company.id, GSNews.NR_TILE, company.hq);
		}
	}
}
