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
			SendErrorResponse("Expected a json mapping from admin port, instead got a " + typeof data);
			return;
		}
		if (!data.rawin("action"))
		{
			SendErrorResponse("Expected 'action' field in admin port message object");
			return;
		}

		if (data.action != "fine")
			return;

		local id = data.company_id;
		local amt = data.amount;

		if (GSCompany.ResolveCompanyID(id) == GSCompany.COMPANY_INVALID)
		{
			SendErrorResponse("No such company: " + id);
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
			SendErrorResponse("Failed to find company with id " + id + " from maintained list!");
			return;
		}

		if (target.hq != GSMap.TILE_INVALID)
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER, target.hq);
		else if (Locs.CAPITAL != NO_CAPITAL_FOUND)
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER);
		else
			GSCompany.ChangeBankBalance(target.id, -amt, GSCompany.EXPENSES_OTHER, CAPITAL);

		return true;
	}

	function SendFineResponse()
	{
		local resp = {
			action = "response",
			error = false,
		};
		GSAdmin.Send(resp);
	}

	function SendErrorResponse(err)
	{
		GSLog.Error(err);
		local resp = {
			action = "fine_response",
			error = true,
			reason = err,
		};
		GSAdmin.Send(resp);
	}
}
