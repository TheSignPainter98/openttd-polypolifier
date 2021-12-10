#!/bin/bash

set -e

git log --pretty=format:%s\
	| grep -v '^Merge'\
	| grep -v '^Initial commit$'\
	| sed 's/^/- /'
