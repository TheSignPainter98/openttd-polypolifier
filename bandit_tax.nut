require("module.nut")
require("util.nut")

class BanditTax extends Module
{
	bandit_tax_rate = null;
	bandit_tax_min = null;
	pot = null;
	companies = null;

	constructor(pot, companies)
	{
		::Module.constructor();
		this.pot = pot;
		this.companies = companies;
	}

	function Refresh()
	{
		bandit_tax_rate = GetPercentageSetting(::BANDIT_TAX_RATE);
		bandit_tax_min = GetPercentageSetting(::BANDIT_TAX_MIN);
	}

	function OnQuarter(_)
	{
		GSLog.Error("Issuing bandit tax");
		foreach (company in companies.GetInfoList())
			if (company.active && company.hq == GSMap.TILE_INVALID)
				Rob(company);
	}

	function Rob(company)
	{
		pot.Tax(company, Util.Max(bandit_tax_rate * company.value, bandit_tax_min))
	}
}
