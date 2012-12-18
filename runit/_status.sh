#!/usr/bin/env bash
source ${HOME}/.bashrc
################################################################################

declare SV_CMD="$(which sv)"

################################################################################

declare SVC=
for SVC in $(ls $(dirname ${0})/_config); do
	sv status ${SVC}
done

########################################

echo

########################################

declare SVC=
for SVC in $(psg "runsv[ ]" | awk '{print $12;}' | sort); do
	sv status ${SVC}
done

exit 0
################################################################################
# end of file
################################################################################
