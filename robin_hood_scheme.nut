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

	/* function OnQuarter(args) */
	/* { */
	/*	GSLog.Error("Executing Robin Hood scheme"); */
	/*	local quarter = args[0]; */

	/*	local companies = company_list.GetInfoList(); */

	/*	local n_companies = companies.len(); */
	/*	if (n_companies < 2) */
	/*	{ */
	/*		GSLog.Error("Robin hood cannot be operated without distinct benefactors and financiers"); */
	/*		return; */
	/*	} */

	/*	local n_taxed_companies = n_companies / 2; */
	/*	local n_irrelevant_companies = n_companies - n_taxed_companies; */

	/*	foreach (company in companies) */
	/*		company.rh_priority <- Priority(company); */
	/*	companies.sort(PriorityCompare); */

	/*	local beneficiary = null; */
	/*	for (local i = 0; i < n_irrelevant_companies; i++) */
	/*		if (companies[i].active && companies[i].hq != GSMap.TILE_INVALID) */
	/*			beneficiary = companies[i]; */

	/*	if (!beneficiary) */
	/*	{ */
	/*		GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.RH_CANNOT_OPERATE), GSCompany.COMPANY_INVALID, Locs.NR_CAPITAL, Locs.CAPITAL); */
	/*		return; */
	/*	} */

	/*	local grant = ComputeGrant(beneficiary, companies); */

	/*	// Get total value of the companies to tax */
	/*	local taxables = companies.slice(-n_taxed_companies); */
	/*	local taxables_tot_value = 0; */
	/*	foreach (taxable in taxables) */
	/*		taxables_tot_value += taxables.q_value; */

	/*	// Compute leviable tax */
	/*	local leviable = 0; */
	/*	foreach (taxable in taxables) */
	/*	{ */
	/*		taxable.rh_levy <- grant * taxable.q_value / taxables_tot_value; */
	/*		if (pot.CanMeansTestedlyTax(taxable, taxable.rh_levy)) */
	/*			leviable += taxable.rh_levy; */
	/*	} */

	/*	// Levy RH tax */
	/*	foreach (taxable in taxables) */
	/*		pot.MeansTestedTax(taxable, taxable.rh_levy); */

	/*	// Attempt to pay RH grant */
	/*	if (pot.Grant(beneficiary, grant)) */
	/*		GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.ROBIN_HOODED, beneficiary.id, grant), beneficiary.name, GSNews.NR_TILE, beneficiary.hq); */
	/*	else */
	/*		GSNews.Create(GSNews.NT_GENERAL, GSText(GSText.CANNOT_RH_GRANT_NO_CASH, quarter), GSCompany.COMPANY_INVALID, Locs.NR_CAPITAL, Locs.CAPITAL); */
	/* } */

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
