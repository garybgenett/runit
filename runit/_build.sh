#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare RUNLEVELS="./_runlevels.txt"

declare SV_CMD="$(which sv)"

################################################################################

${RM} /etc/runit
${RM} /service
${RM} /var/service

${LN} /.runit		/etc/runit
${LN} /.runit/services	/service
${LN} /.runit/services	/var/service

########################################

#>>>${MKDIR} /etc/init.d

#>>>for SVC in $(ls ./_config); do
#>>>	${RM} /etc/init.d/${SVC}
#>>>	${LN} ${SV_CMD} /etc/init.d/${SVC}
#>>>done

########################################

${MKDIR} ./log
${RM} ./log/*

declare SVC=
for SVC in $(ls ./_config | ${GREP} -v "^tty"); do
	${MKDIR} ./services/${SVC}/log
	${LN} ../services/${SVC}/log/current	./log/${SVC}
	${LN} ../../../_config/.log_config	./services/${SVC}/log/config
	${LN} ../../../_config/.log_run		./services/${SVC}/log/run
done

${LN} ../../../_config/.log_config_capture	./services/syslogd/log/config

for SVC in syslogd tcpdump; do
	${RM} ./.${SVC}
	${LN} ./services/${SVC}/log	./.${SVC}
done

########################################

for SVC in $(ls ./_config); do
	${MKDIR} ./services/${SVC}
	${LN} ../../_config/${SVC}	./services/${SVC}/run
done

########################################

${RM} ./runsvdir/*/*

declare IFS_ORIG="${IFS}"
declare IFS_LINE="
"

export IFS="${IFS_LINE}"
declare LINE
declare LEVEL
for LINE in $(eval ${GREP} -v "^[#]" ${RUNLEVELS}); do
	export IFS="${IFS_ORIG}"
	declare SVC_SET="false"
	for LEVEL in ${LINE}; do
		if ${SVC_SET}; then
			${MKDIR} ./runsvdir/${LEVEL}
			${LN} ../../services/${SVC} ./runsvdir/${LEVEL}/${SVC}
		else
			SVC="${LEVEL}"
			SVC_SET="true"
		fi
	done
	export IFS="${IFS_LINE}"
done
export IFS="${IFS_ORIG}"

########################################

chown -vR root:root	./
chmod -vR 755		./

chown -vR root:tcpdump	./services/tcpdump/log

########################################

for SVC in $(ls ./_config); do
	if [[ -z $(${GREP} "^${SVC}" ${RUNLEVELS}) ]]; then
		echo -en "\n !!! SERVICE '${SVC}' MISSING !!!\n"
	fi
done

exit 0
################################################################################
# end of file
################################################################################
