# Simulations

This section of the project is about modelling OpenTTD and the balance changes made by this game-script to check things probably work as intended.

## Table of contents

<!-- vim-markdown-toc GFM -->

* [How to run](#how-to-run)
* [Requirements](#requirements)
* [Modelling OpenTTD](#modelling-openttd)

<!-- vim-markdown-toc -->

## How to run

Simulations can be run by executing `./run-sim` from the project root.
See type `./run-sim -h` for more information.

There is an experimental interactive simulation mode which can be accessed with the `-i` flag.
Interactive simulation is fine, interactive visualisation is the experimental part.

## Requirements

_Please note: This thing probably only runs on Linux._

To run the simulations, you will need installed:

- [gnuplot](http://www.gnuplot.info)
- [moonscript](https://moonscript.org)

## Modelling OpenTTD

The model works as follows.

1. Companies are independent of one-another.
2. OpenTTD is played as a sequence of monthly actions.
3. The _value, bank balance_ and whether a company has built an HQ are tracked.
4. Every month, each company:
	1. Has an interaction with the government game-script
	2. Has its earnings added to its bank balance,
	3. Has loan interest deducted,
	4. Performs some action, which consists of:
		- Investing an amount of money in itself (loan is transparent)
		- Clearing some of its loan
		- Building an HQ.
5. If a company chooses to invest _x_ money in itself, then its value is increased by _x/2_.
6. The monthly earnings of a company is equal to one quarter of its value.
