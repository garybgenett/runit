#!/usr/bin/env bash
source ${HOME}/.bashrc
set -e
################################################################################
#
# cd .static ; view scripts/_sync scripts/grub.sh
# cd .setup ; view .setconf grub/.update.sh grub/grub.defaults.cfg grub/grub.menu.*
#
# ${GREP} -o "[$][{][^}]+[}]" ./grub.menu.gary-os.cfg | ${GREP} -v "[$][{]garyos[_]" | sort -u
#
########################################
#
#	* Boot
#	* Live
#		* Windows
#	* GaryOS
#	* Root
#
################################################################################

declare GRUB_BOOT="/.g/_boot"
declare GRUB_ROOT="/.g/_root"
declare GRUB_LIVE="/.g/_data/_boot"
[[ -d /.g/._boot/boot ]] && GRUB_BOOT="/.g/._boot"
[[ -d /.g/._root/boot ]] && GRUB_ROOT="/.g/._root"

declare FILES_LIST="
	${GRUB_BOOT}/boot/grub/grub.cfg
	${GRUB_BOOT}/live/grub.cfg
	${GRUB_BOOT}/gary-os/gary-os.grub/gary-os.grub.cfg
	${GRUB_ROOT}/boot/grub/grub.cfg
"

########################################

declare SCRIPTS="/.g/_data/zactive/.static/scripts"
declare CONFIGS="/.g/_data/zactive/.setup"

declare TMPDIR="/tmp/grub"

################################################################################

declare U_UPDT="false"
declare U_LIVE="false"
declare U_BOOT="false"
declare U_VIEW="false"
declare U_MENU="false"
[[ ${1} == -u ]] && U_UPDT="true" && shift
[[ ${1} == -b ]] && U_LIVE="true" && shift
[[ ${1} == -g ]] && U_BOOT="true" && shift
[[ ${1} == -v ]] && U_VIEW="true" && shift
[[ ${1} == -e ]] && U_MENU="true" && shift

########################################

if { ${U_UPDT} || ${U_LIVE}; }; then
	${SCRIPTS}/_sync boot
	${MKDIR} ${TMPDIR} ; grub.sh ${TMPDIR}
	${SED} -i "s|memdisk|hd0,1|g" ${TMPDIR}/gary-os.grub.cfg
	${RSYNC_U} ${TMPDIR}/gary-os.grub.cfg ${GRUB_LIVE}/gary-os/gary-os.grub/
	${SCRIPTS}/_sync archive ${SCRIPT}
fi

########################################

if { ${U_UPDT} || ${U_BOOT}; }; then
#>>>	${SCRIPTS}/_sync grub ${GRUB_BOOT}
	${SCRIPTS}/_sync grub all
	${CONFIGS}/.setconf
	${SCRIPTS}/_sync archive ${SCRIPT}
fi

########################################

if { ${U_UPDT} || ${U_VIEW}; }; then
	${VIEW} ${FILES_LIST}
fi

########################################

if { ${U_UPDT} || ${U_MENU}; }; then
	grub-emu -d ${GRUB_BOOT}/boot/grub
fi

########################################

${LL} -L ${FILES_LIST}

exit 0
################################################################################
# end of file
################################################################################
