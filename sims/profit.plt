#!/usr/bin/gnuplot

set datafile separator ","

if (interact == 0) {
	set terminal pdf size 10,5 font "OpenTTD,10"
} else {
	set terminal qt font "OpenTTD"
}
set output 'output/graph.pdf'

set title "" offset graph -0.5,0 left
set ylabel "Money (£)"
set xlabel "Month"
set style fill solid noborder

set grid ytics xtics
show grid
set bmargin 8.25

set auto x
set auto y
set lmargin 15

set style data lines
set xtics 3 left rotate by -90 left

set key autotitle columnhead
set key outside

DATA_DIR = './data/'
datasets = system('ls -1 ' . DATA_DIR)

do for [dataset in datasets] {
	data_loc = DATA_DIR.dataset
	sep_idx = strstrt(dataset, '@')
	dataset_idx = dataset[:sep_idx-1]
	dataset_name = dataset[sep_idx+1:strstrt(dataset, '.')-1]
	dataset_name = system("echo '" . dataset_name . "' | sed 's/-/ /g' | sed 's/\\<./\\u&/'")

	stats [1:1] data_loc index 0 using 1 nooutput
	num_columns_0 = STATS_columns
	stats data_loc index 1 using 4 nooutput
	num_columns_4 = STATS_columns


	set label
	set title sprintf("Simulation %s: %s (without government intervention)", dataset_idx, dataset_name)
	unset logscale y
	plot for [i=2:num_columns_0] data_loc index 0 using 1:i, \
		data_loc index 2 using 1:2 with point, \
		data_loc index 2 using 1:3 with point

	set title sprintf("Simulation %s: %s (with government intervention)", dataset_idx, dataset_name)
	unset logscale y
	plot for [i=2:num_columns_0] data_loc index 3 using 1:i, \
		data_loc index 5 using 1:2 with point, \
		data_loc index 5 using 1:3 with point

	set title sprintf("Simulation %s: %s (without government intervention) (log-scale)", dataset_idx, dataset_name)
	set logscale y
	plot for [i=2:num_columns_0] data_loc index 0 using 1:i, \
		data_loc index 2 using 1:2 with point, \
		data_loc index 2 using 1:3 with point

	set title sprintf("Simulation %s: %s (with government intervention) (log-scale)", dataset_idx, dataset_name)
	set logscale y
	plot for [i=2:num_columns_0] data_loc index 3 using 1:i, \
		data_loc index 5 using 1:2 with point, \
		data_loc index 5 using 1:3 with point

	set title sprintf("Simulation %s: %s government interventions", dataset_idx, dataset_name)
	unset logscale y
	plot for [i=2:num_columns_4] data_loc index 4 using 1:i, \
		data_loc index 5 using 1:2 with point, \
		data_loc index 5 using 1:3 with point

	set title sprintf("Simulation %s: %s government interventions (log-scale)", dataset_idx, dataset_name)
	set logscale y
	plot for [i=2:num_columns_4] data_loc index 4 using 1:i, \
		data_loc index 5 using 1:2 with point, \
		data_loc index 5 using 1:3 with point
}

if (interact == 0) {
	exit 0
}

pause 1
reread
