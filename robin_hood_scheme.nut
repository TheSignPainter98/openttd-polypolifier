require("finances.nut");
require("locations.nut")
require("module.nut")
require("setting_names.nut")
require("util.nut")

// TODO: news alerts!

class RobinHoodScheme extends Module
{
	company_list = null;
	robin_hood_basic_rate = 0.10;

	constructor(companies)
	{
		::Module.constructor();
		this.company_list = companies;
	}

	function Refresh()
	{
		robin_hood_basic_rate = GetPercentageSetting(::ROBIN_HOOD_RATE);
	}

	function OnQuarter(_)
	{
		GSLog.Error("Enacting Robin Hood scheme");

		local companies = company_list.GetInfoList();
		local n_companies = companies.len();

		// Ensure at multiple players are playing
		if (n_companies < 2)
		{
			GSLog.Error("Robin hood cannot be operated at least two companies present.");
			return;
		}

		local n_taxed_companies = n_companies / 2;

		// Sort ascending value
		foreach (company in companies)
			company.rh_priority <- company.value;
		companies.sort(PriorityCompare);

		// Get the beneficiary
		local beneficiary = null;
		foreach (company in companies)
			if (company.active && company.hq != GSMap.TILE_INVALID)
			{
				beneficiary = company;
				break;
			}
		if (!beneficiary)
		{
			GSLog.Error("No valid Robin Hood beneficiaries!");
			return;
		}
		foreach (c_to_tax in cs_to_tax)
			if (beneficiary.id == c_to_tax.id)
			{
				GSLog.Error("Robin hood cannot be operated without distinct benefactors and financiers");
				return;
			}

		local cs_to_tax = companies.slice(-n_taxed_companies);
		local cs_to_tax_tot_value = 0;
		foreach (c in cs_to_tax)
			cs_to_tax_tot_value += c.value;

		local grant = Util.Min(robin_hood_basic_rate * beneficiary.value, robin_hood_basic_rate * (cs_to_tax[0].value - beneficiary.value));

		GSLog.Error("Robin Hood tax is giving £" + grant + " to " + beneficiary.name + " by taking from rich others");
		Finances.Grant(beneficiary, grant);
		foreach (c in cs_to_tax)
			Finances.Tax(c, grant * c.value / cs_to_tax_tot_value);
	}

	function ComputeGrant(beneficiary, companies)
	{
		// Assumes that companies is sorted by RH priority
		return Util.Min(
				robin_hood_basic_rate * beneficiary.value,
				robin_hood_basic_rate * (companies[companies.len() / 2].value - beneficiary.value)
				);
	}

	function PriorityCompare(a, b)
	{
		return Util.Compare(a.rh_priority, b.rh_priority);
	}
}
