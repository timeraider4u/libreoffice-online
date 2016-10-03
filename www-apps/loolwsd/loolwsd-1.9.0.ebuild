# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools eutils fcaps

DESCRIPTION="LibreOffice on-line - server (loolwsd) component."
HOMEPAGE="https://www.collaboraoffice.com/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="https://github.com/LibreOffice/online/archive/${PV}.tar.gz
	-> libreoffice-online-${PV}.tar.gz"

RDEPEND=">=app-office/libreoffice-5.2
		>=dev-libs/poco-1.7.4
		dev-python/polib
		media-libs/libpng:0
		sys-libs/libcap"
DEPEND="${RDEPEND}"

PROG1="/usr/bin/loolforkit"
PROG2="/usr/bin/loolmount"
PROG3="/usr/bin/loolwsd-systemplate-setup"

S="${WORKDIR}/online-${PV}/"

# set-caps taken from loolwsd-Makefile
FILECAPS=(
	cap_fowner,cap_mknod,cap_sys_chroot=ep "${PROG1}" --
	cap_sys_admin=ep "${PROG2}"
)

src_prepare() {
	epatch "${FILESDIR}/${PV}/Makefile.am.patch"
	epatch "${FILESDIR}/${PV}/LOOLKit.cpp.patch"
	eapply_user
}

src_configure() {
	cd "${S}/${PN}" || die "Could not change dir to '${S}/${PN}'"
	local myeconfargs=( \
		--with-lokit-path="${S}/${PN}/bundled/include/" \
		# $(use_enable foo) \
	)
	eautoreconf
	econf ${myeconfargs}
}

src_compile() {
	cd "${S}/${PN}" || die "Could not change dir to '${S}/${PN}'"
	emake
}

src_install() {
	cd "${S}/${PN}" || die "Could not change dir to '${S}/${PN}'"
	emake DESTDIR="${D}" install
	local MY_CNF="${D}/etc/loolwsd/loolwsd.xml"
	cp "${MY_CNF}" "${MY_CNF}.orig" \
		|| die "Could not copy '${MY_CNF}' to '${MY_CNF}.orig'"
}

pkg_postinst() {
	elog "Set required capabilities for '${PROG1}' and '${PROG2}'"
	fcaps_pkg_postinst
}
