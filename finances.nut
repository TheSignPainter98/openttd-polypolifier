class Finances
{
	function Grant(company, amt)
	{
		assert(0 <= amt);
		Finances._MoneyDelta(company, amt);
	}

	function Tax(company, amt)
	{
		assert(0 <= amt);
		Finances._MoneyDelta(company, -amt);
	}

	function _MoneyDelta(company, amt)
	{
		amt = amt.tointeger();
		if (amt >= 0)
			GSLog.Error("Paying £" + amt + " to " + company.name + " (" + company.id + ")");
		else
			GSLog.Error("Paying -£" + -amt + " to " + company.name + " (" + company.id + ")");
		if (!GSCompany.ChangeBankBalance(company.id, amt, GSCompany.EXPENSES_OTHER, company.hq))
			GSLog.Error("Failed to change bank balance of " + company.id + " by £" + amt);
	}
}
