#!/system/bin/sh

#
# copy xml files
#

if [ ! -f "/persist-lg/gons/26201_RoamingPartner.xml" ]; then
    cp /system/etc/26201_RoamingPartner.xml /persist-lg/gons/26201_RoamingPartner.xml
    chmod -h 664 /persist-lg/gons/26201_RoamingPartner.xml
fi

if [ ! -f "/persist-lg/gons/26202_RoamingPartner.xml" ]; then
    cp /system/etc/26202_RoamingPartner.xml /persist-lg/gons/26202_RoamingPartner.xml
    chmod -h 664 /persist-lg/gons/26202_RoamingPartner.xml
fi

if [ ! -f "/persist-lg/gons/45000_RoamingPartner.xml" ]; then
    cp /system/etc/45000_RoamingPartner.xml /persist-lg/gons/45000_RoamingPartner.xml
    chmod -h 664 /persist-lg/gons/45000_RoamingPartner.xml
fi
