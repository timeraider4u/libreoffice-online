# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils systemd user

DESCRIPTION="LibreOffice on-line."
HOMEPAGE="https://www.collaboraoffice.com/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

MYUSER="lool"
MYGROUP="www-data"

# may be overriden by system administrator
#if [ -z "${MYPATH}" ]; then
	MYPATH="/var/lib/${PN}"
#fi

SRC_URI="https://github.com/LibreOffice/online/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

RDEPEND="~www-apps/loleaflet-${PV}
		~www-apps/loolwsd-${PV}"
DEPEND="${RDEPEND}"

S="${WORKDIR}/online-${PV}"

# check if <systemplate> and <lotemplate> will be on the same partition
# as otherwise executing the loolwsd service will lead to problems
# when trying to create hard-links across different partitions/devices.
function checkOnSamePartition() {
	local DEV1=$(stat -c "%d" /usr/lib64/libreoffice)
	local DEV2=$(stat -c "%d" /var/lib/)
	test "${DEV1}" == "${DEV2}"
	RES=$?
	return ${RES}
}

pkg_setup() {
	enewgroup "${MYGROUP}"
	enewuser "${MYUSER}" -1 -1 "${MYPATH}/home" "${MGROUP}"
}

#src_unpack() {
#	# do nothing
#	unpack ${A}
#}

src_prepare() {
	eapply_user
}

src_configure() {
	# do nothing
	return;
}

src_compile() {
	# do nothing
	return;
}

# see loolwsd/debian/lool.postinst for more installation hints
src_install() {
	exeinto "/usr/bin"
	doexe "${FILESDIR}/${PV}/libreoffice-online-precheck.sh"
	# prepare other things
	dodir "${MYPATH}/cache"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/cache"
	dodir "${MYPATH}/home"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/home"
	insinto "${MYPATH}/home"
	newins "${S}/test/data/hello.odt" "hello.odt"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/home/hello.odt"
	dodir "${MYPATH}/jails"
	fperms 0700 "${MYPATH}/jails"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/jails"
	# and necessary symlinks
	dosym "/usr/share/${PN}/loleaflet" "${MYPATH}/loleaflet"
	dosym "../loleaflet" "${MYPATH}/home/loleaflet"
	# RC script
	newinitd "${FILESDIR}/${PV}/${PN}.init" "${PN}"
	# Systemd service unit file
	systemd_dounit "${FILESDIR}/${PV}/${PN}.service"
	# create logging directory
	local LOGDIR="/var/log/${PN}/"
	dodir "${LOGDIR}"
	fowners "${MYUSER}:${MYGROUP}" "${LOGDIR}"
	# install config file(s)
	insinto "/etc/loolwsd"
	# if systemplate and lotemplate on same partition
	if checkOnSamePartition ; then
		newins "${FILESDIR}/${PV}/loolwsd.xml" "loolwsd.xml"
	else
		newins "${FILESDIR}/${PV}/loolwsd-copy-lo.xml" "loolwsd.xml"
	fi
}

pkg_postinst() {
	# populate systemplate
	local LO="/usr/lib64/libreoffice"
	local SYS="${MYPATH}/systemplate"
	elog "Creating and populating '${SYS}'"
	rm -Rf "${SYS}" || \
		die "Could not clean '${SYS}'"
	/usr/bin/loolwsd-systemplate-setup "${SYS}" "${LO}" \
		|| die "Could not execute '${PROG3}" "${SYS}" "${LO}'"
	# if systemplate and lotemplate on same partition
	if checkOnSamePartition ; then
		rm -rf "${SYS}${LO}" || die "Could not delete directory '${SYS}${LO}'"
	else
		ewarn "hard-links across partitions not working!"
		ewarn "copying <lotemplate> to <systemplate> instead!"
		cp -rLuv "${LO}"/* "${SYS}${LO}" \
			|| die "Could not copy '${LO}/*' to '${SYS}${LO}'"
	fi
	# print how-to use...
	elog "Ready for usage!"
	local MNT_POINT=$(stat -c "%m" /var/lib/)
	ewarn "Make sure that the mount point '${MNT_POINT}' for the directory " \
		"'${MYPATH}' is mounted with option -exec. Otherwise the" \
		"libreoffice-online service cannot be started successfully."
	ewarn "Change login/password for admin console in /etc/loolwsd/loolwsd.xml!"
	elog "For OpenRC execute: /etc/init.d/${PN} start"
	elog "For Systemd execute: systemctl start ${PN}"
	local URL_PART1="https://localhost:9980/loleaflet/loleaflet.html?"
	local URL_PART2="file_path=file://${MYPATH}/home/hello.odt&"
	local URL_PART3="host=wss://localhost:9980"
	local URL="${URL_PART1}${URL_PART2}${URL_PART3}"
	elog "Then open ${URL} in your browser!"
}
