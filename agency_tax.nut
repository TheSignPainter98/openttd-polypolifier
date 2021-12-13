require("company_list.nut")
require("finances.nut")
require("module.nut")
require("pot.nut")

class AgencyTax extends Module
{
	pot = null;
	companies = null;
	tax_min = null;
	tax_max = null;

	constructor(pot, companies)
	{
		::Module.constructor();
		this.pot = pot;
		this.companies = companies;
	}

	function Refresh()
	{
		tax_min = GetPercentageSetting(::AGENCY_TAX_RATE_MIN);
		tax_max = GetPercentageSetting(::AGENCY_TAX_RATE_MAX);
	}

	function OnQuarter(args)
	{
		local quarter = args[0];
		if (quarter == 2)
			return;

		GSLog.Error("Enacting agency tax");

		local tot_value = 0;
		local company_list = companies.GetInfoList();
		foreach (company in company_list)
		{
			if (!company.active)
				continue;
			tot_value += company.value;
		}
		foreach (company in company_list)
		{
			if (!company.active)
				continue;
			local levy = Util.Max(0, (tax_min + (tax_max - tax_min) * company.value / tot_value) * company.earnings);
			pot.Add(levy);
			Finances.Tax(company, levy);
		}
	}
}
