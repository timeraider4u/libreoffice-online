# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit npm

DESCRIPTION="Lazy-evaluating list of files, based on globs or regex patterns"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND=">=net-libs/nodejs-0.8.10
	>=dev-nodejs/minimatch-0.3.0
	>=dev-nodejs/utilities-0.0.37
	${DEPEND}"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/FileList-v${PV}" "${S}" \
		|| die "Could not move '${WORKDIR}/FileList-v${PV}' to '${S}'"
}
