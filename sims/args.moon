arg_parser = with (require 'argparse')!
	\name 'run-sim'
	\description 'Simulation for the government GS tax measures'
	with \option '-C --value-conversion'
		\description 'The rate at which investment is converted into company value'
		\default 0.10
		\convert tonumber
	with \option '-D --profit-deviation'
		\description 'The proportion by which the profit each month may deviate from the value profit rate'
		\default 0.25
		\convert tonumber
	with \option '-d --duration'
		\description 'The duration of the simulation in years'
		\default 30
		\convert tonumber
	with \flag '-i --interactive'
		\description 'Add an interactive simulation'
	with \flag '-n --full-names'
		\description 'Whether to use long names or just indices in the output'
	with \option '-P --value-profit-rate'
		\description 'The rate at which company value is converted into profit each month'
		\default  0.25
		\convert tonumber
	with \option '-s --seed'
		\description 'The random seed used for each simulation'
		\default 0
		\convert tonumber
	with \option '-S --spending-cap'
		\description 'The cap on spending which companies may experience or negative for unlimited'
		\default 5000000
		\convert tonumber
	with \option '-T --spending-cap-deviation'
		\description 'The proportion by which the spending cap can deviate each month'
		\default 0.5
		\convert tonumber

{ args: arg_parser\parse! }
