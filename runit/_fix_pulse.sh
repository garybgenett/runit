#!/bin/sh
runsvchdir /.runit/runsvdir/server_v
echo
killall -v -9 \
	Xorg		\
	dbus-daemon	\
	dbus-launch	\
	pulseaudio	\
	xbmc		\
	xbmc.bin	\
	xorg		\
	xorg.null
echo
until [ -z "$(
	lsmod |
	grep -E "snd"
)" ]; do
	for MODULE in $(
		lsmod		|
		grep -E "snd"	|
		cut -d' ' -f1
	); do
		rmmod -v ${MODULE}
	done
done
echo
rm -frv \
	/.g/_data/zactive/.home/.pulse*		\
	/dev/shm/pulse*				\
	/tmp/pulse*
echo
chmod -vR 1777 \
	/dev/shm
if [ "x$1" == "xon" ]; then
	echo
	for MODULE in $(
		grep -E "snd" /etc/modules
	); do
		modprobe -v ${MODULE}
	done
	echo
	runsvchdir /.runit/runsvdir/media
	sleep 5
	aumix -C ansi
	alsamixer
fi
exit 0
# end of file
