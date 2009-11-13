#!/usr/bin/env bash
source ${HOME}/.bashrc

rm -frv ./log/*
rm -frv ./runsvdir/*/*
rm -frv ./services/*/run
rm -frv ./services/*/log/{config,run}

mkdir -pv ./{log,runsvdir,services,watch}
mkdir -pv ./runsvdir/{media,default,server,station,maint,maintx}

for SVC in $(ls ./_config); do
	mkdir -pv ./services/${SVC}
done

for SVC in $(ls ./_config | grep -vE "^tty"); do
	mkdir -pv ./services/${SVC}/log
	ln -fsv ../services/${SVC}/log/current	./log/${SVC}
	ln -fsv ../../../_config/.log_config	./services/${SVC}/log/config
	ln -fsv ../../../_config/.log_run	./services/${SVC}/log/run
done

ln -fsv ../../../_config/.log_config_syslog	./services/syslogd/log/config
ln -fsv ../../../_config/.log_run_syslog	./services/syslogd/log/run
ln -fsv ../_config/.log_config_syslog		./watch/config

for SVC in $(ls ./_config); do
	ln -fsv ../../_config/${SVC}	./services/${SVC}/run
	ln -fsv ../../services/${SVC}	./runsvdir/media/${SVC}
	ln -fsv ../../services/${SVC}	./runsvdir/default/${SVC}
	ln -fsv ../../services/${SVC}	./runsvdir/server/${SVC}
	ln -fsv ../../services/${SVC}	./runsvdir/station/${SVC}
	ln -fsv ../../services/${SVC}	./runsvdir/maint/${SVC}
	ln -fsv ../../services/${SVC}	./runsvdir/maintx/${SVC}
done

rm -frv ./runsvdir/*/{htc,hts,nxproxyc,nxproxys,xdm}

rm -frv   ./runsvdir/media/{NULL,NULL}
rm -frv ./runsvdir/default/{pavucontrol,projectm,pulseaudio}
rm -frv  ./runsvdir/server/{pavucontrol,projectm,pulseaudio,cupsd,dbus,hald,smbd,xvfb}
rm -frv ./runsvdir/station/{pavucontrol,projectm,pulseaudio,cupsd,dbus,hald,smbd,xvfb,_sync,dhcpd,dovecot,tftpd,thttpd,proftpd,named}
rm -frv   ./runsvdir/maint/{pavucontrol,projectm,pulseaudio,cupsd,dbus,hald,smbd,xvfb,_sync,dhcpd,dovecot,tftpd,thttpd,proftpd}
rm -frv  ./runsvdir/maintx/{pavucontrol,projectm,pulseaudio,cupsd,dbus,hald,smbd,xvfb,_sync,dhcpd,dovecot,tftpd,thttpd,proftpd}

rm -frv ./runsvdir/{media,default,server,maint,maintx}/{autossh,dhcpcd}
rm -frv ./runsvdir/{server,maint}/{xorg,xsession}

exit 0
# end of file
