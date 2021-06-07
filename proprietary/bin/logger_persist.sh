#!/system/bin/sh

buffers=""
rotate_size=""
rotate_count=""

source check_data_mount.sh
log_to_data_partition=`is_ext4_data_partition`

function check_buffer() {
    name=$1
    log_file="${name}.log"
    if [[ "$name" == "crash" ]]; then
        log_prop=`getprop persist.service.system.enable`
    else
        log_prop=`getprop persist.service.${name}.enable`
    fi
    log_size_prop=`getprop persist.service.logsize.setting`
    #vold_prop=`getprop vold.decrypt`
    #vold_propress=`getprop vold.encrypt_progress`

    storage_full_prop=`getprop persist.service.logger.full`
    storage_low_prop=`getprop persist.service.logger.low`

    if [[ "$name" == "radio" ]]; then
        file_size_kb=16376
    else
        file_size_kb=8192
    fi

    file_cnt=0

    if [[ $log_size_prop > 0 ]]; then
        file_size_kb=$log_size_prop
    fi

    if [ "$storage_full_prop" = "1" ]; then
        exit 0
    fi
    if [ "$storage_low_prop" = "1" ]; then
        file_size_kb=1024
    fi

    touch /data/logger/${log_file}
    chmod 0644 /data/logger/${log_file}

    case "$log_prop" in
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
        global buffers="${buffers} -b ${name}"
        if [[ "$rotate_size" == "" ]]; then
            global rotate_size=$file_size_kb
        else
            global rotate_size="${rotate_size},$file_size_kb"
        fi
        if [[ "$rotate_count" == "" ]]; then
            global rotate_count="$file_cnt"
        else
            global rotate_count="${rotate_count},$file_cnt"
        fi
    fi
}

check_buffer main
check_buffer system
check_buffer crash
check_buffer events
check_buffer radio

if [[ $buffers != "" ]]; then
    if [[ $log_to_data_partition == 1 ]]; then
        #move_log "/data/logger/${log_file}" "/cache/encryption_log/${log_file}"

        /system/bin/logcat -v threadtime ${buffers} -f /data/logger/${log_file} -n $rotate_count -r $rotate_size --separate
    else
        touch /cache/encryption_log/${log_file}
        chmod 0644 /cache/encryption_log/${log_file}
        /system/bin/logcat -v threadtime ${buffers} -f /cache/encryption_log/${log_file} -n $rotate_count -r $rotate_size --separate
    fi
fi

