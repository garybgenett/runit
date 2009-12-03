#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

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

${MKDIR} ./runsvdir/media
${MKDIR} ./runsvdir/default
${MKDIR} ./runsvdir/server_r
${MKDIR} ./runsvdir/server_v
${MKDIR} ./runsvdir/server
${MKDIR} ./runsvdir/maint
${MKDIR} ./runsvdir/maint_x
${MKDIR} ./runsvdir/station
${RM} ./runsvdir/*/*

declare IFS_ORIG="${IFS}"
declare IFS_LINE="
"

export IFS="${IFS_LINE}"
declare LINE
for LINE in $(eval ${GREP} -v "^#" ./_runlevels.txt); do
	export IFS="${IFS_ORIG}"
	declare SVC_SET="false"
	declare LEVEL
	for LEVEL in ${LINE}; do
		if ${SVC_SET}; then
			${LN} ../../services/${SVC} ./runsvdir/${LEVEL}/${SVC}
		else
			SVC="${LEVEL}"
			SVC_SET="true"
		fi
	done
	export IFS="${IFS_LINE}"
done
export IFS="${IFS_ORIG}"

for SVC in $(ls ./_config); do
	if [[ -z $(${GREP} "^${SVC}" ./_runlevels.txt) ]]; then
		echo -ne "\n !!! SERVICE '${SVC}' MISSING !!!\n"
	fi
done

exit 0
################################################################################
# end of file
################################################################################
