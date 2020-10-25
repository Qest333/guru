# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8,9} )

inherit desktop python-single-r1 xdg

# Tarball from initial py3 port branch:
# https://github.com/spirali/rmahjong/tree/py3
# At least "Furiten", "Red fives" rules aren't implemented.
PKG_sha="119704b581e3358ecb2764bd8e208ea5b24e7695"

DESCRIPTION="Riichi Mahjong, the Japanese variant of the Chinese game Mahjong for 4 players"
HOMEPAGE="https://github.com/spirali/rmahjong"

# PNG icon is taken from Kmahjongg project (GPL-2), renamed to avoid pkgs conflicts
SRC_URI="
	https://github.com/spirali/${PN}/archive/${PKG_sha}.tar.gz -> ${P}.tar.gz
	https://github.com/KDE/kmahjongg/raw/master/icons/48-apps-kmahjongg.png -> kmahjongg_${PN}.png"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="test"
RESTRICT="!test? ( test )"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}/${PN}-${PKG_sha}"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/pygame[X,opengl]
	$(python_gen_cond_dep '
		dev-python/pygame[${PYTHON_MULTI_USEDEP}]
		dev-python/pyopengl[${PYTHON_MULTI_USEDEP}]
	')
"
DEPEND="test? ( dev-python/unittest2 )"

PATCHES=(
	"${FILESDIR}/${PN}-0.4_fix_python3_compat.patch"
	"${FILESDIR}/${PN}-0.4_fix_tests.patch"
)

src_prepare(){
	default

	# Disable logging as application log into directory where user access is denied
	sed -i "/logging.basicConfig/d" "${S}/client/client.py" || die
	sed -i "/logging.basicConfig/d" "${S}/server/server.py" || die
	sed -i "/logging.info/d" "${S}/server/server.py" || die

	echo $'#!/bin/sh\ncd '"$(python_get_sitedir)/${PN}"' && ./start.sh' > "${S}/rmahjong"
}

src_compile() {
	# Build bots
	cd "${S}/bot/" && emake
}

src_test() {
	cd "${S}/server/" && python3 test.py
}

src_install() {
	insinto "$(python_get_sitedir)/${PN}"
	doins -r {client/,server/,start.sh}
	fperms 755 $(python_get_sitedir)/${PN}/start.sh
	fperms 755 $(python_get_sitedir)/${PN}/server/run_server.sh

	insinto "$(python_get_sitedir)/${PN}/bot"
	doins "bot/bot"
	fperms 755 $(python_get_sitedir)/${PN}/bot/bot

	python_optimize "${D}/$(python_get_sitedir)/${PN}/"{client,server}/*.py

	dobin "rmahjong"
	doicon -s 48 "${DISTDIR}/kmahjongg_${PN}.png"
	make_desktop_entry "${PN}" "RMahjong" "kmahjongg_${PN}.png" "Game;BoardGame;" || die "Failed making desktop entry!"
}