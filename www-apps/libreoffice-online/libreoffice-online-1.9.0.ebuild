# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools eutils fcaps user

DESCRIPTION="LibreOffice on-line."
HOMEPAGE="https://www.collaboraoffice.com/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SERVER="loolwsd"
JS="loleaflet"
MYUSER="lool"
MYGROUP="www-data"
PROG1="/usr/bin/loolforkit"
PROG2="/usr/bin/loolmount"
PROG3="/usr/bin/loolwsd-systemplate-setup"

# set-caps taken from loolwsd-Makefile
FILECAPS=(
	cap_fowner,cap_mknod,cap_sys_chroot=ep "${PROG1}" --
	cap_sys_admin=ep "${PROG2}"
)

SRC_URI="https://github.com/LibreOffice/online/archive/${PV}.tar.gz -> ${P}.tar.gz"

# libreoffice[odk]???
RDEPEND=">=app-office/libreoffice-5.2
		>=dev-libs/poco-1.7.4
		dev-python/polib
		media-libs/libpng:0
		net-libs/nodejs
		sys-libs/libcap"
DEPEND="${RDEPEND}
		>=dev-nodejs/jake-8.0.12"

pkg_setup() {
	local MYPATH="var/lib/libreoffice-online"
	enewgroup "${MYGROUP}"
	enewuser "${MYUSER}" -1 -1 "/${MYPATH}/home" "${MGROUP}"
	# we need this to prevent issue https://github.com/npm/npm/issues/11486
	mkdir -p "/usr/etc" || die "Could not create '/usr/etc'"
}

src_unpack() {
	unpack ${A}
	local MYPATH="${WORKDIR}/online-${PV}${MIN}/"
	mv "${MYPATH}" "${S}" || die "Could not move directory '${MYPATH}' to '${S}'"
}

src_prepare() {
	epatch "${FILESDIR}/${P}-${SERVER}-Makefile.am.patch"
	#epatch "${FILESDIR}/${P}-${SERVER}-LOOLKit.cpp.patch"
	epatch "${FILESDIR}/${P}-${JS}-Makefile.patch"
	eapply_user
}

src_configure() {
	cd "${S}/${SERVER}" || die "Could not change dir to '${S}/${SERVER}'"
	local myeconfargs=( \
		--with-lokit-path="${S}/${SERVER}/bundled/include/" \
		# $(use_enable foo) \
	)
	eautoreconf
	econf ${myeconfargs}
}

src_compile() {
	# compile server component
	elog "Building ${SERVER}"
	cd "${S}/${SERVER}" || die "Could not change dir to '${S}/${SERVER}'"
	emake
	# compile JavaScript component
	elog "Building ${JS}"
	cd "${S}/${JS}" || die "Could not change dir to '${S}/${JS}'"
	emake dist
}

src_install() {
	# install server component
	cd "${S}/${SERVER}" || die "Could not change dir to '${S}/${SERVER}'"
	emake DESTDIR="${D}" install
	# install JavaScript component
	local MYPATH="var/lib/libreoffice-online"
	local MYPATH_JS="${MYPATH}/${JS}"
	dodir "/${MYPATH_JS}"
	cp -R "${S}/${JS}/${JS}-${PV}/dist"/* "${D}/${MYPATH_JS}" || die \
		"could not copy '${S}/${JS}/${JS}-${PV}/' to '${D}/${MYPATH_JS}'"
	# prepare other things
	dodir "/${MYPATH}/cache"
	fowners "${MYUSER}:${MGROUP}" "/${MYPATH}/cache"
	dodir "/${MYPATH}/home"
	fowners "${MYUSER}:${MGROUP}" "/${MYPATH}/home"
	dodir "/${MYPATH}/jails"
	fperms 0700 "/${MYPATH}/jails"
	fowners "${MYUSER}:${MGROUP}" "/${MYPATH}/jails"
	# and necessary symlinks
	dosym "../loleaflet" "/${MYPATH}/home/loleaflet"
	dosym "../loleaflet" "/${MYPATH}/loleaflet/dist"
	
	#dodir "/${MYPATH}/systemplate"
	#fowners "${MYUSER}:${MGROUP}" "/${MYPATH}/systemplate"
	# move /usr/bin/... /usr/sbin/ ???
	# start /usr/bin/loolwsd
	# set lo_template_path to /usr/lib64/libreoffice
	# see loolwsd/debian/lool.postinst for more installation hints
	# su - ${MYUSER} -c mkdir /home/lool/systemplate
	# su - ${MYUSER} -c loolwsd-systemplate-setup ./systemplate /usr/lib64/libreoffice/
	## RC script ##
	newinitd "${FILESDIR}/${P}.init" "${PN}"
	#    newconfd "${FILESDIR}/${PN}.conf" "${PN}"
	# create logging directory
	local LOGDIR="/var/log/libreoffice-online/"
	dodir "${LOGDIR}"
	fowners "${MYUSER}:${MGROUP}" "${LOGDIR}"
	# install config file(s)
	dodir "/etc/loolwsd"
	insinto "/etc/loolwsd"
	newins "${FILESDIR}/${P}-loolwsd.xml" "loolwsd.xml"
}

pkg_postinst() {
	elog "Set required capabilities for '${PROG1}' and '${PROG2}'"
	fcaps_pkg_postinst
	local SYS="/var/lib/libreoffice-online/systemplate"
	elog "Creating and populating '${SYS}'"
	rm -Rf "${SYS}" || \
		die "Could not clean '${SYS}'"
	/usr/bin/loolwsd-systemplate-setup \
		"${SYS}" \
		"/usr/lib64/libreoffice/" \
		|| die "Could not execute '${PROG3}"\
			"${SYS}" \
			"/usr/lib64/libreoffice/'"
#	elog "su -l ${MYUSER} -s /bin/bash -c '/usr/bin/loolwsd-systemplate-setup" \
#		"/${MYPATH}/systemplate" \
#		"/usr/lib64/libreoffice/'"
#	su -l "${MYUSER}" -s /bin/bash -c "/usr/bin/loolwsd-systemplate-setup" \
#		"/${MYPATH}/systemplate" \
#		"/usr/lib64/libreoffice/"
}
