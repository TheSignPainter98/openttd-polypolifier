require("version.nut")

class Module
{
	function Refresh();

	event_handlers = null;
	OnMonth = null;
	OnQuarter = null;
	OnEvent = null;

	constructor()
	{
		event_handlers = {};
	}

	function Save() {}
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
