import read, stderr, stdout from io
import random from math
import args from require 'sims.args'
import min from require 'sims.util'
import insert from table

HQ_COST = 300
LOAN_INCREMENT = 10000
LOAN_INTEREST_RATE = 0.004074124 -- (1 + 0.05)^(1/12) - 1
LOAN_MAX = 300000
VAL_CONVERSION = 0.5
VAL_PROFIT_RATE = 0.25

class Company
	new: (@name, @initial_cash=100000, @initial_loan=initial_cash, @initial_value=1) =>
		@id = 1
		@last_investment = @initial_value / VAL_CONVERSION
		@loan_max = LOAN_MAX
		@has_hq = false
		@owe_gov = 0
		@auto_loan = true
	set_id: (@id) =>
	reset: =>
		@cash = @initial_cash
		@loan = @initial_loan
		@last_investment = @initial_value / VAL_CONVERSION
		@value = @initial_value
		@loan_max = LOAN_MAX
		@has_hq = false
		@auto_loan = true

	-- Company properties
	has_started: true
	active: => @has_started and @last_investment > 0
	profit: => @cash - @loan
	bankrupt: => @cash - @loan + @loan_max < 0

	-- Results
	status: => {
		ref: args.full_names and "#{@name}(#{@@__name}.#{@id})" or @id
		cash: @cash
		value: @value
		bankrupt: @bankrupt!
	}

	-- Special
	__tostring: =>
		if @bankrupt!
			return "#{@name}(#{@id}): FOLDED"
		"#{@name}(#{@id}): {cash=#{@cash}, value=#{@value}, loan=#{@loan}}"

	-- Innate behaviour
	earn: =>
		@earnings = VAL_PROFIT_RATE * @value
		@cash += @earnings
	deduct_loan_interest: => @cash -= @loan * LOAN_INTEREST_RATE
	loan_increment_round: (amt, up=false) => (1 + amt // LOAN_INCREMENT + (up and 1 or 0)) * LOAN_INCREMENT
	invest: (amt) =>
		investment = @get_investable amt
		@cash -= investment
		@value += VAL_CONVERSION * investment
		@last_investment = amt
	get_investable: (amt) =>
		-- Preconditions
		return 0 unless amt > 0
		return 0 unless amt < @cash - @loan + @loan_max

		-- If can't pay, take out a loan
		if @cash < amt and @auto_loan
			loan_incr = @loan_increment_round amt, true
			if loan_incr + @loan <= @loan_max
				@cash += loan_incr
				@loan += loan_incr
			else
				diff = @loan_max - @loan
				@cash += diff
				@loan += diff
		amt

	clear_loan: (amt) =>
		-- Preconditions
		return unless @loan > 0
		return unless amt > 0

		-- Clear as much of the loan as possible
		amt = min @loan, @loan_increment_round amt
		@loan -= amt

	-- Monthly actions
	square_up_with_gov: =>
		@cash -= @owe_gov
		@owe_gov = 0
	pre_month: (month) =>
	on_month: (month) =>
		{:investment, :repayment, :build_hq} = @get_actions month
		if @has_hq != build_hq
			if build_hq
				if HQ_COST <= @cash
					@cash -= HQ_COST
					@has_hq = build_hq
			else
				@has_hq = build_hq
		@invest investment
		@clear_loan repayment
	get_actions: (month) => {
		investment: @self_investment month
		repayment: @loan_repayment month
		build_hq: @build_hq month
	}

	-- Interactions with government
	granted: (amt) => @owe_gov -= amt
	taxed: (amt) => @owe_gov += amt

	-- Company behavioural properties
	self_investment: => error "Must implement self_investment!"
	loan_repayment: => error "Must implement loan_repayment!"
	build_hq: => error "Must implement build-hq!"

class Afk extends Company
	new: (@requires_hq=false, ...) => super ...
	build_hq: => @requires_hq
	self_investment: => 0
	loan_repayment: => 0
	__tostring: => super!

class Zombie extends Afk
	new: (...) => super true, ...
	reset: =>
		super!
		@auto_loan = false
	self_investment: => 1
	__tostring: => super!

class Bankrupt extends Company
	new: (@has_hq=true, ...) => super ...
	bankrupt: => true
	__tostring: => super!

class Addict extends Company
	new: (...) =>
		super ...
		@min_investment = 0.8 * random!
		@max_investment = @min_investment + (2 - @min_investment) * random!
	build_hq: => true
	self_investment: => @cash * (@min_investment + (@max_investment - @min_investment) * random!)
	loan_repayment: => 0.5 * @loan
	__tostring: => super!

class Flakey extends Addict
	participation_chance: 0.25
	on_month: (month) => super month if random! <= @participation_chance
	__tostring: => super!

class Delayed extends Addict
	start_month: 36 + 36 * random!
	pre_month: (month) => @has_started = @start_month <= month
	__tostring: => super!

class Homeless extends Addict
	build_hq: => false
	__tostring: => super!

class Interactive extends Company
	new: =>
		super!
		@actions = {}
	reset: =>
		super!
		@hq_state = false
		@afk = false
		@replay = false
		@last_action = @default_action!
		print "--- Start of interactive simulation for company #{@id} ---"
	get_actions: (month) =>
		action = @_get_actions month
		@last_action = action
		insert @actions, action
		action
	_get_actions: (month) =>
		local actions
		if not @afk and not @replay
			-- Reas user input this step
			while true
				stdout\write "Month #{month} company #{@id} cash=£#{string.format '%.0f', @cash}, loan=£#{string.format '%.0f', @loan}> "
				actions = read!
				help = actions and actions\match 'h'
				if help
					@print_action_help!
					continue

				-- Check for of afk of replaying previous actions
				@afk = actions == nil or actions\match '^%s*$'
				stdout\write '\n' if actions == nil
				if actions and actions\match '^%s*R%s*$'
					if month == 1
						@replay = true
					else
						stderr\write "Cannot initiate replays!\n"
						continue
				break
		if @afk
			return @default_action!
		if @replay
			return @actions[month] or @actions[#@actions]
		else if month > 1
			@actions = { @last_action }

		return @last_action if actions\match '^%s*.%s*$'
		actions = actions\gsub ',', ''

		if actions\match 'HQ'
			@hq_state = true
		{
			investment: (tonumber actions\match 'i%s*(%d*)') or 0
			repayment: (tonumber actions\match 'r%s*(%d*)') or 0
			build_hq: @hq_state
		}
	default_action: => {
			investment: 0
			repayment: 0
			build_hq: @hq_state
		}
	print_action_help: =>
		print ""
		print "If the input format contains (commas ignored):"
		print "\tR on month 1"
		print "\t\treplay the previous run of actions of this company"
		print "\ti followed by a number"
		print "\t\tself-invest that much currency"
		print "\t\teg. 'i 100,000' or 'i100,000' would try to self-invest £100,000"
		print "\tr followed by a number"
		print "\t\trepay that much loan"
		print "\t\teg. 'r 10,000' or 'r10,000' would try to pay off £10,000 of loan"
		print "\tHQ\tbuild headquarters if not already build"
		print "\th\tdisplay this help message"
		print "\t.\tthe company repeats its last action"
		print "At an EOF, the company performs no further actions"
		print ""

{
	:Addict
	:Afk
	:Bankrupt
	:Delayed
	:Flakey
	:Homeless
	:Interactive
	:Zombie
}
