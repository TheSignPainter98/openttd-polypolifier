require("locations.nut")
require("module.nut")

class FineExecutor extends Module
{
	companies = null;

	constructor(companies)
	{
		::Module.constructor();
		this.companies = companies
	}

	function OnEvent(args)
	{
		local et = args[0];
		local ev = args[1];
		if (et != GSEvent.ET_ADMIN_PORT)
			return;
		ev = GSEventAdminPort.Convert(ev);
		OnAdminPortData(ev.GetObject());
	}

	function OnAdminPortData(data)
	{
		if (typeof(data) != "table")
		{
			SendErrorResponse(-1, "Expected a json mapping from admin port, instead got a " + typeof data);
			return;
		}
		if (!data.rawin("token"))
		{
			SendErrorResponse(-1, "Expected a token field in admin port message object");
			return;
		}
		local token = data.token;
		if (!data.rawin("action"))
		{
			SendErrorResponse(token, "Expected 'action' field in admin port message object");
			return;
		}

		if (data.action != "fine")
			return;

		if (!GetSetting(::ALLOW_ADMIN_FINES))
		{
			GSLog.Error("Fines are currently disabled in the settings.");
			return;
		}

		local name = data.company_name;
		local amt = data.amount;

		if (amt <= 0)
			return;

		if (GSCompany.ResolveCompanyID(id) == GSCompany.COMPANY_INVALID)
		{
			SendErrorResponse(token, "No such company: " + id);
			return;
		}

		local target = null;
		foreach (c in companies.GetInfoList())
			if (c.id == id)
			{
				target = c;
				break;
			}
		if (!target)
		{
			SendErrorResponse(token, "Failed to find company with id " + id + " from maintained list!");
			return;
		}

		if (target.hq != GSMap.TILE_INVALID)
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER, target.hq);
		else if (Locs.CAPITAL != NO_CAPITAL_FOUND)
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER);
		else
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER, CAPITAL);

		SendSuccResponse(token);
		return true;
	}

	function SendSuccResponse(token)
	{
		local resp = {
			action = "response",
			token = token,
			error = false,
		};
		GSAdmin.Send(resp);
	}

	function SendErrorResponse(token, err)
	{
		GSLog.Error(err);
		local resp = {
			action = "fine_response",
			token = token,
			error = true,
			reason = err,
		};
		GSAdmin.Send(resp);
	}
}
