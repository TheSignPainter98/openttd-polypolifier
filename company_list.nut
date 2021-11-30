require("module.nut")
require("util.nut")

class CompanyList extends Module
{
	company_ids = null;
	join_dates = null;
	companies = null;

	constructor()
	{
		::Module.constructor();
		company_ids = [];
		join_dates = [];
	}


	function Save()
	{
		local packed_join_dates = [];
		foreach (date in join_dates)
			packed_join_dates.append(SaveDate(date))
		return {
			company_ids = company_ids,
			join_dates = packed_join_dates,
		}
	}

	function Load(version, data)
	{
		parent.Load(version, data);
		company_ids = data.company_ids;
		join_dates = []
		foreach (date in data.join_dates)
			join_dates.append(LoadDate(date))
	}

	function Refresh()
	{
		companies = []
		local n_companies = company_ids.len();
		for (local i = 0; i < n_companies; i++)
			companies.append(GetCompanyInfo(company_ids[i], join_dates[i]))
	}

	function GetInfoList()
	{
		if (!companies)
			Refresh();
		return companies;
	}

	function GetCompanyInfo(id, join_date)
	{
		local company = {
			id = id,
			name = GSCompany.GetName(id),
			hq = GSCompany.GetCompanyHQ(id),
			balance = GSCompany.GetBankBalance(id),
			q_income = GSCompany.GetQuarterlyIncome(id, GSCompany.CURRENT_QUARTER),
			q_value = GSCompany.GetQuarterlyCompanyValue(id, GSCompany.CURRENT_QUARTER), // TODO: this doesn't actually work get the value it just returns 1?!
			q_expenses = GSCompany.GetQuarterlyExpenses(id, GSCompany.CURRENT_QUARTER),
			q_cargo = GSCompany.GetQuarterlyCargoDelivered(id, GSCompany.CURRENT_QUARTER),
			join_date = join_date,
			age_months = DiffMonths(GSDate.GetCurrentDate(), join_date),
			active = true, // TODO: implement some activity checker
		}

		company.q_value_delta <- company.q_value - GSCompany.GetQuarterlyCompanyValue(id, GSCompany.CURRENT_QUARTER - 1);

		local q_perf = GSCompany.GetQuarterlyPerformanceRating(id, GSCompany.CURRENT_QUARTER);
		company.q_perf <- q_perf == -1 ? 0 : q_perf;

		local GetImpureAttributes = function (id, company){
			local _ = GSCompanyMode(id);
			company.loaned <- GSCompany.GetLoanAmount();
			company.max_loan <- GSCompany.GetMaxLoanAmount();
		}
		GetImpureAttributes(id, company);

		GSLog.Error("<<<");
		foreach (k,v in company)
			GSLog.Error("=== " + k + ": " + v);
		GSLog.Error(">>>");

		return company;
	}

	function DiffMonths(d1, d2)
	{
		local y1 = GSDate.GetYear(d1);
		local y2 = GSDate.GetYear(d2);
		local m1 = GSDate.GetMonth(d1);
		local m2 = GSDate.GetMonth(d2);
		return m2 - m1 + 12 * (y2 - y1);
	}

	function OnEvent(args)
	{
		local et = args[0];
		local ev = args[1];
		switch (et)
		{
			case GSEvent.ET_COMPANY_NEW:
				OnCompanyNew(ev);
				break;
			case GSEvent.ET_COMPANY_MERGER:
				OnCompanyMerger(ev);
				break;
			case GSEvent.ET_COMPANY_BANKRUPT:
				OnCompanyBankrupt(ev);
				break;
		}
	}

	function OnCompanyNew(ev)
	{
		ev = ::GSEventCompanyNew.Convert(ev);
		company_ids.append(ev.GetCompanyID());
		join_dates.append(GSDate.GetCurrentDate());
	}

	function OnCompanyMerger(ev)
	{
		ev = ::GSEventCompanyMerger.Convert(ev);
		Forget(ev.GetOldCompanyID());
	}

	function OnCompanyBankrupt(ev)
	{
		ev = ::GSEventCompanyBankrupt.Convert(ev);
		Forget(ev.GetCompanyID());
	}

	function Forget(id)
	{
		local idx = Util.Find(company_ids, ev.GetOldCompanyID());
		company_ids.remove(idx);
		join_dates.remove(idx);
	}
}
