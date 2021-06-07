#!/system/bin/sh
# This script installs apks in /system/uninstallable directory
# when the phone is first booted after the factory reset.
#
# Apks installed via this script can be uninstalled by user.
# However, uninstallation does not remove an apk from the system image.
# Furthermore, the apks are again installed after a factory reset.
#
# Apks listed in the config file /cust/config/appmanager.cfg won't
# be neither installed or managed by Application Manager.

LAST_BUILD_INCREMENTAL=`getprop persist.lge.appbox.ntcode 0`
CURRENT_BUILD_INCREMENTAL=`getprop ro.build.version.incremental NODEF`
if [[ "$LAST_BUILD_INCREMENTAL" == "$CURRENT_BUILD_INCREMENTAL" ]]; then
    exit 0;
fi

CUST=`getprop ro.lge.capp_cupss.rootdir /cust`   #/cust/VDF_COM
CONF=${CUST}/config
DATA_SYSTEM=/data/app-system
APPPATH=${CUST}/apps

if [ -f $CONF/ntcode_list_${NTCODE}.cfg ]; then
    for apk1 in $(cat $CONF/ntcode_list_${NTCODE}.cfg); do
        `cat ${APPPATH}/${apk1} > ${DATA_SYSTEM}/${apk1}`
        chown system:system ${DATA_SYSTEM}/${apk1}
        chmod 644 ${DATA_SYSTEM}/${apk1}
    done
elif [ -f $CONF/ntcode_list_FFF.cfg ]; then
    for apk2 in $(cat $CONF/ntcode_list_FFF.cfg); do
        `cat ${APPPATH}/${apk2} > ${DATA_SYSTEM}/${apk2}`
        chown system:system ${DATA_SYSTEM}/${apk2}
        chmod 644 ${DATA_SYSTEM}/${apk2}
    done
fi

if [ -f $CONF/errc_list.cfg ]; then
    for module in $(cat $CONF/errc_list.cfg); do

        ERRC_TYPE=${module#*,}
        module=${module%%,*}

        rm -rf ${DATA_SYSTEM}/${module}
        rm -rf ${DATA_SYSTEM}/${module}.apk
        rm -rf ${DATA_SYSTEM}/${module}-*
        rm -rf ${DATA_SYSTEM}/${module}-*.apk

        if [ "$ERRC_TYPE" != "system" ]; then
            rm -rf /data/app/${module}
            rm -rf /data/app/${module}.apk
            rm -rf /data/app/${module}-*
            rm -rf /data/app/${module}-*.apk

            rm -rf ${APPPATH}/${module}
            rm -rf ${APPPATH}/${module}.apk
        fi
    done
fi

setprop persist.lge.appbox.ntcode ${CURRENT_BUILD_INCREMENTAL}

exit 0