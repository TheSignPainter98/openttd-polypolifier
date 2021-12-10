require("agency_tax.nut")
require("bandit_tax.nut")
require("company_list.nut")
require("fine.nut")
require("module.nut")
require("poll_annuity.nut")
require("pot.nut")
require("rating_medic.nut")
require("robin_hood_scheme.nut")
require("setting_names.nut")
require("version.nut")
require("welcome.nut")

// Bandit tax rate must always be HIGHER than the robin hood tax rate to ensure players submit to the scheme

class MultiGS extends GSController
{
	DAY_TICKS = 74;

	last_month = null;
	last_quarter = null;
	last_year = null;
	initial_month = null;
	initial_year = null;

	constructor()
	{
		last_month = null;
		last_quarter = null;
		last_year = null;

		local date = GSDate.GetCurrentDate();
		initial_month = GSDate.GetMonth(date);
		initial_year = GSDate.GetMonth(date);

		local companies = CompanyList();

		// Welcome new companies
		Welcomer(companies);

		// Create fine handler (for mods)
		FineExecutor(companies);

		// Declare taxes
		BanditTax(companies);
		RobinHoodScheme(companies);
		local pot = Pot();
		PollAnnuity(pot, companies);
		AgencyTax(pot, companies);

		// Fix annoying rating changes.
		RatingMedic();

		GSLog.Error("Registered " + ::ModuleCommander.modules.len() + " modules");
	}

	function Save()
	{
		return {
			last_month = last_month,
			last_quarter = last_quarter,
			modules = ::ModuleCommander.Save(),
		}
	}

	function Load(version, data)
	{
		last_month = data.last_month;
		last_quarter = data.last_quarter;
		::ModuleCommander.Load(version, data.modules);
	}

	function Start()
	{
		Sleep(1); // Avoid initialisation bugs
		local first = true;
		::ModuleCommander.Execute("PostInit");
		local post_init_ticks = GetTick();

		/* GSLog.Error("ASDF"); */
		/* local plane_type_names = { */
		/* 	[GSAirport.PT_HELICOPTER] = "helicopter", */
		/* 	[GSAirport.PT_SMALL_PLANE] = "plane-small", */
		/* 	[GSAirport.PT_BIG_PLANE] = "plane-big", */
		/* 	[GSAirport.PT_INVALID] = "invalid", */
		/* }; */
		/* local o = ""; */
		/* o += "["; */
		/* foreach (vt in ["RAIL", "ROAD", "WATER", "AIR"]) */
		/* { */
		/* 	foreach (e,_ in GSEngineList(GSVehicle["VT_" + vt])) */
		/* 	{ */
		/* 		if (!GSEngine.IsValidEngine(e)) */
		/* 			continue; */
		/* 		o += "{"; */
		/* 		o += "\"id\":" + e + ","; */
		/* 		o += "\"name\":\"" + GSEngine.GetName(e) + "\","; */
		/* 		o += "\"can_haul\":"; */
		/* 		o += "["; */
		/* 		foreach (c,_ in GSCargoList()) */
		/* 		{ */
		/* 			if (!GSCargo.IsValidCargo(c)) */
		/* 				continue; */
		/* 			if ((vt == "RAIL" && GSEngine.CanPullCargo(e, c)) || GSEngine.CanRefitCargo(e, c)) */
		/* 				o += "\"" + GSCargo.GetName(c) + "\","; */
		/* 		} */
		/* 		o += "],"; */
		/* 		o += "\"vehicle_type\":\"" + vt + "\","; */
		/* 		o += "\"cargo\":\"" + GSCargo.GetName(GSEngine.GetCargoType(e)) + "\","; */
		/* 		o += "\"capacity\":" + GSEngine.GetCapacity(e) + ","; */
		/* 		o += "\"max_speed\":" + GSEngine.GetMaxSpeed(e) + ","; */
		/* 		o += "\"price\":" + GSEngine.GetPrice(e) + ","; */
		/* 		o += "\"max_age\":" + GSEngine.GetMaxAge(e) + ","; */
		/* 		o += "\"running_cost\":" + GSEngine.GetRunningCost(e) + ","; */
		/* 		o += "\"power\":" + GSEngine.GetPower(e) + ","; */
		/* 		o += "\"weight\":" + GSEngine.GetWeight(e) + ","; */
		/* 		o += "\"max_tractive_effort\":" + GSEngine.GetMaxTractiveEffort(e) + ","; */
		/* 		local dd = GSEngine.GetDesignDate(e); */
		/* 		o += "\"design_date\":{\"year\":" + GSDate.GetYear(dd) + ",\"month\":" + GSDate.GetMonth(dd) + ",\"day\":" + GSDate.GetDayOfMonth(dd) + "},"; */
		/* 		o += "\"vehicle_type_id\":" + GSEngine.GetVehicleType(e) + ","; */
		/* 		o += "\"is_wagon\":" + GSEngine.IsWagon(e) + ","; */
		/* 		o += "\"road_type\":\"" + GSRoad.GetName(GSEngine.GetRoadType(e)) + "\","; */
		/* 		o += "\"rail_type\":\"" + GSRail.GetName(GSEngine.GetRailType(e)) + "\","; */
		/* 		o += "\"plane_type\":\"" + plane_type_names[GSEngine.GetPlaneType(e)] + "\","; */
		/* 		o += "\"is_articulated\":" + GSEngine.IsArticulated(e) + ","; */
		/* 		o += "\"max_order_distance\":" + GSEngine.GetMaximumOrderDistance(e); */
		/* 		o += "},"; */
		/* 	} */
		/* } */
		/* o += "]" */
		/* GSLog.Error(o); */
		/* GSLog.Error("ASDF"); */
		/* return; */

		while (true)
		{
			local iter_start_tick = GetTick();
			if (first)
				iter_start_tick -= 1 + post_init_ticks; // Re-align after skipping the first tick

			HandleEvents();

			// Get date data
			local date = GSDate.GetCurrentDate();
			local year = GSDate.GetYear(date);
			local month = GSDate.GetMonth(date);
			local quarter = 1 + (month - 1) / 3;

			// Collect jobs to execute
			local to_execute = [];
			if (!first) // Skip the first month for the sake of long-initialisation.
			{
				if (last_month != month)
					to_execute.append(ModuleJob("OnMonth", month, year));
				if (last_quarter != quarter)
					to_execute.append(ModuleJob("OnQuarter", quarter, year));
				if (last_year != year)
					to_execute.append(ModuleJob("OnYear", year));
			}

			// Execute the jobs
			if (to_execute.len())
			{
				::ModuleCommander.Execute("Refresh");
				foreach (job in to_execute)
					::ModuleCommander.Execute(job.name, job.args);
			}

			last_month = month;
			last_quarter = quarter;
			last_year = year;

			if (first)
				first = false;

			// Wait until the start of the next day.
			local ticks_taken = iter_start_tick - GetTick();
			local wait = (DAY_TICKS - ticks_taken) % DAY_TICKS;
			if (wait < 0)
				wait += DAY_TICKS;
			Sleep(wait);
		}
	}

	function HandleEvents()
	{
		while(GSEventController.IsEventWaiting())
		{
			local ev = GSEventController.GetNextEvent();
			if (ev == null)
				return;

			local et = ev.GetEventType();
			::ModuleCommander.Execute("OnEvent", et, ev);
		}
	}
}

class ModuleJob
{
	name = null;
	args = null;
	constructor(name, ...)
	{
		this.name = name;
		local args = [];
		for (local i = 0; i < vargc; i++)
			args.append(vargv[i]);
		this.args = args;
	}
}
