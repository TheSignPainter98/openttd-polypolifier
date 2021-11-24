require("version.nut")

gs_info <- GSInfo()

/* ubi */
/* bandit_tax_rate */
/* bandit_tax_min */
/* robin_hood_basic_rate */
/* loan_monthly_rate */
/* loan_recuperation_rate */
/* loan_cap */
/* loan_cap_negative */
/* grace_epsilon */

// TODO: complete the settings!

SELF_SETTINGS <- [
	{
		name = "gov.ubi_sum"
		description = "Set the amount of money given to all companies every April"
		min_value = 0
		max_value = 50000
		easy_value = 25000
		medium_value = 15000
		hard_value = 10000
		custom_value = 25000
		random_deviation = 0
		step_size = 5000
		flags = gs_info.CONFIG_INGAME
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
			AddSetting(SELF_SETTINGS[i])
			if ("labels" in SELF_SETTINGS[i])
				AddLabels(SELF_SETTING[i].name, SELF_SETTINGS[i].labels)
		}
}

// TODO: allow settings to be used to configure this!

RegisterGS(HmrcGSInfo());
