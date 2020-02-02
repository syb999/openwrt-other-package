#!/bin/sh /etc/rc.common


device=$(uci get samba.@samba[0].device)
chmod_mask=$(uci get samba.@samba[0].chmod_mask)
chmod_files=$(uci get samba.@samba[0].chmod_files)

if [ $chmod_files = "true" ]; then
	p="-R"
else
	p=""
fi

chmod $p $chmod_mask $device
