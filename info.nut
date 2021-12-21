require("version.nut")
require("setting_names.nut")

SELF_SETTINGS <- [
	{
		name = ANNUITY_BASELINE
		description = "Set the minimum annuity gifted to each company every April"
		min_value = 0
		max_value = 100000
		easy_value = 10000
		medium_value = 10000
		hard_value = 10000
		custom_value = 10000
		random_deviation = 0
		step_size = 5000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_LOW_THRESHOLD
		description = "Poll annuity low grant threshold"
		min_value = 50000
		max_value = 150000
		easy_value = 100000
		medium_value = 100000
		hard_value = 100000
		custom_value = 100000
		random_deviation = 0
		step_size = 25000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_MED_THRESHOLD
		description = "Poll annuity medium grant threshold"
		min_value = 175000
		max_value = 300000
		easy_value = 200000
		medium_value = 200000
		hard_value = 200000
		custom_value = 200000
		random_deviation = 0
		step_size = 25000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_HIGH_THRESHOLD
		description = "Poll annuity high grant threshold"
		min_value = 325000
		max_value = 500000
		easy_value = 400000
		medium_value = 400000
		hard_value = 400000
		custom_value = 400000
		random_deviation = 0
		step_size = 25000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_LOW_GRANT
		description = "Poll annuity low grant"
		min_value = 10000
		max_value = 30000
		easy_value = 20000
		medium_value = 20000
		hard_value = 20000
		custom_value = 20000
		random_deviation = 0
		step_size = 5000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_MED_GRANT
		description = "Poll annuity medium grant"
		min_value = 20000
		max_value = 45000
		easy_value = 30000
		medium_value = 30000
		hard_value = 30000
		custom_value = 30000
		random_deviation = 0
		step_size = 5000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_HIGH_GRANT
		description = "Poll annuity high grant"
		min_value = 30000
		max_value = 65000
		easy_value = 45000
		medium_value = 45000
		hard_value = 45000
		custom_value = 45000
		random_deviation = 0
		step_size = 5000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ANNUITY_MAX_GRANT
		description = "Poll annuity maximum grant"
		min_value = 45000
		max_value = 90000
		easy_value = 65000
		medium_value = 65000
		hard_value = 65000
		custom_value = 65000
		random_deviation = 0
		step_size = 5000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BANDIT_TAX_RATE
		description = "Set the Highwayman tax rate (%)"
		min_value = 0
		max_value = 50
		easy_value = 5
		medium_value = 10
		hard_value = 20
		custom_value = 5
		random_deviation = 0
		step_size = 5
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BANDIT_TAX_MIN
		description = "Set the minimum Highwayman tax amount"
		min_value = 0
		max_value = 20000
		easy_value = 5500
		medium_value = 7000
		hard_value = 10000
		custom_value = 5500
		random_deviation = 0
		step_size = 500
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ROBIN_HOOD_RATE
		description = "Set the Robin Hood grant rate (%)"
		min_value = 0
		max_value = 100
		easy_value = 20
		medium_value = 10
		hard_value = 5
		custom_value = 20
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = WELCOME_DELAY
		description = "How many months after joining a player is welcomed"
		min_value = 0
		max_value = 24
		easy_value = 2
		medium_value = 2
		hard_value = 2
		custom_value = 2
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = AGENCY_TAX_RATE_MIN
		description = "The minimum rate at which agency tax is charged"
		min_value = 0
		max_value = 25
		easy_value = 5
		medium_value = 10
		hard_value = 20
		custom_value = 5
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = AGENCY_TAX_RATE_MAX
		description = "The maximum rate at which agency tax is charged"
		min_value = 0
		max_value = 50
		easy_value = 25
		medium_value = 35
		hard_value = 45
		custom_value = 25
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ALLOW_ADMIN_FINES
		description = "Allow fines to be made by request through the admin port"
		easy_value = 0
		medium_value = 0
		hard_value = 0
		custom_value = 0
		flags = GSInfo.CONFIG_BOOLEAN | GSInfo.CONFIG_INGAME
	}
	{
		name = RATING_MEDIC
		description = "Allow the rating medic to run (keep off for large maps)"
		easy_value = 0
		medium_value = 0
		hard_value = 0
		custom_value = 0
		flags = GSInfo.CONFIG_BOOLEAN
	}
	{
		name = SUPERMARKET_SIGNS
		description = "Add supermarket signs above general stores"
		easy_value = 1
		medium_value = 1
		hard_value = 1
		custom_value = 1
		flags = GSInfo.CONFIG_BOOLEAN | GSInfo.CONFIG_INGAME
	}
	{
		name = SUPERMARKET_SIGN_MIN_DISTANCE
		description = "Minimum distance between the centre of town and a supermarket sign"
		min_value = 1
		max_value = 100
		easy_value = 5
		medium_value = 5
		hard_value = 5
		custom_value = 5
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
]

class GovGSInfo extends GSInfo
{
	function GetAuthor() { return "kcza"; }
	function GetName() { return "Her Majesty's Government"; }
	function GetDescription() { return "A socialist balancer to encourage polypolies"; }
	function GetVersion() { return VERSION; }
	function GetDate() { return "2020-12-16"; }
	function CreateInstance() { return "MultiGS"; }
	function GetShortName() { return "GVMT"; }
	function GetAPIVersion() { return "12"; }
	function GetSettings()
		for (local i = 0; i < SELF_SETTINGS.len(); i++)
		{
			local setting = SELF_SETTINGS[i];
			local labels = null;
			if ("labels" in setting)
			{
				labels = setting.labels;
				delete setting.labels;
			}
			AddSetting(setting);
			if (labels)
				AddLabels(setting.name, labels);
		}
}

RegisterGS(GovGSInfo());
