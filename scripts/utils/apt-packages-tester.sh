#!/usr/bin/env bash

while read p; do
	if echo $p | grep -qo "Listing\.\.\.\|apt\|coreutils\|bash\|dpkg\|busybox"; then continue; fi
	apt install -y $p
	for bin in $(dpkg -L $p | grep "/usr/bin/"); do
		fname=${p}-$(date -u)-$(basename $bin).log
		timeout \
			--signal=KILL 5 \
			$bin 2> "$fname"
		if echo $? | grep -qo "134\|139"; then
			echo "Error for binary $bin, and has been stored to $fname."
		else
			echo "$bin is OK."
			rm "$fname"
		fi
		killall -9 $bin || killall -9 $(basename $bin)
	done

	# Uncommenting this line could lead into accidental system packages deletion
	# and therefore is not recommended to be enabled.
	# apt autoremove -y $p
done<<<$(apt list | cut -d"/" -f1)

