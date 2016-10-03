# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

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
MYPATH="/var/lib/${PN}"

SRC_URI="https://github.com/LibreOffice/online/archive/${PV}.tar.gz
	-> ${P}.tar.gz"

RDEPEND="~www-apps/loleaflet-${PV}
		~www-apps/loolwsd-${PV}"
DEPEND="${RDEPEND}"

S="${WORKDIR}/online-${PV}"

# check if <systemplate> and <lotemplate> are on the same partition
# as otherwise executing the loolwsd service will lead to problems
# when trying to create hard-links across different partitions/devices.
#function checkSamePartition() {
# stat -c "%d %m" /usr/lib64/libreoffice
# stat -c "%d %m" /var/lib/libreoffice-online/systemplate/
#}

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

src_install() {
	# prepare other things
	dodir "${MYPATH}/cache"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/cache"
	dodir "${MYPATH}/home"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/home"
	dodir "${MYPATH}/jails"
	fperms 0700 "${MYPATH}/jails"
	fowners "${MYUSER}:${MYGROUP}" "${MYPATH}/jails"
	# and necessary symlinks
	dosym "/usr/share/${PN}/loleaflet" "${MYPATH}/loleaflet"
	dosym "../loleaflet" "${MYPATH}/home/loleaflet"
	# see loolwsd/debian/lool.postinst for more installation hints
	# su - ${MYUSER} -c mkdir /home/lool/systemplate
	# su - ${MYUSER} -c loolwsd-systemplate-setup ./systemplate /usr/lib64/libreoffice/
	# RC script
	newinitd "${FILESDIR}/${PV}/${PN}.init" "${PN}"
	#    newconfd "${FILESDIR}/${PV}/${PN}.conf" "${PN}"
	# Systemd service unit file
	systemd_dounit "${FILESDIR}/${PV}/${PN}.service"
	# create logging directory
	local LOGDIR="/var/log/${PN}/"
	dodir "${LOGDIR}"
	fowners "${MYUSER}:${MYGROUP}" "${LOGDIR}"
	# install config file(s)
	insinto "/etc/loolwsd"
	# if systemplate and lotemplate on same partition:
		newins "${FILESDIR}/${PV}/loolwsd.xml" "loolwsd.xml"
	# else
		#newins "${FILESDIR}/${PV}/loolwsd2.xml" "loolwsd.xml"
	# endif
}

pkg_postinst() {
	# populate systemplate
	local SYS="${MYPATH}/systemplate"
	elog "Creating and populating '${SYS}'"
	rm -Rf "${SYS}" || \
		die "Could not clean '${SYS}'"
	/usr/bin/loolwsd-systemplate-setup \
		"${SYS}" \
		"/usr/lib64/libreoffice/" \
		|| die "Could not execute '${PROG3}"\
			"${SYS}" \
			"/usr/lib64/libreoffice/'"
	# if systemplate and lotemplate on same partition :
		rm -rf "${SYS}/usr/lib64/libreoffice" \
			|| die "Could not delete directory '${SYS}/usr/lib64/libreoffice'"
	# else
		# hard-links across partitions not working!
		# ewarn "..."
		# cp -rLv <lotemplate> <systemplate>
	# endif 
	# print how-to use...
	elog "Ready for usage!"
	ewarn "Change login/password for admin console in /etc/loolwsd/loolwsd.xml!"
	elog "For OpenRC execute: /etc/init.d/${PN} start"
	elog "For Systemd execute: systemctl start ${PN}"
	local URL_PART1="https://localhost:9980/loleaflet/loleaflet.html?"
	local URL_PART2="file_path=file:///home/test.odt&host=wss://localhost:9980"
	local URL="${URL_PART1}${URL_PART2}"
	elog "Then open ${URL} in your browser!"
}
