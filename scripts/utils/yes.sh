#!/usr/bin/env sh

while true; do
	echo ${@:-y}
	! [ -z $INT ] && sleep $INT
done
