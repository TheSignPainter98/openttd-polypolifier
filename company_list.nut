require("module.nut")
require("util.nut")

class CompanyList extends Module
{
	company_ids = null;
	join_dates = null;
	companies = null;
	activity_data = null;
	prev_activity_data = null;

	constructor()
	{
		::Module.constructor();
		company_ids = [];
		join_dates = [];
		activity_data = null;
		prev_activity_data = null;
	}

	function Save()
	{
		local packed_join_dates = [];
		foreach (d in join_dates)
			packed_join_dates.append(SaveDate(v));
		return {
			company_ids = company_ids,
			join_dates = packed_join_dates,
			prev_activity_data = prev_activity_data,
		}
	}

	function Load(version, data)
	{
		/* parent.Load(version, data); */
		if (version != ::VERSION)
			return;
		company_ids = data.company_ids;
		prev_activity_data = data.prev_activity_data;
		join_dates = [];
		foreach (d in data.join_dates)
			join_dates.append(LoadDate(d));
	}

	function Refresh()
	{
		if (!activity_data)
			UpdateActivityData();

		companies = [];
		local n_companies = company_ids.len();
		GSLog.Error("Collating data on " + n_companies + " companies");
		for (local i = 0; i < n_companies; i++)
			if (GSCompany.GetName(company_ids[i]) != "TownCars")
				companies.append(GetCompanyInfo(company_ids[i], join_dates[i]))
			else
				GSLog.Error("Ignoring company " + GSCompany.GetName(company_ids[i]));
	}

	function OnYear(_)
	{
		UpdateActivityData();
	}

	function UpdateActivityData()
	{
		GSLog.Error("Updating activity data");
		prev_activity_data = activity_data;
		activity_data = GetActivityData();
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
			value = GSCompany.GetQuarterlyCompanyValue(id, GSCompany.CURRENT_QUARTER),
			join_date = join_date,
			age_months = DiffMonths(GSDate.GetCurrentDate(), join_date),
			active = IsActive(id),
			earnings = Util.Max(0, GSCompany.GetQuarterlyIncome(id, GSCompany.CURRENT_QUARTER + 1)),
		}

		/* local q_perf = GSCompany.GetQuarterlyPerformanceRating(id, GSCompany.CURRENT_QUARTER); */
		/* company.q_perf <- q_perf == -1 ? 0 : q_perf; */

		{
			local _ = GSCompanyMode(id);
			company.loaned <- GSCompany.GetLoanAmount();
			company.max_loan <- GSCompany.GetMaxLoanAmount();
		}

		company.profit <- company.balance - company.loaned;

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
		return m1 - m2 + 12 * (y1 - y2);
	}

	function IsActive(id)
	{
		if (!prev_activity_data)
			return true;
		if (!(id in prev_activity_data))
			return true;

		local curr_data = activity_data[id];
		local prev_data = prev_activity_data[id];
		foreach (k,_ in prev_data)
		{
			GSLog.Error("Checking " + k + ": " + prev_data[k] + " == " + curr_data[k] + "?");
			if (prev_data[k] < curr_data[k])
				return true;
		}

		return false;
	}

	function GetActivityData()
	{
		local data = {};

		foreach (id in company_ids)
		{
			local _ = GSCompanyMode(id);
			local d = {
				infrastructure = 0,
				vehicles = 0,
			};
			foreach (itype in ["RAIL", "SIGNALS", "ROAD", "CANAL", "STATION", "AIRPORT"])
				d.infrastructure += GSInfrastructure.GetInfrastructurePieceCount(id, GSInfrastructure["INFRASTRUCTURE_" + itype]);
			data[id] <- d;
		}

		foreach (id in company_ids)
		{
			local _ = GSCompanyMode(id);
			GSLog.Error("Vehicle list has length " + GSVehicleList().Count());
			foreach (vehicle,_ in GSVehicleList())
			{
				GSLog.Error("Vehicle " + vehicle + " has owner " + GSVehicle.GetOwner(vehicle));
				local owner = GSVehicle.GetOwner(vehicle);
				if (owner != -1)
					data[owner].vehicles++;
			}
		}

		return data;
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
		local id = ev.GetCompanyID();
		GSLog.Error("Detected new company with id " + id);
		company_ids.append(id);
		join_dates.append(GSDate.GetCurrentDate());
	}

	function OnCompanyMerger(ev)
	{
		ev = ::GSEventCompanyMerger.Convert(ev);
		GSLog.Error("Detected merged company with id " + ev.GetOldCompanyID());
		Forget(ev.GetOldCompanyID());
	}

	function OnCompanyBankrupt(ev)
	{
		ev = ::GSEventCompanyBankrupt.Convert(ev);
		GSLog.Error("Detected bankrupt company with id " + ev.GetCompanyID());
		Forget(ev.GetCompanyID());
	}

	function Forget(id)
	{
		local idx = Util.Find(company_ids, id);
		company_ids.remove(idx);
		join_dates.remove(idx);
	}
}
