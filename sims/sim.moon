#!/usr/bin/moon

import open, stderr from io
import format from string
import concat, insert from table
import randomseed from math
import args from require 'sims.args'
import debug from require 'sims.log'
import Afk, Zombie, Delayed, Flakey, Interactive, Addict from require 'sims.companies'
import Gov from require 'sims.gov'
import pexists from require 'sims.util'

DATA_DIR = 'data'

names = { 'RED', 'BLU', 'Xyferries', 'kczaRide', 'Bucket-Bus', 'ChomanderCorp.', 'LegitTrains', 'Sugondese' }
names = { 'Xyferries', 'kczaRide', 'Bucket-Bus', 'ChomanderCorp.', 'LegitTrains', 'Sugondese' }

class Simulation
	new: (@name, @companies, @seed=args.seed) =>
		@gov = Gov @companies
		id = 1
		for c in *@companies
			c\set_id id
			id += 1
	execute: (years) =>
		@results = {
			gov: @run_sim years, true
			no_gov: @run_sim years, false
		}
	run_sim: (years, sim_gov) =>
		c\reset! for c in *@companies
		@gov\reset!

		randomseed @seed
		ret = { @curr_month_result! }
		for month = 1, 12 * years - 1
			all_bankrupt = @run_sim_month month, sim_gov
			ret[month+1] = @curr_month_result!
			break if all_bankrupt
		ret
	curr_month_result: =>
		result = {}
		insert result, company\status! for company in *@companies
		result
	run_sim_month: (month, sim_gov) =>
		all_bankrupt = true
		@gov\on_month month if sim_gov
		for company in *@companies
			if not company\bankrupt!
				all_bankrupt = false
				if company.has_started
					company\earn!
					company\square_up_with_gov!
					company\deduct_loan_interest!
					company\on_month month
		all_bankrupt
	output: (sim_num) =>
		f = open "#{DATA_DIR}/#{format '%02d', sim_num}@#{@name}.csv", 'w+'
		@output_sim_result f, @results.no_gov
		f\write '\n\n'
		@output_sim_result f, @results.gov
		f\close!
	output_sim_result: (f, sim_result) =>
		@output_fields f, sim_result, { 'cash', 'value' }
		f\write '\n\n'
		@output_fields f, sim_result, { 'granted', 'taxed' }

		f\write '\n\n'
		f\write @fmt_record { 'month', 'value-at-bankruptcy', 'cash-at-bankruptcy', 'company' }

		bankrupted = {}
		for month = 1, #sim_result
			for company in *sim_result[month]
				continue unless company.bankrupt
				continue if bankrupted[company.ref]
				bankrupted[company.ref] = true
				f\write @fmt_record { month - 1, company.value, company.cash, company.ref }
	output_fields: (f, sim_result, fields) =>
		-- Write the header
		head = { 'month' }
		insert head, "#{field}-#{cstat.ref}" for field in *fields for cstat in *sim_result[1]
		f\write @fmt_record head

		-- Write the data
		for month = 1, #sim_result
			record = { month }
			for cstat in *sim_result[month]
				for f in *fields
					insert record, cstat.bankrupt and '' or cstat[f]
			f\write @fmt_record record
	fmt_record: (rec) => (concat rec, ',') .. '\n'

sims = {
	Simulation 'all-AFK-with-and-without-HQ', [ Afk i <= #names // 2, names[i] for i=1,#names ]
	Simulation 'all-AFK-without-HQ', [ Afk false, names[i] for i=1,#names ]
	Simulation 'some-AFK-some-zombie', [ i <= #names / 2 and (Zombie names[i]) or Afk true, names[i] for i=1,#names ]
	Simulation 'all-addicted', [ Addict name for name in *names ]
	Simulation 'all-zombie', [ Zombie name for name in *names ]
	Simulation 'all-addicted-but-1-flakey', [ i <= 1 and (Flakey names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-addicted-but-2-flakey', [ i <= 2 and (Flakey names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-addicted-but-1-delayed', [ i <= 1 and (Delayed names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-addicted-but-2-delayed', [ i <= 2 and (Delayed names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-addicted-but-1-zombie', [ i <= 1 and (Zombie names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-addicted-but-2-zombie', [ i <= 2 and (Zombie names[i]) or Addict names[i] for i=1,#names ]
	Simulation 'all-flakey-but-1-addicted', [ i <= 1 and (Addict names[i]) or Flakey names[i] for i=1,#names ]
	Simulation 'all-flakey-but-2-addicted', [ i <= 2 and (Addict names[i]) or Flakey names[i] for i=1,#names ]
}
insert sims, Simulation 'interactive', { Interactive 'player' } if args.interactive

for i=1,#sims
	with sims[i]
		\execute args.duration
		\output i
