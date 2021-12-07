import sqrt from math
import max, min from require 'sims.util'
import sort from table

class Gov
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
	@make_gov_props: (overrides) =>
		ret = {}
		ret[k] = overrides[k] or v for k,v in pairs @@default_props
		ret
	new: (@companies, gov_props={}) =>
		@props = @@make_gov_props gov_props
		@pot = @props.pot_initial_content + @props.pot_company_change_boost * #@companies
	reset: => @pot = @props.pot_initial_content
	on_month: (month) =>
		return unless month >= 12
		month %= 12
		return unless month % 3 == 0
		@on_quarter 1 + (month - 1) // 3
	on_quarter: (quarter) =>
		@deduct_pot_interest!
		@bound_pot!
		@perform_bandit_tax!
		@perform_robin_hood_tax!
		@perform_agency_tax!
		@perform_annuity quarter
	deduct_pot_interest: => @pot *= 1 + @props.pot_rate if @pot < 0
	bound_pot: =>
		if @pot < @props.pot_overdraft_cap
			@pot = @props.pot_overdraft_cap
		else if @pot > @props.pot_cap
			@pot = @props.pot_cap
	perform_bandit_tax: =>
		for c in *@companies
			continue if c.has_hq
			amt = max @props.bandit_tax_min, c.value * @props.bandit_tax_rate
			@tax c, amt, 'Bandit-tax'
	perform_agency_tax: =>
		for c in *@companies
			continue unless c\active!
			@tax c, @props.agency_tax_rate * (c\profit! - @props.agency_tax_threshold)
		if @pot < 0
			tot_val = 0
			for c in *@companies
				continue unless c\active!
				tot_val += c.value
			tot_levy = -@pot * @props.agency_tax_overdraft_rate
			for c in *@companies
				continue unless c\active!
				@means_tax c, tot_levy * c.value / tot_val, 'Agency-overdraft-tax'
	perform_robin_hood_tax: =>
		return unless #@companies >= 2
		sort @companies, (c, d) -> c.value < d.value
		min_to_tax = 1 + #@companies // 2
		beneficiary = @companies[1]
		beneficiary = nil
		for i=1,min_to_tax-1
			c = @companies[i]
			if c.has_hq and c\active!
				beneficiary = c
				break
		return unless beneficiary
		grant = min @props.robin_hood_rate * beneficiary.value,
			@props.robin_hood_rate * (@companies[min_to_tax].value - beneficiary.value)
		to_tax = [ c for c in *@companies[min_to_tax,] ]
		tot_value = 0
		for c in *to_tax
			tot_value += c.value
		leviable = 0
		for c in *to_tax
			c.rh_levy = grant * c.value / tot_value
			if @can_means_tax c, c.rh_levy
				leviable += c.rh_levy
		for c in *to_tax
			@means_tax c, c.rh_levy, 'RH-levy'
		if @can_grant grant
			@grant beneficiary, grant, 'RH-grant'
	perform_annuity: (quarter) =>
		return unless quarter == 2
		ann_tot = 0
		for c in *@companies
			if c\active! and c.has_hq
				ann_tot += @props.annuity
		if @can_grant ann_tot
			for c in *@companies
				continue unless c\active! and c.has_hq
				@grant c, @props.annuity, 'Annuity'
	can_grant: (amt) => @props.pot_overdraft_cap <= @pot - amt
	can_means_tax: (company, amt) =>
		p = company\profit!
		return amt + @props.grace_margin <= p and
			p - amt <= @props.grace_proportion * p
	means_tax: (company, amt, reason) =>
		if @can_means_tax company, amt
			@tax company, amt, reason
			@pot += amt
	tax: (company, amt, reason) =>
		@pot += amt
		@pot = min @pot, @props.pot_cap
		company\taxed amt
	grant: (company, amt, reason) =>
		@pot -= amt
		company\granted amt

{ :Gov }
