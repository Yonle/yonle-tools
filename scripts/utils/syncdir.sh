#!/usr/bin/env sh

symlinkall() {
	for i in $(ls -A "$2"); do
		curdir="$i"
		if [ -d "$2/$i" ]; then
			! [ -d "$1/$curdir" ] && mkdir -p $1/$curdir
			echo "$4 - Entering directory: $2/$i"
			symlinkall "$1/$i" "$2/$i" "$i" "$4 "
		else
			echo "$4 + Symlinking $2/$i"
			! [ -h "$1/$i" ] && ln -s "$2/$i" "$1/$i"
		fi
	done
}

[ -z "$1" ] && exec cat <<- EOM

	Usage: syncdir SRC <target>

	syncdir is only a small tool that used to sync
	a file from restricted path to unrestricted path. 

	This is good for a code that stored in vFat partition
	that does not has a support for storing executeable
	file or binaries, Especially for those ones who stuck
	compiling binaries.

	SRC    - Original source directory from restricted path
	target - Target path for the good/unrestricted side.

	If there's no <target> provided, The current directory will
	used to get synced directory. You may need to re-sync it if
	there's a new file from original source.

	Do not use the synced directory for git. That would lead you
	to a very big issue. Copy every files from original source
	if you're done.

	Example of usage:
	  syncdir /media/$(whoami)/usb/my-project

	* syncdir by @Yonle
	* https://github.com/Yonle/syncdir
EOM

export TDIR=$2
! [ -d $TDIR ] && mkdir -p $TDIR
cd ${TDIR:-.}
symlinkall . $1
