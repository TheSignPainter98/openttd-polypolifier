require("module.nut")
require("setting_names.nut")

class Pot extends Module
{
	monthly_rate = 0.05;
	recuperation_rate = 0.30;
	content = null;
	cap_spill = null;
	cap_overdraft = null;
	grace_margin = 50000;

	constructor()
	{
		::Module.constructor();
		content = 0;
	}

	function Save()
	{
		return {
			content = content,
		}
	}

	function Load(version, data)
	{
		parent.Load(version, data);
		content = data.content;
	}

	function Refresh()
	{
		monthly_rate = GetPercentageSetting(::POT_RATE);
		recuperation_rate = GetPercentageSetting(::POT_RECUPERATION_RATE);
		cap_spill = GetSetting(::POT_CAP);
		cap_overdraft = GetSetting(::POT_OVERDRAFT_CAP);
		grace_margin = GetSetting(::GRACE_MARGIN);
	}

	function OnQuarter(_)
	{
		if (content < 0)
			content *= 1 + monthly_rate
		else if (cap_spill < content)
			content = cap_spill
	}

	function MeansTestedTax(company, amount)
	{
		if (typeof amount == "float")
			amount = amount.tointeger();

		if (CanMeansTestedlyTax(company, amount))
		{
			Tax(company, amount);
			content += amount;
		}
	}

	function CanMeansTestedlyTax(company, amount)
	{
		if (typeof amount == "float")
			amount - amount.tointeger();
		return amount + grace_margin <= company.balance - company.loaned;
	}

	function Tax(company, amount)
	{
		if (typeof amount == "float")
			amount = amount.tointeger();
		Pay(company, -amount);
	}

	function Grant(company, amount)
	{
		if (typeof amount == "float")
			amount = amount.tointeger();

		if (!CanGrant(amount))
			return false;

		content -= amount;
		Pay(company, amount);

		return true;
	}

	function CanGrant(amount)
	{
		return cap_overdraft <= content - amount;
	}

	/* function CanGrantWithExtraTax(amount, extra_tax) */
	/* { */
	/* 	if (typeof amount == "float") */
	/* 		amount = amount.tointeger(); */
	/* 	if (typeof extra_tax == "float") */
	/* 		extra_tax = extra_tax.tointeger(); */
	/* 	return content + extra_tax - amount >= cap_overdraft */
	/* } */

	function Pay(company, amount)
	{
		if (amount >= 0)
			GSLog.Error("Paying $" + amount + " to " + company.name + " (" + company.id + ")");
		else
			GSLog.Error("Paying -$" + -amount + " to " + company.name + " (" + company.id + ")");
		if (!GSCompany.ChangeBankBalance(company.id, amount, GSCompany.EXPENSES_OTHER))
			GSLog.Error("Failed to change bank balance of " + company.id + " by £" + amount);
	}
}
