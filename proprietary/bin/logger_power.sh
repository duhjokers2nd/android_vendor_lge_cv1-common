#!/system/bin/sh

source check_data_mount.sh
log_to_data_partition=`is_ext4_data_partition`
log_file="power.log"

power_log_prop=`getprop persist.service.power.enable`
#vold_prop=`getprop vold.decrypt`
#vold_propress=`getprop vold.encrypt_progress`

touch /data/logger/${log_file}
chmod 0644 /data/logger/${log_file}


storage_full_prop=`getprop persist.service.logger.full`
storage_low_prop=`getprop persist.service.logger.low`

file_size_kb=8192
file_cnt=0

if [ "$storage_full_prop" = "1" ]; then
    exit 0
fi
if [ "$storage_low_prop" = "1" ]; then
   file_size_kb=1024
fi

case "$power_log_prop" in
        6)
            file_size_kb=1024
            file_cnt=4
            ;;
        5)
            file_cnt=99
            ;;
        4)
            file_cnt=49
            ;;
        3)
            file_cnt=19
            ;;
        2)
            file_cnt=9
            ;;
        1)
            file_cnt=4
            ;;
        0)
            file_cnt=0
            ;;
        *)
            file_cnt=0
            ;;
esac

if [[ $file_cnt > 0 ]]; then
    if [[ $log_to_data_partition == 1 ]]; then
        #move_log "/data/logger/${log_file}" "/cache/encryption_log/${log_file}"

        /system/bin/power_logger -f /data/logger/${log_file} -n $file_cnt -r $file_size_kb -t 300
    else
        touch /cache/encryption_log/${log_file}
        chmod 0644 /cache/encryption_log/${log_file}
        /system/bin/power_logger -f /cache/encryption_log/${log_file} -n $file_cnt -r $file_size_kb -t 300
    fi
fi

