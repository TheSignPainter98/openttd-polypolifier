arg_parser = with (require 'argparse')!
	\name 'run-sim'
	\description 'Simulation for the government GS tax measures'
	with \option '-d --duration'
		\description 'The duration of the simulation in years'
		\default 25
	with \flag '-i --interactive'
		\description 'Add an interactive simulation'
	with \flag '-n --full-names'
		\description 'Whether to use long names or just indices in the output'
	with \option '-s --seed'
		\description 'The random seed used for each simulation'
		\default 0

{ args: arg_parser\parse! }
