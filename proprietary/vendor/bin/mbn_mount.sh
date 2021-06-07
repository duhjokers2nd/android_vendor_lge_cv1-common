#!/system/bin/sh

MCFG_ROOT_DIR=/data/shared
MCFG_SMARTCA_DIR=/data/shared/mcfg
MCFG_FW_MCFG_SW_DIR=/firmware/image/modem_pr/mcfg/configs/mcfg_sw
MCFG_SMARTCA_MBN_LOG="/data/logger/smartca_mbn_update"
MCFG_MBN_MOUNT_KEY=$MCFG_ROOT_DIR'/smartca_mbn_mount_key'

if [ -f $MCFG_MBN_MOUNT_KEY ]; then
    if [ ! -f $MCFG_SMARTCA_MBN_LOG ]; then
        touch $MCFG_SMARTCA_MBN_LOG
        /system/bin/chown system:system $MCFG_SMARTCA_MBN_LOG
        /system/bin/chmod 644 $MCFG_SMARTCA_MBN_LOG
    fi

    if [ -d $MCFG_SMARTCA_DIR -a -f $MCFG_SMARTCA_DIR'/mbn_sw.dig' -a -f $MCFG_SMARTCA_DIR'/mbn_sw.txt' ]; then
        mount $MCFG_SMARTCA_DIR $MCFG_FW_MCFG_SW_DIR
        echo "$(date +%m-%d) $(date +%T) B [CMD] mount $MCFG_SMARTCA_DIR $MCFG_FW_MCFG_SW_DIR" >> $MCFG_SMARTCA_MBN_LOG
    else
        echo "$(date +%m-%d) $(date +%T) B [ERR] There is no $MCFG_SMARTCA_DIR" >> $MCFG_SMARTCA_MBN_LOG
    fi
fi
