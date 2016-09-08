# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit multilib npm

DESCRIPTION="JavaScript build tool, similar to Make or Rake"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND=">=net-libs/nodejs-0.8.10
	>=dev-nodejs/filelist-0.0.4
	>=dev-nodejs/minimatch-0.2.5
	>=dev-nodejs/chalk-0.4.0
	>=dev-nodejs/utilities-1.0.4
	>=dev-nodejs/async-0.9.2
	${DEPEND}"

MY_LIBDIR=$(get_libdir)
MY_P="usr/${MY_LIBDIR}"
NPM_EXTRA_FILES="bin"

src_unpack() {
	unpack "${A}"
	mv "${WORKDIR}/${PN}-v${PV}" "${S}" \
		|| die "Could not move '${WORKDIR}/${PN}-v${PV}' to '${S}'"
}

src_install() {
	npm_src_install
	dodir /usr/bin
	ln -snf "../${MY_LIBDIR}/node_modules/jake/bin/cli.js" "${D}/usr/bin/jake" \
		|| die "Could not create '${D}/usr/bin/jake'"
	chmod 755 "${D}/${MY_P}/node_modules/jake/bin/cli.js" || die \
		"Could not change perms for '${D}/${MY_P}/node_modules/jake/bin/cli.js'"
}
