import sqrt from math
import max, min from require 'sims.util'
import sort from table

class Gov
	new: (@companies, gov_props={}) =>
		@props = {}
		@props[k] = gov_props[k] or v for k,v in pairs @@default_props
		@collected = 0
	reset: =>
		@collected = 0

	-- Periodical actions
	on_month: (month) =>
		return unless month >= 12
		month %= 12
		return unless month % 3 == 0
		@on_quarter 1 + (month - 1) // 3
	on_quarter: (quarter) =>
		@perform_bandit_tax!
		@perform_robin_hood_tax!
		@perform_annuity quarter

	perform_bandit_tax: =>
		-- Tax all companies without an HQ
		for c in *@companies
			continue unless c.has_started and not c.has_hq
			amt = max @props.bandit_tax_min, c.value * @props.bandit_tax_rate
			@tax c, amt, 'Bandit-tax'

	perform_robin_hood_tax: =>
		return unless #@companies >= 2

		-- Get beneficiaries and those to tax
		sorted_companies = [ c for c in *@companies ]
		sort sorted_companies, (c, d) -> c.value < d.value
		min_to_tax = 1 + #sorted_companies // 2
		beneficiary = nil
		for c in *sorted_companies
			if c.has_started and c.has_hq and c\active!
				beneficiary = c
				break
		return unless beneficiary
		to_tax = [ c for c in *sorted_companies[min_to_tax,] when c.has_started and c != beneficiary ]
		return unless #to_tax >= 1

		-- Compute grant
		grant = min @props.robin_hood_rate * beneficiary.value,
			@props.robin_hood_rate * (sorted_companies[min_to_tax].value - beneficiary.value)

		-- Get value of taxables
		tot_value = @get_total_value to_tax

		-- Weighted-tax by value and grant remainder
		@tax c, grant * c.value / tot_value, 'RH-levy' for c in *to_tax
		@grant beneficiary, grant, 'RH-grant'

	perform_annuity: (quarter) =>
		if quarter == 2
			-- Redistribute wealth
			tot_grant_max = 0

			for c in *@companies
				continue unless c.has_started and c\active! and c.has_hq
				@collected += 10000
				c.grant_max = @get_annuity_grant_cap c
				tot_grant_max += c.grant_max
			for c in *@companies
				continue unless c.has_started and c\active! and c.has_hq
				@grant c, (min c.grant_max, @collected * c.grant_max / tot_grant_max), 'annuity'
			@collected = 0 -- Rest taken by gov't, but more taken from more valuable companies.
		else
			-- Collect wealth
			tot_value = @get_total_value @companies, => @active!
			for c in *@companies
				continue unless c\active!
				levy = (0.01 + (0.05 - 0.01) * c.value / tot_value) * c.earnings
				@collected += levy
				@tax c, levy, 'annuity-tax'

	get_annuity_grant_cap: (company) =>
		if company.value <= 100000
			20000
		else if company.value <= 200000
			30000
		else if company.value <= 400000
			45000
		else
			65000

	get_total_value: (companies, p=(c)->true) =>
		tot_value = 0
		tot_value += c.value for c in *companies when p c
		tot_value

	-- Intaractions with companies
	tax: (company, amt, reason) => company\taxed amt
	grant: (company, amt, reason) => company\granted amt

	-- Defaults
	@default_props:
		annuity: 100000
		bandit_tax_rate: .05
		bandit_tax_min: 5500
		robin_hood_rate: .10
		agency_tax_threshold: 50000
		agency_tax_rate: 0.01
		agency_tax_overdraft_rate: .20
		pot_initial_content: 400000
		pot_company_change_boost: 100000
		pot_rate: -1 + sqrt sqrt 1 + .05
		pot_cap: 10000000
		pot_overdraft_cap: 1000000 * -1
		grace_margin: 50000
		grace_proportion: .75

{ :Gov }
