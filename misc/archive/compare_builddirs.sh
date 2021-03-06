#!/bin/sh
# --- T2-COPYRIGHT-NOTE-BEGIN ---
# This copyright note is auto-generated by ./scripts/Create-CopyPatch.
# 
# T2 SDE: misc/archive/compare_builddirs.sh
# Copyright (C) 2005 The T2 SDE Project
# 
# More information can be found in the files COPYING and README.
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License. A copy of the
# GNU General Public License can be found in the file COPYING.
# --- T2-COPYRIGHT-NOTE-END ---

config=trunk
if [ "$1" = -cfg ]; then
	config="$2"
fi

compare_builddirs() {
	local config="$1" dir0="${2%/}" dir1="${3%/}"
	local cfgid0="${dir0#build/}" cfgid1="${dir1#build/}"
	local cfg0= cfg1=
	echo "compare: $cfgid0 vs. $cfgid1"

	# config dir
	if grep -q "^export SDECFG_ID='$cfgid0'" config/$config/config; then
		cfg0="config/$config"
	elif [ -f "$dir0/etc/ROCK-CONFIG/packages" ]; then
		cfg0="$dir0/etc/ROCK-CONFIG"
	elif [ -f "$dir0/etc/SDE-CONFIG/packages" ]; then
		cfg0="$dir0/etc/SDE-CONFIG"
	else
		echo "Unable to detect '$dir0' config."
	fi
	if grep -q "^export SDECFG_ID='$cfgid1'" config/$config/config; then
		cfg1="config/$config"
	elif [ -f "$dir1/etc/ROCK-CONFIG/packages" ]; then
		cfg1="$dir1/etc/ROCK-CONFIG"
	elif [ -f "$dir1/etc/SDE-CONFIG/packages" ]; then
		cfg1="$dir1/etc/SDE-CONFIG"
	else
		echo "Unable to detect '$dir1' config."
	fi

	[ -n "$cfg0" -a -n "$cfg1" ] || exit 1
	
	# package list
	#diff -U1 "$cfg0/packages" "$cfg1/packages"

	# dir0 vs dir1
	for flist in "$dir0/var/adm/flists/"*; do
		pkg="${flist#$dir0/var/adm/flists/}"
		if [ -f "$dir1/var/adm/flists/$pkg" ]; then
			diff -U1 "$flist" "$dir1/var/adm/flists/$pkg"
		else
			echo "missing '$pkg' at '$cfgid1'"
		fi
	done
	for flist in "$dir1/var/adm/flists/"*; do
		pkg="${flist#$dir1/var/adm/flists/}"
		if [ ! -f "$dir0/var/adm/flists/$pkg" ]; then
			echo "missing '$pkg' at '$cfgid0'"
		fi
	done
}

bd0= bd1=
find build/$config-*/ -maxdepth 0 -type d 2> /dev/null | while read -r builddir; do
	if [ -z "$bd0" ]; then
		# first builddir
		bd0="$builddir"
	elif [ -z "$bd1" ]; then
		# second builddir
		bd1="$builddir"
	else
		# third or another builddir, rotate
		bd0="$bd1"
		bd1="$builddir"
	fi

	if [ -n "$bd0" -a -n "$bd1" ]; then
		compare_builddirs "$config" "$bd0" "$bd1"
	fi
done
