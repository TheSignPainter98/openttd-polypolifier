#!/usr/bin/gnuplot

set datafile separator ","

if (interact == 0) {
	set terminal pdf size 10,5 font "OpenTTD,10"
} else {
	set terminal qt font "OpenTTD"
}
set output 'output/graph.pdf'

set xlabel "Month"
set style fill solid noborder

set grid ytics xtics
show grid
set bmargin 8.25

set auto x
set auto y

set style data lines
set xtics 3 left rotate by -90 left

set key autotitle columnhead
set key outside

DATA_DIR = './data/'
datasets = system('ls -1 ' . DATA_DIR)

do for [dataset in datasets] {
	data_loc = DATA_DIR.dataset

	stats [1:1] data_loc index 0 using 1 nooutput
	num_columns = STATS_columns

	set title sprintf("Dataset '%s' without government intervention", dataset)
	unset logscale y
	plot for [i=2:num_columns] data_loc index 0 using 1:i, \
		data_loc index 1 using 1:2 with point, \
		data_loc index 1 using 1:3 with point

	set title sprintf("Dataset '%s' with government intervention", dataset)
	unset logscale y
	plot for [i=2:num_columns] data_loc index 2 using 1:i, \
		data_loc index 3 using 1:2 with point, \
		data_loc index 3 using 1:3 with point

	set title sprintf("Dataset '%s' without government intervention (log-scale)", dataset)
	set logscale y
	plot for [i=2:num_columns] data_loc index 0 using 1:i, \
		data_loc index 1 using 1:2 with point, \
		data_loc index 1 using 1:3 with point

	set title sprintf("Dataset '%s' with government intervention (log-scale)", dataset)
	set logscale y
	plot for [i=2:num_columns] data_loc index 2 using 1:i, \
		data_loc index 3 using 1:2 with point, \
		data_loc index 3 using 1:3 with point
}

if (interact == 0) {
	exit 0
}

pause 1
reread
