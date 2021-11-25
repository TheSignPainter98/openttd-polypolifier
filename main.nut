require("version.nut")
require("setting_names.nut")

// Bandit tax rate must always be HIGHER than the robin hood tax rate to ensure players submit to the scheme

class HmrcGS extends GSController
{
	function Save();
	function Load(version, data);
	function Start();

	scheme_introduction_delay_years = 0 // TODO: 1
	loan_monthly_rate = 0.05
	loan_recuperation_rate = 0.30
	loan_amount = 0
	loan_cap = 10000000
	loan_min = -5000000
	prev_loan_update_month = null
	grace_epsilon = 50000
	poll_annuity = 20000
	poll_annuity_issue_months = [ 4 ]
	stim_months = [ 1, 4, 7, 10 ]
	stim_day = 2 // TODO: 1
	send_welcome_message = true
	bandit_tax_rate = 0.05
	bandit_tax_min = 5500
	robin_hood_basic_rate = 0.10
	wdate = null

	ANNOUNCEMENT_NO_HQ = [ "FREE MONEY BONANZA! Government announces tax breaks and new stimulus scheme for all companies headquartered in the UK and ROI. Commuters shocked and appalled to learn that Company ", " does not have its HQ in the UK/ROI, and hence will not benefit" ]
	ANNOUNCEMENT_HQ = "\"It's the nanny-state gone mad!\" says Farage. Government announces tax breaks and new stimulus scheme for all companies headquartered in the UK and ROI."
	ROBIN_HOODED = [ "SNOWFLAKE LIBERALS AT IT AGAIN! ", " selected by the government to receive a stimulus grant of £" ]
	POLL_ANNUITIED = [ "BRITAIN TAKES BACK CONTROL OF HER FINANCES! Government announces stimulus package of £", " for all UK and ROI transport companies" ]
	POLL_ANNUITY_MISSED = [ "As transport companies around the UK and ROI take their £", " poll annuity, questions are asked why ", " hasn't moved their HQ to the British Isles" ]
	RH_CANNOT_OPERATE = [ "Westminster panic as Gov. study shows only ", " in ", " companies take up new \"Robin Hood\" tax benefit scheme for UK&ROI-based companies" ]
}

function HmrcGS::Save()
{
	local data = {
		loan_amount = SaveFloat(loan_amount)
		send_welcome_message = send_welcome_message
	}

	if (wdate)
		data.wdate <- SaveDate(wdate)
	if (prev_loan_update_month)
		data.prev_loan_update_month <- prev_loan_update_month

	return data
}

function HmrcGS::Load(version, data)
{
	if (version != VERSION)
		return

	wdate = LoadDate(data.wdate)
	prev_loan_update_month = data.prev_loan_update_month
	loan_amount = LoadFloat(data.loan_amount)
	send_welcome_message = data.send_welcome_message
}

function HmrcGS::SaveFloat(float)
	return float.tostring()

function HmrcGS::LoadFloat(str)
	if (str)
		return str.tofloat()

function HmrcGS::SaveDate(date)
	return {
		year = GSDate.GetYear(date)
		month = GSDate.GetMonth(date)
		day = GSDate.GetDayOfMonth(date)
	}

function HmrcGS::LoadDate(date)
	if (date)
		return GSDate.GetDate(date.year, date.month, date.day)

