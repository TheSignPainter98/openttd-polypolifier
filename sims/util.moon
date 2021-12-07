import maxinteger, mininteger from math
import open from io

util = {}

util.max = (...) ->
	m = mininteger
	n = select '#', ...
	for i=1,n
		a = select i, ...
		if m < a
			m = a
	m

util.min = (...) ->
	m = maxinteger
	n = select '#', ...
	for i=1,n
		a = select i, ...
		if a < m
			m = a
	m

util.pexists = =>
	f = open @, 'r'
	r = f and true or false
	f\close! if f
	r

util
