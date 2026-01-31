#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare SV_CMD="$(which sv)"
declare SVC=

################################################################################

for SVC in $(ls $(dirname ${0})/_config); do
	${SV_CMD} status ${SVC}
done
echo
for SVC in $(psg "runsv[ ]" | awk '{print $12;}' | sort); do
	${SV_CMD} status ${SVC}
done

########################################

if [[ -n ${1} ]]; then
	declare SVC="${1}" && shift
	echo
	${SV_CMD} restart ${SVC}
	tail -f /.runit/log/${SVC}
fi

exit 0
################################################################################
# end of file
################################################################################