function HmrcGS::Start()
{
	GetSettings()
	/* local london = 1 */
	/* local towns = GSTownList() */
	/* local town = towns.Begin() */
	/* while (town) */
	/* { */
	/* 	if (GSTown.GetName(town) == "London") */
	/* 	{ */
	/* 		london = town */
	/* 		break */
	/* 	} */
	/* 	town = towns.Next() */
	/* } */

	local initial_date = GSDate.GetCurrentDate()
	local next_stim_year = GSDate.GetYear(initial_date) + scheme_introduction_delay_years // TODO this on resume!
	local curr_month = GSDate.GetMonth(initial_date)

	while (true)
	{
		if (12 < curr_month + 1)
		{
			next_stim_year++
			curr_month = 0
		}

		AwaitDate(GSDate.GetDate(next_stim_year, curr_month + 1, stim_day))
		curr_month = GSDate.GetMonth(GSDate.GetCurrentDate())
		GSLog.Error("=== " + curr_month + ", " + In(stim_months, curr_month))
		if (!In(stim_months, curr_month))
			continue

		GetSettings()

		UpdateLoan()

		GSLog.Error("================================================================================")
		GSLog.Error("Hello, this is Gov knocking at " + GetTick() + ": " + GetVersion())
		GSLog.Error("Current company index is " + GSCompany.ResolveCompanyID(GSCompany.COMPANY_SELF))
		GSLog.Error("First company index is " + GSCompany.ResolveCompanyID(GSCompany.COMPANY_FIRST))
		GSLog.Error("Last company index is " + GSCompany.ResolveCompanyID(GSCompany.COMPANY_LAST))

		local companies = []
		for (local i = 0; GSCompany.ResolveCompanyID(i) != GSCompany.COMPANY_INVALID; i++)
			companies.append(GetCompanyInfo(i))

		if (send_welcome_message)
		{
			send_welcome_message = false;
			SendWelcomeMessages(companies)
			continue
		}

		BanditTax(companies)
		if (In(poll_annuity_issue_months, curr_month))
			IssueUBI(companies)
		else
			DoRobinHoodScheme(companies)

		GSLog.Error("The current bank balance of 0 is " + GSCompany.GetBankBalance(0))
		GSLog.Error("Gov currently owes HM Treasury " + loan_amount)
		GSLog.Error("================================================================================")
	}
}

function HmrcGS::GetSettings()
{
	loan_monthly_rate = GetPercentageSetting(::BOE_POT_RATE)
	loan_recuperation_rate = GetPercentageSetting(::BOE_POT_RECUPERATION_RATE)
	loan_cap = GetSetting(::BOE_POT_CAP)
	loan_overdraft_cap = GetSetting(::BOE_POT_OVERDRAFT_CAP)
	grace_epsilon = GetSetting(::GRACE_MARGIN)
	poll_annuity = GetSetting(::ANNUITY)
	bandit_tax_rate = GetPercentageSetting(::BANDIT_TAX_RATE)
	bandit_tax_min = GetSetting(::BANDIT_TAX_MIN)
	robin_hood_basic_rate = GetSetting(::ROBIN_HOOD_RATE)

	GSLog.Error("loan_monthly_rate:" + loan_monthly_rate)
	GSLog.Error("loan_recuperation_rate:" + loan_recuperation_rate)
	GSLog.Error("loan_cap:" + loan_cap)
	GSLog.Error("loan_overdraft_cap:" + loan_overdraft_cap)
	GSLog.Error("grace_epsilon:" + grace_epsilon)
	GSLog.Error("poll_annuity:" + poll_annuity)
	GSLog.Error("bandit_tax_rate:" + bandit_tax_rate)
	GSLog.Error("bandit_tax_min:" + bandit_tax_min)
	GSLog.Error("robin_hood_basic_rate:" + robin_hood_basic_rate)
}

function HmrcGS::GetPercentageSetting(name)
{
	return GetSetting(name) / 100.0
}

function HmrcGS::GetSetting(name)
{
	local v = ::GSController.GetSetting(name)
	if (v == -1)
		GSLog.Error("Unknown setting: " + name)
	return v
}

function HmrcGS::In(list, val)
{
	for (local i = 0; i < list.len(); i++)
		if (list[i] == val)
			return true
	return false
}

function HmrcGS::SendWelcomeMessages(companies)
{
	GSLog.Error("Sending welcome messages")

	for (local i = 0; i < companies.len(); i++)
	{
		local company = companies[i]
		if (company.hq == GSMap.TILE_INVALID)
			GSNews.Create(GSNews.NT_GENERAL, format(ANNOUNCEMENT_NO_HQ, company.id + 1), company.id, GSNews.NR_NONE, 0)
		else
			GSNews.Create(GSNews.NT_GENERAL, ANNOUNCEMENT_HQ, company.id, GSNews.NR_NONE, company.hq)
	}

	GSLog.Error("Done sending welcome messages")
}

