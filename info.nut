require("version.nut")
require("setting_names.nut")

SELF_SETTINGS <- [
	{
		name = ANNUITY
		description = "Set the annuity gifted to each company every April"
		min_value = 0
		max_value = 50000
		easy_value = 20000
		medium_value = 15000
		hard_value = 10000
		custom_value = 20000
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
		name = POT_INITIAL_CONTENT
		description = "The amount initially in the government's pot"
		min_value = 0
		max_value = 1000000
		easy_value = 400000
		medium_value = 200000
		hard_value = 0
		custom_value = 400000
		step_size = 50000
		flags = GSInfo.CONFIG_NONE
	}
	{
		name = POT_COMPANY_CHANGE_BOOST
		description = "The pot change when a company is created or removed"
		min_value = 0
		max_value = 200000
		easy_value = 100000
		medium_value = 50000
		hard_value = 0
		custom_value = 100000
		step_size = 25000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = POT_RATE
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
		name = POT_CAP
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
		name = POT_OVERDRAFT_CAP
		description = "The limit on the overdraft available to the government"
		min_value = 100000
		max_value = 10000000
		easy_value = 1000000
		medium_value = 250000
		hard_value = 100000
		custom_value = 1000000
		random_deviation = 0
		step_size = 50000
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
	{
		name = GRACE_PROPORTION
		description = "The proportion of profits which must remain when executing a means-tested tax",
		min_value = 0
		max_value = 100
		easy_value = 75
		medium_value = 50
		hard_value = 25
		custom_value = 75
		random_deviation = 0
		step_size = 5
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
		name = AGENCY_TAX_THRESHOLD
		description = "The profit not taken into account by the agency tax"
		min_value = 0
		max_value = 100000
		easy_value = 50000
		medium_value = 30000
		hard_value = 10000
		custom_value = 50000
		random_deviation = 0
		step_size = 10000
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = AGENCY_TAX_RATE
		description = "The rate at which agency tax is charged"
		min_value = 0
		max_value = 25
		easy_value = 1
		medium_value = 10
		hard_value = 20
		custom_value = 1
		random_deviation = 0
		step_size = 1
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = AGENCY_TAX_OVERDRAFT_RATE
		description = "The proportion of overdraft the agency tax can attempt to clear"
		min_value = 5
		max_value = 50
		easy_value = 20
		medium_value = 30
		hard_value = 40
		custom_value = 20
		random_deviation = 0
		step_size = 5
		flags = GSInfo.CONFIG_INGAME
	}
	{
		name = ALLOW_ADMIN_FINES
		description = "Allow fines to be made by request through the admin port"
		easy_value = 0
		medium_value = 0
		hard_value = 0
		custom_value = 0
		flags = GSInfo.CONFIG_BOOLEAN
	}
	// TODO: add initial delay / start date
]

class GovGSInfo extends GSInfo
{
	function GetAuthor() { return "kcza"; }
	function GetName() { return "Her Majesty's Government"; }
	function GetDescription() { return "A socialist balancer to encourage polypolies"; }
	function GetVersion() { return VERSION; }
	function GetDate() { return "1900-01-01"; }
	function CreateInstance() { return "MultiGS"; }
	function GetShortName() { return "GVMT"; }
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

RegisterGS(GovGSInfo());
