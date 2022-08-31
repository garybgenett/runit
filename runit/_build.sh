#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare ROOT_DST="${ROOT_DST:-}"

declare RUNLEVELS="./_runlevels.txt"

################################################################################

${RM} ${ROOT_DST}/etc/runit
${RM} ${ROOT_DST}/etc/service
${RM} ${ROOT_DST}/etc/sv
${RM} ${ROOT_DST}/service
${RM} ${ROOT_DST}/var/service

${LN} -r ${PWD}				${ROOT_DST}/etc/runit
${LN} -r ${PWD}/services		${ROOT_DST}/etc/sv
${LN} -r ${PWD}/services		${ROOT_DST}/service

${LN} $(realpath --no-symlink --relative-to=${ROOT_DST}/etc ${PWD}/runsvdir/current) ${ROOT_DST}/etc/service
${LN} $(realpath --no-symlink --relative-to=${ROOT_DST}/var ${PWD}/runsvdir/current) ${ROOT_DST}/var/service

########################################

#>>>${MKDIR} ${ROOT_DST}/etc/init.d

#>>>declare SV_CMD="$(which sv)"
#>>>for SVC in $(ls ./_config); do
#>>>	${RM} ${ROOT_DST}/etc/init.d/${SVC}
#>>>	${LN} -r ${ROOT_DST}${SV_CMD} ${ROOT_DST}/etc/init.d/${SVC}
#>>>done

########################################

${MKDIR} ./log
${RM} ./log/*

declare SVC=
for SVC in $(ls ./_config | ${GREP} -v "^tty"); do
	${MKDIR} ./services/${SVC}/log
	${LN} -r ./services/${SVC}/log/current	./log/${SVC}
	${LN} -r ./_config/.log_config		./services/${SVC}/log/config
	${LN} -r ./_config/.log_run		./services/${SVC}/log/run
done
${LN} -r ./_config/.log_config_capture		./services/syslogd/log/config

for SVC in syslogd tcpdump; do
	${RM} ./.${SVC}
	${LN} -r ./services/${SVC}/log ./.${SVC}
done

########################################

for SVC in $(ls ./_config); do
	${MKDIR} ./services/${SVC}
	${LN} -r ./_config/${SVC} ./services/${SVC}/run
done

########################################

${RM} ./runsvdir/*/*

declare LINE
declare LEVEL
${GREP} -v "^[#]" ${RUNLEVELS} | while read -r LINE; do
	declare SVC_SET="false"
	for LEVEL in ${LINE}; do
		if ${SVC_SET}; then
			${MKDIR} ./runsvdir/${LEVEL}
			${LN} -r ./services/${SVC} ./runsvdir/${LEVEL}/${SVC}
		else
			SVC="${LEVEL}"
			SVC_SET="true"
		fi
	done
done

########################################

chown -vR root:root	./
chmod -vR 755		./

chown -vR root:tcpdump	./services/tcpdump/log
chmod -vR 775		./services/tcpdump/log

########################################

${RM} ./ctrlaltdel
${RM} ./reboot
${RM} ./stopit

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
