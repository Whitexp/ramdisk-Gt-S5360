#!/system/bin/sh

echo " " >> /data/local/CWM-Ver
echo " " >> /data/local/CWM-Ver

FILESIZE=$(/sbin/busybox cat /data/local/CWM-Ver|wc -c)
USERNAME=$(/sbin/busybox whoami)

exec > /data/local/userscript.log 2>&1

# Loging as Root
chmod 4777 /sbin/su
/sbin/su

# Remove Kernel file if it is big
if /sbin/busybox test "$FILESIZE" -ge "10000"; then
	/sbin/busybox rm /data/local/CWM-Ver
fi
sync

# Start Logging
echo "  " >> /data/local/CWM-Ver
echo " Starting Merruk Logger Script - ( AT ) - " $(/sbin/busybox date) >> /data/local/CWM-Ver
echo " - " >> /data/local/CWM-Ver
echo " - " >> /data/local/CWM-Ver
echo " " $(/sbin/busybox uname -a) >> /data/local/CWM-Ver
echo " Username : " $USERNAME >> /data/local/CWM-Ver
echo " - " >> /data/local/CWM-Ver
echo " - " >> /data/local/CWM-Ver

############# Start the important things #############

# UnlockBML & Remount Read/Write
echo "	Unlock BML Blocks " >> /data/local/CWM-Ver
/sbin/bmlunlock
sleep 1

echo "	Mount /System as R/W " >> /data/local/CWM-Ver
/sbin/busybox mount -o remount,rw /dev/block/stl9 /system
/sbin/busybox mount -o remount,rw / /
sleep 1

# Create Needed Directories
echo "	Create /etc directory " >> /data/local/CWM-Ver
/sbin/busybox rm -f /etc
/sbin/busybox mkdir -p /etc

if /sbin/busybox test ! -d /sd-ext ; then
	echo "	Create /sd-ext Folder " >> /data/local/CWM-Ver
	/sbin/busybox mkdir -p /sd-ext
fi
sync


# Galaxy Y make /sdcard a symlink to /mnt/sdcard, which confuses CWM
echo "	Fix Linked /sdcard to /mnt/sdcard " >> /data/local/CWM-Ver
/sbin/busybox rm -f /sdcard
/sbin/busybox mkdir -p /sdcard

# Fix permissions in /sbin
echo "	Fix Permissions on /sbin " >> /data/local/CWM-Ver
chmod 750 /sbin/*
echo "		* Set a Special Permissions for Busybox & Su " >> /data/local/CWM-Ver
chmod u+s /sbin/busybox
chmod 06755 /sbin/su

# Fix Recovery EXT4 Partitions 
if /sbin/busybox test -f /etc/recovery.fstab ; then
	echo "	Replace Recovery 'fstab' File -Status 1- " >> /data/local/CWM-Ver
	rm /etc/recovery.fstab
	cp /sbin/recovery.fstab /etc/
else
	echo "	Replace Recovery 'fstab' File -Status 2- " >> /data/local/CWM-Ver
	cp /sbin/recovery.fstab /etc/
fi
sync

# Fix System EXT4 Partitions
if /sbin/busybox test -f /etc/fstab ; then
	echo "	Replace System 'fstab' File -Status 1- " >> /data/local/CWM-Ver
	rm /etc/fstab
	cp /sbin/fstab /etc/
else
	echo "	Replace System 'fstab' File -Status 2- " >> /data/local/CWM-Ver
	cp /sbin/fstab /etc/
fi
sync

sleep 2

#######################################################


# Also A Shorter
echo '#!/sbin/sh
exec >> /data/local/CWMm_Boot_Log.txt 2>&1

/sbin/busybox cp /sbin/fstab /etc/
/sbin/busybox cp /sbin/fstab /etc/mtab
/sbin/busybox cp /sbin/recovery.fstab /etc/recovery.fstab

# Mount All fstab Mount-Points
echo "	Mount /System as R/W " >> /data/local/cwm_boot_log.txt
/sbin/busybox mount -o remount,rw /dev/block/stl9 /system
/sbin/busybox mount -o remount,rw / /
/sbin/busybox mount -a
sleep 2

# succeed to mount the sdcard by default even with broken fstab
/sbin/busybox mount -t vfat -o rw,nosuid,nodev,noexec,uid=1000,gid=1015,fmask=0002,dmask=0002,allow_utime=0020,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro /dev/block/mmcblk0p1 /sdcard
sleep 1
' > /sbin/postrecoveryboot.sh
chmod 777 /sbin/postrecoveryboot.sh

# Needed For CWM Recouvery
/sbin/busybox rm /cache/recovery/command
/sbin/busybox rm /cache/update.zip
touch /tmp/.ignorebootmessage
kill $(ps | grep /sbin/adbd)
kill $(ps | grep /sbin/recovery)

# Check if we have a luancher first
if /sbin/busybox test -f /sbin/recovery.sh ; then
    /sbin/busybox sh /sbin/recovery.sh &
else
    /sbin/recovery &
fi
sync

exit 1
