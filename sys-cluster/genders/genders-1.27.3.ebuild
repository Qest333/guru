# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )
DISTUTILS_USE_SETUPTOOLS=no

inherit autotools distutils-r1 perl-module java-pkg-opt-2

case "${PV}" in
9999)
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/chaos/${PN}.git"
	inherit git-r3
	KEYWORDS=""
	;;
*)
	MY_PV="$(ver_rs 1-2 -)"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://github.com/chaos/${PN}/archive/${MY_P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/${PN}-${MY_P}"
	;;
esac

DESCRIPTION="Static cluster configuration database used for cluster configuration management."
HOMEPAGE="https://github.com/chaos/genders"
LICENSE="GPL-2"
SLOT="0"
IUSE="cxx java perl python"

DOCS=( README TUTORIAL NEWS )

CDEPEND="
	perl?	( dev-lang/perl:= )
	python?	( ${PYTHON_DEPS} )
"
DEPEND="
	${CDEPEND}
	java?	( virtual/jdk:1.8 )

"

RDEPEND="
	${DEPEND}
	java?	( virtual/jre:1.8 )
"
REQUIRED_USE="
		python? ( ${PYTHON_REQUIRED_USE} )
"

src_prepare() {
	sed -i "s|perl python||" src/extensions/Makefile.am
	sed -i "s|\$(DESTDIR)\$(docdir)-\$(VERSION)-javadoc|\$(DESTDIR)\$(docdir)/html/javadoc|" src/extensions/java/Makefile.am
	eapply_user
	./autogen.sh
}

src_configure() {
	use java && append-cflags "-I${S}/src/libgenders"
	use java && append-cflags "$(java-pkg_get-jni-cflags)"

	local myconf=(
		--disable-static
		--with-non-shortened-hostnames
		$(use_with cxx cplusplus-extensions)
		$(use_with java java-extensions)
		$(use_with perl perl-extensions)
		$(use_with python python-extensions)
	)
	econf "${myconf[@]}"
}

src_compile() {
	default

	if use perl ; then
		cd "${S}/src/extensions/perl"
		perl-module_src_configure
		perl-module_src_compile
	fi

	if use python; then
		cd "${S}/src/extensions/python"
		cp genderssetup.py setup.py
		distutils-r1_src_compile
	fi
}

src_test() {
	cd src/testsuite
	default
	cd ../..
}

src_install() {
	default

	if use perl ; then
		cd "${S}/src/extensions/perl"
		unset DOCS
		myinst=( DESTDIR="${D}" )
		perl-module_src_install
	fi

	if use python; then
		cd "${S}/src/extensions/python"
		unset DOCS
		python_install() {
			distutils-r1_python_install
		}
		distutils-r1_src_install
	fi

	find "${ED}" -name '*.la' -delete || die
}
