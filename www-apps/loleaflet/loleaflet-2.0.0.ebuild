# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="LibreOffice on-line - JavaScript (loleaflet) component."
HOMEPAGE="https://www.collaboraoffice.com/"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

SRC_URI="https://github.com/LibreOffice/online/archive/${PV}.tar.gz
	-> libreoffice-online-${PV}.tar.gz"

RDEPEND="net-libs/nodejs"
DEPEND="${RDEPEND}
		>=dev-nodejs/jake-8.0.12"

S="${WORKDIR}/online-${PV}/"

pkg_setup() {
	# we need this to prevent issue https://github.com/npm/npm/issues/11486
	mkdir -p "/usr/etc" || die "Could not create '/usr/etc'"
}

src_prepare() {
	epatch "${FILESDIR}/${PV}/Makefile.patch"
	eapply_user
}

src_compile() {
	cd "${S}/${PN}" || die "Could not change dir to '${S}/${PN}'"
	emake dist
}

src_install() {
	local MYPATH="usr/share/libreoffice-online"
	local MYPATH_JS="${MYPATH}/${PN}"
	dodir "/${MYPATH_JS}"
	cp -R "${S}/${PN}/dist"/* "${D}/${MYPATH_JS}" || die \
		"could not copy '${S}/${PN}/dist/' to '${D}/${MYPATH_JS}'"
	dosym "../loleaflet" "${MYPATH_JS}/dist"
}

pkg_postinst() {
	rm -rf "/usr/etc" || die "Could not delete '/usr/etc'"
}
