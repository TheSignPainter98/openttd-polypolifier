require("locations.nut");
require("module.nut");
require("setting_names.nut");
require("finances.nut");

class PollAnnuity extends Module
{
	pot = null;
	companies = null;

	// Setting values
	baseline = null;
	low_threshold = null;
	med_threshold = null;
	high_threshold = null;
	low_grant = null;
	med_grant = null;
	high_grant = null;
	max_grant = null;

	constructor(pot, companies)
	{
		::Module.constructor();
		this.pot = pot;
		this.companies = companies;
	}

	function Refresh()
	{
		baseline = GetSetting(::ANNUITY_BASELINE);
		low_threshold = GetSetting(::ANNUITY_LOW_THRESHOLD);
		med_threshold = GetSetting(::ANNUITY_MED_THRESHOLD);
		high_threshold = GetSetting(::ANNUITY_HIGH_THRESHOLD);
		low_grant = GetSetting(::ANNUITY_LOW_GRANT);
		med_grant = GetSetting(::ANNUITY_MED_GRANT);
		high_grant = GetSetting(::ANNUITY_HIGH_GRANT);
		max_grant = GetSetting(::ANNUITY_MAX_GRANT);
	}

	function OnQuarter(args)
	{
		local quarter = args[0];
		local year = args[1];

		GSLog.Error("Poll annuity checking quarter: " + quarter);
		if (quarter != 2)
			return;

		GrantPollAnnuity();
	}

	function GrantPollAnnuity()
	{
		GSLog.Error("Executing poll annuity");
		local company_infos = companies.GetInfoList();

		// Get annuity weights
		local tot_grant_max = 0;
		foreach (company in company_infos)
		{
			if (!company.active || company.hq == GSMap.TILE_INVALID)
			{
				GSLog.Error("Company " + company.name + " ineligible for poll annuity: active? " + company.active + " hq? " + company.hq != GSMap.TILE_INVALID);
				continue;
			}
			company.poll_annuity_max_payout <- GetMaxPayout(company);
			tot_grant_max += company.poll_annuity_max_payout;
		}

		// Payout annuities
		foreach (company in company_infos)
		{
			if (!company.active || company.hq == GSMap.TILE_INVALID)
				continue;
			Finances.Grant(company, baseline + Util.Min(company.poll_annuity_max_payout, pot.GetContents() * company.poll_annuity_max_payout / tot_grant_max));
		}

		// Government takes any leftovers for itself.
		pot.ZeroContents();
	}

	function GetMaxPayout(company)
	{
		local v = company.value;
		if (v <= low_threshold) // 100000)
			return low_grant; // 20000;
		if (v <= med_threshold) // 200000)
			return med_grant; // 30000;
		if (v <= high_threshold) // 400000)
			return high_grant; // 45000;
		return max_grant; // 65000;
	}
}
