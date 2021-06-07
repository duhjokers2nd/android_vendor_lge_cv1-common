#!/system/bin/sh
local count=0
local utime
local ktime
local fg_file_size
# size 1 = 512byte, 409600 is 200Mbyte
local fg_log_max_size=409600
local pause_time=10

fg_prop=`getprop persist.service.fg.enable`

if [ -n "$1" ]; then
    pause_time=$1
fi
dump_peripheral () {
    local base=$1
    local size=$2
    local dump_path=$3
    echo $base > $dump_path/address
    echo $size > $dump_path/count
    cat $dump_path/data
}

fg_dumper() {
    echo DATE: $(date)
    echo "Starting dumps!"
    echo "Dump path = $dump_path, pause time = $pause_time"
    echo "SRAM and SPMI Dump"
    dump_peripheral 0x0 0x400 "/sys/kernel/debug/fg_memif"
    while true
    do
	if [ $(( $count % 5 )) -eq 5 ]; then
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "Charger Dump Started at ${ktime}"
	    dump_peripheral 0x21000 0x700 "/sys/kernel/debug/spmi/spmi-0"
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "Charger Dump done at ${ktime}"
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "FG Dump Started at ${ktime}"
	    dump_peripheral 0x24000 0x700 "/sys/kernel/debug/spmi/spmi-0"
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "FG Dump done at ${ktime}"
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "PS Capture Started at ${ktime}"
	    cat /sys/class/power_supply/bms/uevent
	    cat /sys/class/power_supply/battery/uevent
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "PS Capture done at ${ktime}"
	else
	    utime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "SRAM Dump Started at ${ktime}"
	    dump_peripheral 0x400 0x200 "/sys/kernel/debug/fg_memif"
	    uptime=($(cat /proc/uptime))
	    ktime=${utime[0]}
	    echo "SRAM Dump done at ${ktime}"
	fi
	fg_file_size="`ls -s /data/logger/fg.log | awk '{print $1}'`"
	if [ $fg_file_size -ge $fg_log_max_size ]; then
		echo "delete fg log beause of over size!!! = $fg_file_size"
		rm -f /data/logger/fg.log
	fi
	sleep $pause_time
	let count=$count+1
    done
}
if [ "$fg_prop" == "1" ] || [ "$fg_prop" == "2" ] || [ "$fg_prop" == "3" ] || [ "$fg_prop" == "4" ] || [ "$fg_prop" == "5" ]; then
if [ -n "$2" ]
then
    touch $2
    chmod -h 644 $2
    fg_dumper >> "$2"
else
    fg_dumper
fi
fi
