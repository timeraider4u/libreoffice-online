# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit npm

DESCRIPTION="Terminal string styling done right. Alternative to 'colors' module."

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND=""
RDEPEND=">=net-libs/nodejs-0.8.10
	>=dev-nodejs/has-color-0.1.0
	>=dev-nodejs/ansi-styles-1.0.0
	>=dev-nodejs/strip-ansi-0.1.0
	${DEPEND}"
