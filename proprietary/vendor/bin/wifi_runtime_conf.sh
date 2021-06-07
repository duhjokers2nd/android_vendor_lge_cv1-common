#!/system/bin/sh

#BUILD TIME
WLAN_CHIP_VENDOR=`getprop wlan.chip.vendor`
WLAN_CHIP_VERSION=`getprop wlan.chip.version`

# RUN TIME Property http://collab.lge.com/main/pages/viewpage.action?pageId=677917338
LAOP_LAOP_ENABLED_PROP=`getprop ro.lge.laop`
LAOP_SKU_CARRIER_PROP=`getprop ro.lge.sku_carrier`
LAOP_TARGET_OPERATOR_PROP=`getprop ro.build.target_operator`
LAOP_TARGET_COUNTRY_PROP=`getprop ro.build.target_country`
LAOP_DEFAULT_COUNTRY_PROP=`getprop ro.build.default_country`
LAOP_BRAND_PROP=`getprop ro.lge.laop.brand`
LAOP_SIM_OPERATOR_USED_PROP=`getprop ro.lge.sim.operator.use`
LAOP_PRODUCT_MODEL_PROP=`getprop ro.product.model`
LAOP_MODEL_MODEL_PROP=`getprop ro.model.name`

# Folder path
WIFI_CACHE_FOLDER_ROOT=/persist-lg/wifi
WIFI_SYSTEM_PATH=/system/etc/wifi
WIFI_DATA_PATH=/data/misc/wifi
WIFI_SYSTEM_SKU_PATH=${WIFI_SYSTEM_PATH}/${LAOP_SKU_CARRIER_PROP}

# RUNTIME PROPERTY
WIFI_RUNTIME_PROPERTY_FILE=/system/etc/wifi/wifi_runtime_prop.conf
# TAG NAME
TAG=LAOP_WIFI

# QCT
WIFI_QCT_FOLDER_PATH=${WIFI_CACHE_FOLDER_ROOT}/qcom
WIFI_QCT_CACHE_BOOT_CAL_FILE=${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_wlan_cache_nv_boot.bin
WIFI_QCT_CACHE_INI_FILE=${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_cache_cfg.ini
# QCT WCN399X
WIFI_QCT_399X_CACHE_BD_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_cache.bin
WIFI_QCT_399X_CACHE_BD_CH0_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_ch0_cache.bin
WIFI_QCT_399X_CACHE_BD_CH1_WLAN=${WIFI_QCT_FOLDER_PATH}/bdwlan_ch1_cache.bin
WIFI_QCT_399X_CACHE_MAC_WLAN=${WIFI_QCT_FOLDER_PATH}/wlan_mac_cache.bin

# BRCM
WIFI_BRCM_FOLDER_PATH=${WIFI_CACHE_FOLDER_ROOT}/brcm
WIFI_BRCM_CACHE_BOOT_CAL_FILE=${WIFI_BRCM_FOLDER_PATH}/bcmdhd_cache.cal

# MTK
WIFI_MTK_FOLDER_PATH=${WIFI_CACHE_FOLDER_ROOT}/mtk
WIFI_MTK_CACHE_BOOT_CAL_FILE=${WIFI_MTK_FOLDER_PATH}/WIFI_cache
WIFI_MTK_FW_PATH=/system/vendor/firmware

function CHECK_CACHE_ROOT_FOLDER_EXIST() {
if [[ -d ${WIFI_CACHE_FOLDER_ROOT} ]]; then
	return 1
else
	log -p e -t "${TAG}" "Don't be exist root folder"
	return 0
fi
}

function CHECK_CACHE_VENDOR_FOLDER_EXIST() {
if [[ ${WLAN_CHIP_VENDOR} == "qcom" ]]; then
	if [[ -d ${WIFI_QCT_FOLDER_PATH} ]]; then
		return 1
	else
		log -p e -t "${TAG}" "Don't be exist qcom folder"
		return 0
	fi
elif [[ ${WLAN_CHIP_VENDOR} == "brcm" ]]; then
	if [[ -d ${WIFI_BRCM_FOLDER_PATH} ]]; then
		return 1
	else
		log -p e -t "${TAG}" "Don't be exist BRCM folder"
		return 0
	fi
elif [[ ${WLAN_CHIP_VENDOR} == "mtk" ]]; then
	if [[ -d ${WIFI_MTK_FOLDER_PATH} ]]; then
		return 1
	else
		log -p e -t "${TAG}" "Don't be exist MTK folder"
		return 0
	fi
else
	return 0
fi
}

function QCOM_INI_SET() {
	log -p v -t "${TAG}" "QCOM INI"
	# ini
	if [[ -f ${WIFI_QCT_CACHE_INI_FILE} ]]; then
	log -p v -t "${TAG}" "Default INI Link Success"
	if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
		if [[ -f ${WIFI_SYSTEM_SKU_PATH}/WCNSS_qcom_cfg.ini ]]; then
			ln -sf ${WIFI_SYSTEM_SKU_PATH}/WCNSS_qcom_cfg.ini ${WIFI_QCT_CACHE_INI_FILE}
			log -p v -t "${TAG}" "Change symbolic link"
		else
			log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
		fi
	fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi
}

function QCOM_NV_SET() {
	log -p v -t "${TAG}" "QCOM WCN NV"
	# nv.bin
	ln -sf ${WIFI_SYSTEM_PATH}/WCNSS_qcom_wlan_nv.bin ${WIFI_QCT_CACHE_BOOT_CAL_FILE}
	ln -sf ${WIFI_SYSTEM_PATH}/WCNSS_qcom_cfg.ini ${WIFI_QCT_FOLDER_PATH}/WCNSS_qcom_cache_cfg.ini

	if [[ -f ${WIFI_QCT_CACHE_BOOT_CAL_FILE} ]]; then
		log -p v -t "${TAG}" "Default NV Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/WCNSS_qcom_wlan_nv.bin ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/WCNSS_qcom_wlan_nv.bin ${WIFI_QCT_CACHE_BOOT_CAL_FILE}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi

	# INI
	QCOM_INI_SET
}

function QCOM_WCN399X_NV_SET() {
	log -p v -t "${TAG}" "QCOM WCN399X NV"
	# bdwlan.bin
	ln -sf ${WIFI_SYSTEM_PATH}/bdwlan.bin ${WIFI_QCT_399X_CACHE_BD_WLAN}

	if [[ -f ${WIFI_QCT_399X_CACHE_BD_WLAN} ]]; then
		log -p v -t "${TAG}" "Default bdwlan Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/bdwlan.bin ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/bdwlan.bin ${WIFI_QCT_399X_CACHE_BD_WLAN}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi

	# bdwlan_ch0.bin
	ln -sf ${WIFI_SYSTEM_PATH}/bdwlan_ch0.bin ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN}
	if [[ -f ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN} ]]; then
		log -p v -t "${TAG}" "Default bdwlan_ch0 Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/bdwlan_ch0.bin ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/bdwlan_ch0.bin ${WIFI_QCT_399X_CACHE_BD_CH0_WLAN}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi

	# bdwlan_ch1.bin
	ln -sf ${WIFI_SYSTEM_PATH}/bdwlan_ch1.bin ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN}
	if [[ -f ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN} ]]; then
		log -p v -t "${TAG}" "Default bdwlan_ch1 Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/bdwlan_ch1.bin ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/bdwlan_ch1.bin ${WIFI_QCT_399X_CACHE_BD_CH1_WLAN}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi

	# INI
	QCOM_INI_SET
}

