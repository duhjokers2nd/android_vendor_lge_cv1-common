#!/system/bin/sh

MCFG_ROOT_DIR="/data/shared"
MCFG_SMARTCA_DIR="/data/shared/mcfg"
MCFG_FW_MCFG_SW_DIR="/firmware/image/modem_pr/mcfg/configs/mcfg_sw"
MCFG_SMARTCA_MBN_LOG="/data/logger/smartca_mbn_update"
MCFG_MBN_MOUNT_KEY=$MCFG_ROOT_DIR'/smartca_mbn_mount_key'
MCFG_TEMP_STR_VAL=$MCFG_ROOT_DIR'/temp_str_val'
MCFG_MBN_NAME="mcfg_sw.mbn"
MCFG_MBN_SW_DIG="mbn_sw.dig"
MCFG_MBN_SW_TXT="mbn_sw.txt"
MCFG_DIR_LIMIT_LEN=8

function check_dir_name_len()
{
    if [ -d $1 ]; then
        MCFG_FILE_LIST=$(ls $1'/')
        for MCFG_FILE in ${MCFG_FILE_LIST}; do
            if [ ! $MCFG_FILE == $MCFG_MBN_NAME -a ! $MCFG_FILE == $MCFG_MBN_SW_DIG -a ! $MCFG_FILE == $MCFG_MBN_SW_TXT ]; then
                echo $MCFG_FILE | tr '[A-Z]' '[a-z]' > $MCFG_TEMP_STR_VAL
                while read line; do
                    LOWER_NAME=$line
                done < $MCFG_TEMP_STR_VAL

                if [ ! -d $1'/'$LOWER_NAME ]; then
                    mv $1'/'$MCFG_FILE $1'/'$LOWER_NAME
                    MCFG_FILE=$LOWER_NAME
                fi

                if [ ${#MCFG_FILE} -gt $MCFG_DIR_LIMIT_LEN ]; then
                    mv $1'/'$MCFG_FILE $1'/'${MCFG_FILE:0:8}
                    check_dir_name_len $1'/'${MCFG_FILE:0:8}
                else
                    check_dir_name_len $1'/'$MCFG_FILE
                fi
            fi
        done
    fi
}

if [ ! -f $MCFG_SMARTCA_MBN_LOG ]; then
    touch $MCFG_SMARTCA_MBN_LOG
    /system/bin/chown system:system $MCFG_SMARTCA_MBN_LOG
    /system/bin/chmod 644 $MCFG_SMARTCA_MBN_LOG
    echo "$(date +%m-%d) $(date +%T) M [CMD] touch $MCFG_SMARTCA_MBN_LOG" >> $MCFG_SMARTCA_MBN_LOG
fi

if [ -d $MCFG_SMARTCA_DIR ]; then
    # DG: MCFG dir path converting is proceeded at MBN build time
    # Permalink: http://lr.lge.com:8147/lap-review/#/c/647499/
    #check_dir_name_len $MCFG_SMARTCA_DIR
    #echo "$(date +%m-%d) $(date +%T) M [FNC] check_dir_name_len $MCFG_SMARTCA_DIR" >> $MCFG_SMARTCA_MBN_LOG
    #
    #if [ -f $MCFG_TEMP_STR_VAL ]; then
    #    rm -rf $MCFG_TEMP_STR_VAL
    #fi

    /system/bin/chown -R system:system $MCFG_SMARTCA_DIR'/'*
    /system/bin/chmod -R 550 $MCFG_SMARTCA_DIR'/'*
    /system/bin/chmod 440 $MCFG_SMARTCA_DIR'/mbn_sw.'*
    find $MCFG_SMARTCA_DIR -name *.mbn | xargs /system/bin/chmod 440
    echo "$(date +%m-%d) $(date +%T) M [STT] chmod and chown completed" >> $MCFG_SMARTCA_MBN_LOG
fi

if [ -d $MCFG_SMARTCA_DIR -a -f $MCFG_SMARTCA_DIR'/mbn_sw.dig' -a -f $MCFG_SMARTCA_DIR'/mbn_sw.txt' ]; then
    mount | grep $MCFG_FW_MCFG_SW_DIR > $MCFG_TEMP_STR_VAL
    while read line; do
        MCFG_MOUNT_CHECK=$line
    done < $MCFG_TEMP_STR_VAL

    if [ ${#MCFG_MOUNT_CHECK} == 0 ]; then
        mount $MCFG_SMARTCA_DIR $MCFG_FW_MCFG_SW_DIR
        echo "$(date +%m-%d) $(date +%T) M [CMD] mount $MCFG_SMARTCA_DIR $MCFG_FW_MCFG_SW_DIR" >> $MCFG_SMARTCA_MBN_LOG
    fi

    if [ -f $MCFG_TEMP_STR_VAL ]; then
        rm -rf $MCFG_TEMP_STR_VAL
    fi

    if [ ! -f $MCFG_MBN_MOUNT_KEY ]; then
        touch $MCFG_MBN_MOUNT_KEY
        echo "$(date +%m-%d) $(date +%T) M [CMD] touch $MCFG_MBN_MOUNT_KEY" >> $MCFG_SMARTCA_MBN_LOG
    fi

    am broadcast -a com.lge.android.intent.action.ACTION_CHECK_MCFG_SSR --include-stopped-packages
    echo "$(date +%m-%d) $(date +%T) M [CMD] am broadcast -a com.lge.android.intent.action.ACTION_CHECK_MCFG_SSR --include-stopped-packages" >> $MCFG_SMARTCA_MBN_LOG

    setprop persist.radio.mcfg.version mount
    echo "$(date +%m-%d) $(date +%T) M [CMD] setprop persist.radio.mcfg.version mount" >> $MCFG_SMARTCA_MBN_LOG
fi

