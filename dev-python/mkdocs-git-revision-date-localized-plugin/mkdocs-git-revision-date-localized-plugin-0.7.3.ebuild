# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 )

inherit distutils-r1

DESCRIPTION="Display the localized date of the last git modification of a markdown file"
HOMEPAGE="
	https://github.com/timvink/mkdocs-git-revision-date-localized-plugin
	https://pypi.org/project/mkdocs-git-revision-date-localized-plugin
"
SRC_URI="https://github.com/timvink/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	>=dev-python/Babel-2.7.0[${PYTHON_USEDEP}]
	dev-python/GitPython[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	>=dev-python/mkdocs-1.0[${PYTHON_USEDEP}]
"
DEPEND="test? (
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/mkdocs-material[${PYTHON_USEDEP}]
)"

distutils_enable_tests pytest

python_test() {
	distutils_install_for_testing
	pytest -vv || die "Tests fail with ${EPYTHON}"
}
