require("version.nut")

class ModuleCommander
{
	modules = [];

	function Save()
	{
		local ret = [];
		foreach (module in ModuleCommander.modules)
			ret.append(module.Save());
		return ret;
	}

	function Load(version, data)
	{
		if (data.len() != ModuleCommander.modules.len())
			return;

		for (local i = 0; i < ModuleCommander.modules.len(); i++)
			ModuleCommander.modules[i].Load(version, data[i]);
	}

	function Execute(x, ...)
	{
		local start_tick = GetTick();
		::print("Executing '" + x + "' with " + vargc + " args");
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

			foreach (module in ModuleCommander.modules)
				if (x in module && module[x])
					module[x](vargs);
		}
		else
			foreach (module in ModuleCommander.modules)
				if (x in module && module[x])
					module[x]();

		::print("Execution of '" + x + "' took " + (GetTick() - start_tick) + "t (" + ::ModuleCommander.modules.len() + " modules)");
	}
}

class Module
{
	function Refresh();

	OnMonth = null;
	OnQuarter = null;
	OnEvent = null;

	constructor()
	{
		::ModuleCommander.modules.append(this);
	}

	function Save() { }
	function Load(version, data)
	{
		if (version != ::VERSION)
			return;
	}

	function GetPercentageSetting(name)
	{
		return GetSetting(name) / 100.0;
	}

	function GetSetting(name)
	{
		local v = ::GSController.GetSetting(name);
		if (v == -1)
			GSLog.Error("Unknown setting: " + name);
		return v;
	}

	function SaveFloat(float)
	{
		return float.tostring();
	}

	function LoadFloat(str)
	{
		return str.tofloat();
	}

	function SaveDate(date)
	{
		return {
			year = GSDate.GetYear(date),
			month = GSDate.GetMonth(date),
			day = GSDate.GetDayOfMonth(date),
		};
	}

	function LoadDate(date)
	{
		return GSDate.GetDate(date.year, date.month, date.day);
	}
}