function HmrcGS::format(fmt_str_parts, ...)
{
	// A bad format function because the global one from the standard library isn't available
	local str = ""
	local i = 0
	local j = 0
	local n = fmt_str_parts.len()
	while (true)
	{
		if (i < n)
			str += fmt_str_parts[i]
		if (j < vargc)
			str += vargv[j]
		if (!(i < n || j < vargc))
			break
		i++
		j++
	}
	return str
}

function HmrcGS::AwaitDate(wdate)
{
	this.wdate = wdate
	while (GSDate.GetCurrentDate() < wdate)
		Sleep(100)
}

function HmrcGS::GetCompanyInfo(id)
{
	local company = {
		id = id
		name = GSCompany.GetName(id)
		hq = GSCompany.GetCompanyHQ(id)
		balance = GSCompany.GetBankBalance(id)
		q_income = GSCompany.GetQuarterlyIncome(id, GSCompany.CURRENT_QUARTER)
		q_value = GSCompany.GetQuarterlyCompanyValue(id, GSCompany.CURRENT_QUARTER)
		q_expenses = GSCompany.GetQuarterlyExpenses(id, GSCompany.CURRENT_QUARTER)
		q_cargo = GSCompany.GetQuarterlyCargoDelivered(id, GSCompany.CURRENT_QUARTER)
	}

	local q_perf = GSCompany.GetQuarterlyPerformanceRating(id, GSCompany.CURRENT_QUARTER)
	company.q_perf <- q_perf == -1 ? 0 : q_perf

	local GetImpureAttributes = function (id, company){
		local _ = GSCompanyMode(id)
		company.loaned <- GSCompany.GetLoanAmount()
		company.max_loan <- GSCompany.GetMaxLoanAmount()
	}
	GetImpureAttributes(id, company)

	company.robin_hood_priority <- GetRobinHoodPriority(company)

	GSLog.Error("<<<")
	GSLog.Error("len: " + company.len)
	GSLog.Error("id: " + company.id)
	GSLog.Error("name: " + company.name)
	GSLog.Error("hq: " + company.hq)
	GSLog.Error("balance: " + company.balance)
	GSLog.Error("q_income: " + company.q_income)
	GSLog.Error("q_value: " + company.q_value)
	GSLog.Error("q_expenses: " + company.q_expenses)
	GSLog.Error("q_cargo: " + company.q_cargo)
	GSLog.Error("q_perf: " + company.q_perf)
	GSLog.Error("loaned: " + company.loaned)
	GSLog.Error("max_loan: " + company.max_loan)
	GSLog.Error("robin_hood_priority: " + company.robin_hood_priority)
	GSLog.Error(">>>")

	return company
}

function HmrcGS::GetRobinHoodPriority(company)
	return -(company.q_value + company.balance - company.loaned)
	/* return -company.q_income - company.q_value + company.q_expenses - company.q_cargo - company.q_perf - company.balance * (1 - company.loaned / company.max_loan) */

function HmrcGS::GetCapitalTaxPriority(company)
	return company.q_income + company.q_value + (company.balance - company.loaned)

function HmrcGS::UpdateLoan()
{
	local curr_month = GSDate.GetMonth(GSDate.GetCurrentDate())
	if (curr_month != prev_loan_update_month && loan_amount > 0)
	{
		prev_loan_update_month = curr_month
		loan_amount *= 1 + loan_monthly_rate
	}
	if (loan_amount > loan_cap)
		loan_amount = loan_cap
	else if (loan_amount < loan_min)
		loan_amount = loan_min
}

function HmrcGS::BanditTax(companies)
{
	// Tax unregistered companies
	GSLog.Error("Issuing bandit tax")
	for (local i = 0; i < companies.len(); i++)
	{
		local company = companies[i]
		if (company.hq == GSMap.TILE_INVALID)
		{
			local bandit_tax = Max(company.balance * bandit_tax_rate, bandit_tax_min)
			Tax(company, bandit_tax)
			GSLog.Error("Bandit tax levied: " + bandit_tax + " for balance " + company.balance)
			loan_amount -= bandit_tax
		}
	}
}

