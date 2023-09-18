#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
echo TDCsPi >/etc/hostname
sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tTDCsPi/g" /etc/hosts
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pi' '$5$4uKIqHX.Jl$z1K.OtmQ5PXFtRSbLHLgODYOsk7/TQCgMCXU2IYrahB'
else
   echo "$FIRSTUSER:"'$5$4uKIqHX.Jl$z1K.OtmQ5PXFtRSbLHLgODYOsk7/TQCgMCXU2IYrahB' | chpasswd -e
   if [ "$FIRSTUSER" != "pi" ]; then
      usermod -l "pi" "$FIRSTUSER"
      usermod -m -d "/home/pi" "pi"
      groupmod -n "pi" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pi/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pi/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pi /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
systemctl enable ssh
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=BE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Howest-IoT"
	psk=a2ad90c72dd23d4fb7daed24ec566fa2311abb84904035d4dea7f4500240f0b9
}

WPAEOF
chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
rfkill unblock wifi
for filename in /var/lib/systemd/rfkill/*:wlan ; do
  echo 0 > $filename
done
rm -f /etc/localtime
echo "Europe/Brussels" >/etc/timezone
dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="be"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
dpkg-reconfigure -f noninteractive keyboard-configuration
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
