require("module.nut")
require("setting_names.nut")

class Pot extends Module
{
	quarterly_rate = 0.05;
	content = null;
	cap_spill = null;
	cap_overdraft = null;
	grace_margin = 50000;
	grace_proportion = 0.75;

	constructor()
	{
		::Module.constructor();
		content = 0;
	}

	function Save()
	{
		return {
			content = SaveFloat(content),
		}
	}

	function Load(version, data)
	{
		GSLog.Error("Loading pot");
		if (version != ::VERSION)
			return;
		content = LoadFloat(data.content);
	}

	function ZeroContents()
	{
		content = 0;
	}

	function GetContents()
	{
		return content;
	}

	function Add(amt)
	{
		assert(0 <= amt);
		content += amt;
	}
}
