#!/system/bin/sh

USER_APP_EXTERNAL_JAR=/data/local/etc
COTA_EXTERNAL_JAR=/data/shared/lib

if [ ! -d ${USER_APP_EXTERNAL_JAR} ]; then
        mkdir ${USER_APP_EXTERNAL_JAR}
       /system/bin/chmod 755 ${USER_APP_EXTERNAL_JAR}
fi

if [ -d $COTA_EXTERNAL_JAR ]; then
        COTAFILELIST=$(ls $COTA_EXTERNAL_JAR)
        for COTAALLFILE in ${COTAFILELIST}; do
            if [ -f $COTA_EXTERNAL_JAR/${COTAALLFILE} ]; then
                cp -f $COTA_EXTERNAL_JAR/${COTAALLFILE} $USER_APP_EXTERNAL_JAR/${COTAALLFILE}
            fi
        done
fi

setprop persist.sys.cota.file.copied 0

exit 0