function HmrcGS::DoRobinHoodScheme(companies)
{
	GSLog.Error("Issuing Robin Hood tax and breaks")
	local n_companies = companies.len()

	if (n_companies < 2)
	{
		GSLog.Error("Robin hood cannot be operated without distinct benefactors and financiers")
		return
	}

	local n_taxed_companies = n_companies / 2
	local n_irrelevant_companies = n_companies - n_taxed_companies

	local robin_hood_sorter = function (a,b) {
		local a = a.robin_hood_priority
		local b = b.robin_hood_priority
		if (a < b)
			return 1
		if (a > b)
			return -1
		return 0
	}

	local beneficiary = null
	companies.sort(robin_hood_sorter)
	for (local i = 0; i < n_irrelevant_companies; i++)
		if (companies[i].hq != GSMap.TILE_INVALID)
			beneficiary = companies[i]
		else
			GSLog.Error("Company " + companies[i].name + " (" + companies[i].id + ") does not have an HQ built in the British Isles and is therefore ineligible for stimulus grants by Gov")

	if (!beneficiary)
	{
		local built_hqs = 0
		for (local i = 0; i < n_companies; i++)
			if (companies[i].hq != GSMap.TILE_INVALID)
				built_hqs++
		GSNews.Create(GSNews.NT_GENERAL, format(RH_CANNOT_OPERATE, built_hqs, n_companies), GSCompany.COMPANY_INVALID, GSNews.NR_NONE, 0)
		return
	}

	local grant = ComputeSizeOfHoodToRob(beneficiary, companies)
	local to_tax = companies.slice(-n_taxed_companies)
	local taxables_tot_value = 0
	for (local i = 0; i < to_tax.len(); i++)
		taxables_tot_value += to_tax[i].q_value

	GSNews.Create(GSNews.NT_GENERAL, format(ROBIN_HOODED, company_name, grant), beneficiary.name, GSNews.NR_NONE, 0)
	Pay(beneficiary, grant)

	for (local i = 0; i < taxed.len(); i++)
	{
		local company_to_tax = to_tax[i]
		local levy = grant * (company_to_tax.q_value / taxables_tot_value)
		if (!CanTax(taxed[i], levy))
		{
			loan_amount += levy
			continue
		}

		Tax(taxed[i], levy)
		if (loan_amount > 0)
		{
			local loan_recuperation_levy = Min(loan_amount, levy * loan_recuperation_rate)
			if (CanTax(taxed[i], loan_recuperation_levy))
			{
				Tax(taxed[i], loan_recuperation_levy)
				loan_amount -= loan_recuperation_levy
			}
		}
	}
}

function HmrcGS::Min(a, b)
{
	if (a < b)
		return a
	return b
}

function HmrcGS::Max(a, b)
{
	if (a < b)
		return b
	return a
}

function HmrcGS::CanTax(company, amount)
	return amount + grace_epsilon <= company.balance - company.loaned

function HmrcGS::ComputeSizeOfHoodToRob(beneficiary, companies)
	return beneficiary.q_value * robin_hood_basic_rate

function HmrcGS::IssueUBI(companies)
{
	GSLog.Error("Issuing UBI")
	for (local i = 0; i < companies.len(); i++)
	{
		local company = companies[i]
		if (company.hq == GSMap.TILE_INVALID)
		{
			GSNews.Create(GSNews.NT_GENERAL, format(POLL_ANNUITY_MISSED, poll_annuity, company.name), company.id, GSNews.NR_NONE, 0)
			continue
		}

		GSNews.Create(GSNews.NT_GENERAL, format(POLL_ANNUITIED, poll_annuity), company.id, GSNews.NR_NONE, 0)
		Pay(company, poll_annuity)
		loan_amount += poll_annuity
	}
}

function HmrcGS::Tax(company, amount)
	Pay(company, -amount)

function HmrcGS::Pay(company, amount)
{
	GSLog.Error("Paying £" + amount + " to " + company.name + " (" + company.id + ")")
	if (typeof amount == "float")
		amount = amount.tointeger()
	if (!GSCompany.ChangeBankBalance(company.id, amount, GSCompany.EXPENSES_OTHER))
		GSLog.Error("Failed to change bank balance of " + company.id + " by £" + amount)
}
