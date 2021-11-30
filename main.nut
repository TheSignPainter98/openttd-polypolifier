require("bandit_tax.nut")
require("company_list.nut")
require("poll_annuity.nut")
require("pot.nut")
require("robin_hood_scheme.nut")
require("setting_names.nut")
require("version.nut")
require("welcome.nut")

HmrcGS <- {}

// Bandit tax rate must always be HIGHER than the robin hood tax rate to ensure players submit to the scheme

print <- GSLog.Error

class MultiGS extends GSController
{
	DAY_TICKS = 74;
	modules = null;
	on_month = null;
	on_quarter = null;
	last_month = null;
	last_quarter = null;
	initial_month = null;
	initial_year = null;
	companies = null;

	constructor()
	{
		modules = [];
		on_month = [];
		on_quarter = [];
		last_month = null;
		last_quarter = null;

		local date = GSDate.GetCurrentDate();
		initial_month = GSDate.GetMonth(date);
		initial_year = GSDate.GetMonth(date);

		companies = CompanyList();
		modules.append(companies);

		local pot = Pot();
		modules.append(pot);

		// TODO: recuperation tax
		modules.append(BanditTax(pot, companies));
		modules.append(RobinHoodScheme(pot, companies));
		modules.append(PollAnnuity(pot, companies));

		modules.append(Welcomer(companies));
	}

	function Save()
	{
		local ret = {};
		for (local i = 0; i < modules.len(); i++)
			ret[i] <- modules[i].Save();

		ret.last_month <- last_month;
		ret.last_quarter <- last_quarter;

		return ret;
	}

	function Load(version, data)
	{
		if (data.len() != modules.len())
			return;

		for (local i = 0; i < modules.len(); i++)
			modules[i].Load(version, data[i]);

		last_month = data.last_month;
		last_quarter = data.last_quarter;
	}

	function ModExecute(x, ...)
	{
		print("Executing '" + x + "' with " + vargc + " args");
		if (vargc)
		{
			local vargs = null;
			if (vargc == 1)
				vargs = vargv[0];
			else
			{
				vargs = [];
				for (local i = 0; i < vargc; i++)
					vargs.append(vargv[i]);
			}

			foreach (module in modules)
				if (x in module && module[x])
					module[x](vargs);
		}
		else
			foreach (module in modules)
				if (x in module && module[x])
					module[x]();
	}

	function Start()
	{
		Sleep(1); // Avoid initialisation bugs
		local first = true;

		while (true)
		{
			local iter_start_tick = GetTick();
			if (first)
			{
				iter_start_tick--; // Re-align after skipping the first tick
				first = false;
			}

			HandleEvents();

			// Get date data
			local date = GSDate.GetCurrentDate();
			local year = GSDate.GetYear(date);
			local month = GSDate.GetMonth(date);
			local quarter = 1 + (month - 1) / 4;

			// Collect jobs to execute
			local to_execute = [];
			if (last_month != month)
				to_execute.append(ModuleJob("OnMonth", month, year));
			if (last_quarter != quarter)
				to_execute.append(ModuleJob("OnQuarter", quarter, year));

			// Execute the jobs
			if (to_execute.len())
			{
				ModExecute("Refresh");
				foreach (job in to_execute)
					ModExecute(job.name, job.args);
			}

			last_month = month;
			last_quarter = quarter;

			local ticks_taken = iter_start_tick - GetTick();
			local wait = DAY_TICKS - ticks_taken;
			Sleep(wait);
		}
	}

	function HandleEvents()
	{
		while(GSEventController.IsEventWaiting())
		{
			local ev = GSEventController.GetNextEvent();
			if(ev == null)
				return;

			local et = ev.GetEventType();

			ModExecute("OnEvent", et, ev);
		}
	}

	// TODO: scheme_introduction_delay_years = 1
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
