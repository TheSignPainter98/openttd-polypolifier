require("locations.nut");
require("module.nut");

class NewsAlerter extends Module
{
	companies = null;
	constructor(companies)
	{
		::Module.constructor()
		this.companies = companies;
	}

	function OnMonth(argv)
	{
		local month = argv[0];
		local year = argv[1];

		// Fire in a semi-random month
		GSLog.Error("Rando chcek: " + ((month * 359) % 12) + " != " + (997 * year) % 12)
		if ((month * 359) % 12 != (997 * year) % 12)
			return;

		RandomNews(month, year);
	}

	function RandomNews(month, year)
	{
		GSLog.Error("Sending everyone some random news!");

		local rand = month * 357 + year * 997;

		local news_stories = GetNewsStories(rand);
		local story_id = GSDate.GetCurrentDate() % news_stories.len();
		news_stories[story_id].MakeNews();
	}

	function GetNewsStories(rand)
	{
		local curr_date = GSDate.GetCurrentDate();
		local curr_year = GSDate.GetYear(curr_date);
		local curr_month = GSDate.GetMonth(curr_date);

		// Special cases
		if (curr_year == 2016)
			return [ NewsStory("NEWS_BREXIT") ];
		if (curr_year == 2020 && curr_month == 3)
			return [ NewsStory("NEWS_PANDEMIC") ];
		if (curr_year == 2025)
			ret.append(NewsStory("NEWS_NFTS"));

		local c_list = companies.GetInfoList();
		local rand_company = c_list[rand % c_list.len()];

		local ret = [];
		ret.append(NewsStory("NEWS_LOST_CAT"));
		ret.append(NewsStory("NEWS_BREAD_PRICES"));
		ret.append(NewsStory(GSText(GSText.NEWS_CLICK_BAIT, rand_company.id)));
		ret.append(NewsStory("NEWS_MORAL_PANIC"));
		ret.append(NewsStory("NEWS_PAGERS"));
		ret.append(NewsStory("NEWS_SUPERMARKET"));
		ret.append(NewsStory("NEWS_CLIMATE"));
		ret.append(NewsStory("NEWS_NUTJOB"));
		ret.append(NewsStory("NEWS_NO_CHRISTMAS"));
		ret.append(NewsStory("NEWS_POLICE"));
		ret.append(NewsStory("NEWS_STATUES"));
		ret.append(NewsStory("NEWS_CORRUPTION"));
		ret.append(NewsStory("NEWS_TRAFFIC"));
		ret.append(NewsStory("NEWS_ENVIRONMENTALIST"));
		ret.append(NewsStory(GSText(GSText.NEWS_RESIDENT, Locs.LARGE_CITY, GSTown.GetPopulation(Locs.LARGE_CITY))));
		ret.append(NewsStory(GSText(GSText.NEWS_HUNGER_STRIKE, Locs.LARGE_CITY)));
		ret.append(NewsStory("NEWS_SUSHI"));

		// TODO: the dead towns thing
		// TODO: the no food one
		// TODO: the no poewr one
		// TODO: the power one
		return ret;
	}
}

class NewsStory
{
	input_text = null;
	text = null;
	ref_type = null;
	ref = null;

	constructor(text, ...)
	{
		this.input_text = text;
		this.text = typeof(text) == "instance" || typeof(text) == "integer" ? text : GSText(GSText[text]);
		this.ref_type = vargc < 2 ? Locs.NR_CAPITAL : vargv[0];
		this.ref = vargc < 2 ? Locs.CAPITAL : vargv[1];
	}

	function MakeNews()
	{
		GSLog.Error("Printing news: " + input_text + ", " + text);
		GSNews.Create(GSNews.NT_GENERAL, text, GSCompany.COMPANY_INVALID, ref_type, ref);
	}
}
