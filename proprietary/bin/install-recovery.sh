#!/system/bin/sh
#// LGE_UPDATE_S DMS_SYSTEM_GOTA dms-fota@lge.com 2016/03/23
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:17822936:05629e7651f13211262a0a6225dd6ad94977d655; then
	if applypatch -b /system/etc/recovery-resource.dat EMMC:/dev/block/bootdevice/by-name/boot:15588564:84e2c59887d04686c2d6291fd4e3a89ba369a1c7 EMMC:/dev/block/bootdevice/by-name/recovery 05629e7651f13211262a0a6225dd6ad94977d655 17822936 84e2c59887d04686c2d6291fd4e3a89ba369a1c7:/system/recovery-from-boot.p ; then
        log -t recovery "Installing new recovery image: succeeded"
        echo "<3>[CCAudit] SW update is succeed." > /dev/kmsg
    else
        log -t recovery "Installing new recovery image: failed"
        echo "<3>[CCAudit] SW update is failed." > /dev/kmsg
	fi
else
  log -t recovery "Recovery image already installed"
fi
