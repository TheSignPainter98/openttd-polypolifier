require("module.nut")
require("company_list.nut")
require("pot.nut")

class AgencyTax extends Module
{
	pot = null;
	companies = null;
	profit_tax_threshold = 50000;
	profit_tax_rate = 0.01;
	overdraft_proportion = 0.20;

	constructor(pot, companies)
	{
		::Module.constructor();
		this.pot = pot;
		this.companies = companies;
	}

	function Refresh()
	{
		profit_tax_threshold = GetSetting(::AGENCY_TAX_THRESHOLD);
		profit_tax_rate = GetPercentageSetting(::AGENCY_TAX_RATE);
		overdraft_proportion = GetPercentageSetting(::AGENCY_TAX_OVERDRAFT_RATE);
	}

	function OnQuarter(_)
	{
		foreach (company in companies.GetInfoList())
		{
			if (!company.active)
				continue;

			local profit_over_threshold = company.profit - profit_tax_threshold;
			if (profit_tax_threshold > 0)
				pot.Tax(company, profit_tax_rate * profit_over_threshold);
		}

		if (pot.IsInOverdraft())
		{
			// Compute market value
			local total_value = 0;
			foreach (company in companies.GetInfoList())
				if (company.active)
					total_value += company.value;

			local total_levy = overdraft_proportion * pot.GetOverdraft();
			foreach (company in companies.GetInfoList())
			{
				if (!company.active)
					continue;

				local levy = total_levy * company.value / total_value;
				GSLog.Error("Agency overdraft taxing " + company.name + " £" + levy);
				pot.MeansTestedTax(company, levy);
			}
		}
	}
}
