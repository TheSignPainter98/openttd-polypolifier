require("version.nut")
require("setting_names.nut")

SELF_SETTINGS <- [
	{
		name = ANNUITY
		description = "Set the annuity gifted to each company every April"
		min_value = 0
		max_value = 50000
		easy_value = 25000
		medium_value = 15000
		hard_value = 10000
		custom_value = 25000
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
		easy_value = 10
		medium_value = 5
		hard_value = 3
		custom_value = 10
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BOE_POT_RATE
		description = "The overdraft interest rate of the pot (%)"
		min_value = 0
		max_value = 30
		easy_value = 5
		medium_value = 7
		hard_value = 10
		custom_value = 5
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BOE_POT_RECUPERATION_RATE
		description = "The increase in the robin hood levy used to reduce overdraft in the pot (%) "
		min_value = 0
		max_value = 100
		easy_value = 30
		medium_value = 40
		hard_value = 50
		custom_value = 30
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BOE_POT_CAP
		description = "The upper limit on the amount of money which the government can store"
		min_value = 0
		max_value = 20000000
		easy_value = 10000000
		medium_value = 2000000
		hard_value = 0
		custom_value = 10000000
		random_deviation = 0
		step_size = 500000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = BOE_POT_OVERDRAFT_CAP
		description = "The limit on the overdraft available to the government"
		min_value = 100000
		max_value = 10000000
		easy_value = 5000000
		medium_value = 2500000
		hard_value = 1000000
		custom_value = 5000000
		random_deviation = 0
		step_size = 500000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = GRACE_MARGIN
		description = "The margin afforded to companies who can only just pay their Robin Hood levy"
		min_value = 20000
		max_value = 100000
		easy_value = 50000
		medium_value = 40000
		hard_value = 30000
		custom_value = 50000
		random_deviation = 0
		step_size = 10000
		flags = GSInfo.CONFIG_INGAME
	}
]

class HmrcGSInfo extends GSInfo
{
	function GetAuthor() { return "kcza"; }
	function GetName() { return "Her Majesty's Revenue and Customs"; }
	function GetDescription() { return "A socialist balancer to encourage polypolies"; }
	function GetVersion() { return VERSION; }
	function GetDate() { return "1900-01-01"; }
	function CreateInstance() { return "HmrcGS"; }
	function GetShortName() { return "HMRC"; }
	function GetAPIVersion() { return "1.9"; }
	function GetSettings()
		for (local i = 0; i < SELF_SETTINGS.len(); i++)
		{
			local setting = SELF_SETTINGS[i]
			local labels = null
			if ("labels" in setting)
			{
				labels = setting.labels
				delete setting.labels
			}
			AddSetting(setting)
			if (labels)
				AddLabels(setting.name, labels)
		}
}

RegisterGS(HmrcGSInfo());
