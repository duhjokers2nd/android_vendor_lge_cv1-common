#!/system/bin/sh

MCFG_ROOT_DIR=/data/shared
MCFG_FW_MCFG_SW_DIR=/firmware/image/modem_pr/mcfg/configs/mcfg_sw
MCFG_SMARTCA_MBN_LOG="/data/logger/smartca_mbn_update"
MCFG_MBN_MOUNT_KEY=$MCFG_ROOT_DIR'/smartca_mbn_mount_key'
MCFG_TEMP_STR_VAL=$MCFG_ROOT_DIR'/temp_str_val'

if [ ! -f $MCFG_SMARTCA_MBN_LOG ]
then
    touch $MCFG_SMARTCA_MBN_LOG
    /system/bin/chown system:system $MCFG_SMARTCA_MBN_LOG
    /system/bin/chmod 644 $MCFG_SMARTCA_MBN_LOG
    echo "$(date +%m-%d) $(date +%T) U [CMD] touch $MCFG_SMARTCA_MBN_LOG" >> $MCFG_SMARTCA_MBN_LOG
fi

if [ -f $MCFG_MBN_MOUNT_KEY ]; then
    if [ -f $MCFG_MBN_MOUNT_KEY ]; then
        rm -rf $MCFG_MBN_MOUNT_KEY
        echo "$(date +%m-%d) $(date +%T) U [CMD] rm -rf $MCFG_MBN_MOUNT_KEY" >> $MCFG_SMARTCA_MBN_LOG
    fi

    mount | grep $MCFG_FW_MCFG_SW_DIR > $MCFG_TEMP_STR_VAL
    while read line; do
        MCFG_MOUNT_CHECK=$line
    done < $MCFG_TEMP_STR_VAL

    if [ ${#MCFG_MOUNT_CHECK} != 0 ]; then
        umount $MCFG_FW_MCFG_SW_DIR
        echo "$(date +%m-%d) $(date +%T) U [CMD] umount $MCFG_FW_MCFG_SW_DIR" >> $MCFG_SMARTCA_MBN_LOG

        am broadcast -a com.lge.android.intent.action.ACTION_CHECK_MCFG_SSR --include-stopped-packages
        echo "$(date +%m-%d) $(date +%T) U [CMD] am broadcast -a com.lge.android.intent.action.ACTION_CHECK_MCFG_SSR --include-stopped-packages" >> $MCFG_SMARTCA_MBN_LOG
    fi

    if [ -f $MCFG_TEMP_STR_VAL ]; then
        rm -rf $MCFG_TEMP_STR_VAL
    fi
fi