function BRCM_NV_SET() {
	log -p v -t "${TAG}" "BRCM"
	# on first booting.
	ln -sf ${WIFI_SYSTEM_PATH}/bcmdhd.cal ${WIFI_BRCM_CACHE_BOOT_CAL_FILE}

	if [[ -f ${WIFI_BRCM_CACHE_BOOT_CAL_FILE} ]]; then
		log -p v -t "${TAG}" "Default bcmdhd.cal Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/bcmdhd.cal ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/bcmdhd.cal ${WIFI_BRCM_CACHE_BOOT_CAL_FILE}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi
}

function CHECK_FIRMWARE_MTK_FOLDER_EXIST() {
if [[ -d ${WIFI_MTK_FW_PATH} ]]; then
	return 1
else
	log -p e -t "${TAG}" "Don't be exist MTK FW folder"
	return 0
fi
}

function MTK_NV_SET() {
	log -p v -t "${TAG}" "MTK"
	# on first booting.
	ln -sf ${WIFI_MTK_FW_PATH}/WIFI ${WIFI_MTK_CACHE_BOOT_CAL_FILE}

	if [[ -f ${WIFI_MTK_CACHE_BOOT_CAL_FILE} ]]; then
		log -p v -t "${TAG}" "Default WIFI Link Success"
		if [[ -n ${LAOP_SKU_CARRIER_PROP} ]]; then
			if [[ -f ${WIFI_SYSTEM_SKU_PATH}/WIFI ]]; then
				ln -sf ${WIFI_SYSTEM_SKU_PATH}/WIFI ${WIFI_MTK_CACHE_BOOT_CAL_FILE}
				log -p v -t "${TAG}" "Change symbolic link"
			else
				log -p e -t "${TAG}" "Need to Check SKU Carrier Folder"
			fi
		fi
	else
		log -p e -t "${TAG}" "Don't have write permission to change Link"
	fi
}

function READ_FILE_SET_PROPERTY() {
if [[ -f ${WIFI_RUNTIME_PROPERTY_FILE} ]]; then
	while read -r SKU PROP NAME VALUE ETC
	do
		str_chk=`echo "${SKU}" | grep "#" | wc -l`
		if [[ ! $str_chk -ge 1 ]]; then
			if [[ -n ${LAOP_SKU_CARRIER_PROP} ]] && [[ ${LAOP_SKU_CARRIER_PROP} = ${SKU} ]]; then
				if [[ ${PROP} = "setprop" ]]; then
					`setprop ${NAME} ${VALUE}`
					log -p v -t "${TAG}" "${SKU} ${PROP} ${NAME} ${VALUE}"
				else
					log -p e -t "${TAG}" "Please check wifi_runtime_prop.conf format"
				fi
			fi
		fi
	done < ${WIFI_RUNTIME_PROPERTY_FILE}
else
	log -p v -t "${TAG}" "Please check wifi_runtime_prop.conf"
fi
}

function MAIN_FUNCTION() {
if [[ ${LAOP_LAOP_ENABLED_PROP} == 1 ]]; then
	log -p v -t "${TAG}" "LAOP Property set and Working runtime Wi-Fi NV"
	if [[ ${WLAN_CHIP_VENDOR} == "qcom" ]]; then
		if [[ ${WLAN_CHIP_VERSION} == "wcn399x" ]]; then
			QCOM_WCN399X_NV_SET
		else
			QCOM_NV_SET
		fi
	elif [[ ${WLAN_CHIP_VENDOR} == "brcm" ]]; then
		BRCM_NV_SET
	elif [[ ${WLAN_CHIP_VENDOR} == "mtk" ]]; then
		MTK_NV_SET
	else
		return
	fi
	# Property Conf file read.
	READ_FILE_SET_PROPERTY
else
	log -p v -t "${TAG}" "ro.lge.laop = 0 and do not working"
fi
}

# MAIN FUNCTION
MAIN_FUNCTION

